//
//  MyPageViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit
import SwiftUI

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private let viewWillAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    private let settingButton = UIBarButtonItem()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let myPageInfoView = MyPageInfoView()
    private let statisticsLabel = UILabel()
    private let emotionBarChartController = UIHostingController(rootView: EmotionBarChartView(emotions: []))
    private let walkDurationChartController = UIHostingController(rootView: WalkDurationChartView(data: []))
    private let distanceChartController = UIHostingController(rootView: DistanceChartView(data: []))
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBind()
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
    }
    
    private func configureBind() {
        let selectDateDidChangeRelay = PublishRelay<YearMonth>()
        
        let input = MyPageViewModel.Input(
            viewWillAppear: viewWillAppearRelay.asObservable(),
            selectDateDidChange: selectDateDidChangeRelay.asObservable(),
            totalWalkButtonDidTap: myPageInfoView.totalWalkButton.rx.tapGesture().map { _ in }.asObservable(),
            monthWalkButtonDidTap: myPageInfoView.monthWalkButton.rx.tapGesture().map { _ in }.asObservable(),
            bookmarkButtonDidTap: myPageInfoView.bookmarkButton.rx.tapGesture().map { _ in }.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.selectedDate
            .drive(with: self) { owner, yearMonth in
                owner.myPageInfoView.configureView(yearMonth)
            }
            .disposed(by: disposeBag)
        
        output.myPageInfoItems
            .drive(with: self) { owner, myPageInfoItem in
                owner.myPageInfoView.configureView(myPageInfoItem)
            }
            .disposed(by: disposeBag)
        
        output.moveToSummaryView
            .drive(with: self) { owner, type in
                let reactor = WalkSummaryReactor(viewType: type)
                let viewController = WalkSummaryViewController(reactor: reactor)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.emotionStaticData
            .drive(with: self) { owner, data in
                owner.emotionBarChartController.rootView = EmotionBarChartView(emotions: data)
            }
            .disposed(by: disposeBag)
        
        output.durationChartData
            .drive(with: self) { owner, data in
                owner.walkDurationChartController.rootView = WalkDurationChartView(data: data)
            }
            .disposed(by: disposeBag)
        
        output.distanceChartData
            .drive(with: self) { owner, data in
                owner.distanceChartController.rootView = DistanceChartView(data: data)
            }
            .disposed(by: disposeBag)
        
        /// 뷰 내부 로직
        myPageInfoView.calendarButton.rx.tap
            .bind(with: self) { owner, _ in
                let monthPicker = MonthPickerViewController() { selected in
                    selectDateDidChangeRelay.accept(selected)
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
        
        settingButton.rx.tap
            .bind(with: self) { owner, _ in
                let viewController = SettingsViewController()
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        settingButton.image = .gearShape
        settingButton.tintColor = .textPrimary
        
        navigationItem.rightBarButtonItem = settingButton
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        scrollView.showsVerticalScrollIndicator = false
        
        emotionBarChartController.view.layer.cornerRadius = 10
        emotionBarChartController.view.clipsToBounds = true
        
        walkDurationChartController.view.layer.cornerRadius = 10
        walkDurationChartController.view.clipsToBounds = true
        
        distanceChartController.view.layer.cornerRadius = 10
        distanceChartController.view.clipsToBounds = true
        
        statisticsLabel.text = .StringLiterals.MyPage.statisticsTitle
        statisticsLabel.textColor = .textPrimary
        statisticsLabel.font = .titleLarge
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            myPageInfoView,
            statisticsLabel,
            emotionBarChartController.view,
            walkDurationChartController.view,
            distanceChartController.view
        )
        
        addChild(emotionBarChartController)
        emotionBarChartController.didMove(toParent: self)
        addChild(walkDurationChartController)
        walkDurationChartController.didMove(toParent: self)
        addChild(distanceChartController)
        distanceChartController.didMove(toParent: self)
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        myPageInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        statisticsLabel.snp.makeConstraints {
            $0.top.equalTo(myPageInfoView.snp.bottom).offset(34)
            $0.leading.equalTo(22)
        }
        
        emotionBarChartController.view.snp.makeConstraints {
            $0.top.equalTo(statisticsLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(240)
        }
        
        walkDurationChartController.view.snp.makeConstraints {
            $0.top.equalTo(emotionBarChartController.view.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        
        distanceChartController.view.snp.makeConstraints {
            $0.top.equalTo(walkDurationChartController.view.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.bottom.equalToSuperview().inset(54)
        }
    }
}
