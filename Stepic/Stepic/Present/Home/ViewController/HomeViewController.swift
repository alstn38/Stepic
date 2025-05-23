//
//  HomeViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

import FSCalendar
import RxCocoa
import RxDataSources
import RxGesture
import RxSwift
import SnapKit

final class HomeViewController: UIViewController {
    
    private let viewModel: HomeViewModel
    private var walkDiaryData: [WalkDiaryEntity] = []
    private let viewWillAppearRelay = PublishRelay<Void>()
    private let calendarDidSelectRelay = PublishRelay<Date>()
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeRecordSection>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCollectionViewCell.identifier,
                for: indexPath
            ) as? RecordCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureView(item)
            return cell
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }

            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RecordCollectionHeaderView.identifier,
                for: indexPath
            ) as? RecordCollectionHeaderView else { return UICollectionReusableView() }
            
            return header
        }
    )
    
    private let weatherView = WeatherView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let calendarTitleLabel = UILabel()
    private let calendarButton = UIButton()
    private let calendar = FSCalendar()
    private lazy var recordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionLayout())
    private let recordButton = UIButton(type: .system)
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
        configureBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setTracking()
    }
    
    private func configureBind() {
        let selectDateDidChangeRelay = PublishRelay<YearMonth>()
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppearRelay.asObservable(),
            selectDateDidChange: selectDateDidChangeRelay.asObservable(),
            calendarDidSelect: calendarDidSelectRelay.asObservable(),
            recordButtonDidTap: recordButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.weatherLocationData
            .drive(with: self) { owner, data in
                owner.weatherView.configureView(data)
            }
            .disposed(by: disposeBag)
        
        output.selectedDate
            .drive(with: self) { owner, yearMonth in
                let calendarTitle = DateFormatManager.shared.selectMonthTitle(
                    year: yearMonth.year,
                    month: yearMonth.month
                )
                owner.calendarTitleLabel.text = calendarTitle
                owner.moveCalendar(toYear: yearMonth.year, month: yearMonth.month)
            }
            .disposed(by: disposeBag)
        
        output.walkDiaryData
            .drive(with: self) { owner, data in
                owner.walkDiaryData = data
                owner.calendar.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.selectDiaryData
            .map { [HomeRecordSection(items: $0)] }
            .drive(recordCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.selectDiaryData
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, isEmpty in
                owner.updateRecordCollectionViewLayout(isHidden: isEmpty)
            }
            .disposed(by: disposeBag)

        output.moveToWalkView
            .drive(with: self) { owner, _ in
                let viewModel = WalkViewModel()
                let viewController = WalkViewController(viewModel: viewModel)
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .crossDissolve
                self.present(viewController, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.presentAlert
            .drive(with: self) { owner, alertType in
                switch alertType {
                case .messageError(let title, let message):
                    owner.presentWarningAlert(title: title, message: message)
                case .locationSetting:
                    owner.presentToSettingAppWithLocation()
                }
            }
            .disposed(by: disposeBag)
        
        /// 뷰 내부 로직
        calendarButton.rx.tap
            .bind(with: self) { owner, _ in
                let monthPicker = MonthPickerViewController() { selected in
                    selectDateDidChangeRelay.accept(selected)
                    Tracking.logEvent(Tracking.Event.mainChangeMonth)
                }
                
                monthPicker.modalPresentationStyle = .pageSheet
                if let sheet = monthPicker.sheetPresentationController {
                    sheet.detents = [
                        .custom(resolver: { context in
                            return context.maximumDetentValue * 0.3
                        })
                    ]
                }
                
                owner.present(monthPicker, animated: true)
            }
            .disposed(by: disposeBag)
        
        recordCollectionView.rx.modelSelected(WalkDiaryEntity.self)
            .bind(with: self) { owner, diaryData in
                let viewModel = DetailViewModel(detailViewType: .viewer(walkDiary: diaryData))
                let viewController = DetailViewController(viewModel: viewModel)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        weatherView.rx.tapGesture().when(.recognized)
            .bind(with: self) { owner, _ in
                let viewController = WeatherAttributionPopupViewController()
                viewController.modalPresentationStyle = .overFullScreen
                viewController.modalTransitionStyle = .crossDissolve
                owner.present(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setTracking() {
        Tracking.logScreen(name: Tracking.Screen.main, from: self)
        
        recordButton.rx.tap
            .bind { _ in
                Tracking.logEvent(Tracking.Event.startWalk)
            }
            .disposed(by: disposeBag)
        
        calendarDidSelectRelay
            .bind { _ in
                Tracking.logEvent(Tracking.Event.tapCalendarEmoji)
            }
            .disposed(by: disposeBag)
        
        recordCollectionView.rx.itemSelected
            .bind { _ in
                Tracking.logEvent(Tracking.Event.tapMainWalkPreview)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        let leftItem = UIBarButtonItem(customView: weatherView)
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        scrollView.showsVerticalScrollIndicator = false
        
        calendarTitleLabel.textColor = .textPrimary
        calendarTitleLabel.font = .titleLarge
        
        calendarButton.configuration = configureCalendarButtonConfiguration()
        
        calendar.headerHeight = 0
        calendar.appearance.weekdayTextColor = .textSecondary // 요일 글자색
        calendar.weekdayHeight = 30
        calendar.placeholderType = .none
        calendar.scope = .month
        calendar.appearance.titleFont = .captionRegular // 날짜 숫자 크기
        calendar.appearance.titleOffset = CGPoint(x: 0, y: -10)
        calendar.appearance.imageOffset = CGPoint(x: 0, y: 3) // 이미지 위치 조정
        calendar.backgroundColor = .backgroundSecondary
        calendar.layer.cornerRadius = 10
        calendar.clipsToBounds = true
        calendar.appearance.titleDefaultColor = .textSecondary // 기본 날짜 글자색
        calendar.appearance.selectionColor = .accentPrimary.withAlphaComponent(0.7) // 선택된 날짜 배경색
        calendar.appearance.titleSelectionColor = .white // 선택된 날짜 글자색
        calendar.appearance.todayColor = .accentPrimary
        calendar.appearance.titleTodayColor = .white
        calendar.scrollEnabled = false
        calendar.appearance.borderRadius = 8.0
        
        calendar.delegate = self
        calendar.dataSource = self
        calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
        
        recordCollectionView.backgroundColor = .clear
        recordCollectionView.register(
            RecordCollectionViewCell.self,
            forCellWithReuseIdentifier: RecordCollectionViewCell.identifier
        )
        recordCollectionView.register(
            RecordCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecordCollectionHeaderView.identifier
        )
        
        recordButton.configuration = configureMainButtonButtonConfiguration(title: .StringLiterals.Home.walkButtonTitle)
        recordButton.layer.cornerRadius = 10
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            calendarTitleLabel,
            calendarButton,
            calendar,
            recordCollectionView,
            recordButton
        )
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        calendarTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(22)
        }
        
        calendarButton.snp.makeConstraints {
            $0.centerY.equalTo(calendarTitleLabel)
            $0.leading.equalTo(calendarTitleLabel.snp.trailing).offset(6)
            $0.size.equalTo(20)
        }
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(calendarTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(calendar.snp.width).multipliedBy(1.3)
        }
        
        recordCollectionView.snp.makeConstraints {
            let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
            let height = (screenWidth - 56) / 2 + 174 + 38
            $0.top.equalTo(calendar.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(height)
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(recordCollectionView.snp.bottom).offset(76)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(44)
            $0.bottom.equalTo(contentView).inset(54)
        }
    }
    
    private func configureCollectionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let groupHeight = (screenWidth - 56) / 2 + 174
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth - 44),
            heightDimension: .absolute(groupHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 22, bottom: .zero, trailing: 22)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(38)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureCalendarButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .chevronDown
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12)
        configuration.baseForegroundColor = .accessoryContent
        
        return configuration
    }
    
    /// FSCalendar 위치 이동 메서드
    private func moveCalendar(toYear year: Int, month: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        if let targetDate = Calendar.current.date(from: components) {
            calendar.setCurrentPage(targetDate, animated: true)
        }
    }
}

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    /// 캘린더의 이미지 설정
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let calendar = Calendar.current
        
        return walkDiaryData
            .first { calendar.isDate($0.startDate, inSameDayAs: date) }
            .flatMap { EmotionTypeEntity(rawValue: $0.emotion)?.image }
            .flatMap { resizeImage(image: $0, targetSize: CGSize(width: 30, height: 30)) }
            .map { $0.withTintColor(.textPrimary) }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(
            withIdentifier: CalendarCell.identifier,
            for: date,
            at: position
        ) as? CalendarCell else { return FSCalendarCell() }
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendarDidSelectRelay.accept(date)
    }
    
    /// 이미지 크기 조절 (파일 위치 변경 가능)
    private func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    /// collectionView Hidden 애니메이션 메서드
    private func updateRecordCollectionViewLayout(isHidden: Bool) {
        let screenWidth = UIScreen.main.bounds.width
        let visibleHeight = (screenWidth - 56) / 2 + 174 + 38
        let newHeight = isHidden ? 0 : visibleHeight

        UIView.animate(withDuration: 0.3) {
            self.recordCollectionView.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
            self.recordCollectionView.alpha = isHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
}
