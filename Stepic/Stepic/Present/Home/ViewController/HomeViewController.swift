//
//  HomeViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

import FSCalendar
import SnapKit

final class HomeViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let calendarTitleLabel = UILabel()
    private let calendarButton = UIButton()
    private let calendar = FSCalendar()
    private lazy var recordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionLayout())
    private let recordButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        scrollView.showsVerticalScrollIndicator = false
        
        calendarTitleLabel.text = "2025년 3월" // TODO: 이후 서버 연결
        calendarTitleLabel.textColor = .textPrimary
        calendarTitleLabel.font = .titleLarge
        
        calendarButton.configuration = configureButtonConfiguration()
        
        calendar.headerHeight = 0
        calendar.appearance.weekdayTextColor = .textSecondary // 요일 글자색
        calendar.weekdayHeight = 30
        calendar.placeholderType = .none
        calendar.scope = .month
        calendar.appearance.titleFont = .captionRegular // 날짜 숫자 크기
        calendar.appearance.imageOffset = CGPoint(x: 0, y: 10) // 이미지 위치 조정
        calendar.backgroundColor = .backgroundSecondary
        calendar.layer.cornerRadius = 10
        calendar.clipsToBounds = true
        calendar.appearance.titleDefaultColor = .textSecondary // 기본 날짜 글자색
        calendar.appearance.selectionColor = .accentPrimary.withAlphaComponent(0.3) // 선택된 날짜 배경색
        calendar.appearance.titleSelectionColor = .white // 선택된 날짜 글자색
        calendar.appearance.todayColor = .accentPrimary
        calendar.appearance.titleTodayColor = .white
        
        recordCollectionView.backgroundColor = .clear
        recordCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell") // TODO: 기본 Cell
        
        recordButton.setTitle(.StringLiterals.Home.walkButtonTitle, for: .normal)
        recordButton.backgroundColor = .accentPrimary
        recordButton.setTitleColor(.white, for: .normal)
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
            $0.top.equalTo(calendar.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(375)
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(recordCollectionView.snp.bottom).offset(76)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(44)
            $0.bottom.equalTo(contentView).inset(54)
        }
    }
    
    private func configureCollectionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(225))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(225))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .chevronDown
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12)
        configuration.baseForegroundColor = .accessoryContent
        
        return configuration
    }
}
