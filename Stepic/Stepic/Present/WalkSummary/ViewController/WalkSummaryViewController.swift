//
//  WalkSummaryViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class WalkSummaryViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    private lazy var walkSummaryCollectionDataSource = UICollectionViewDiffableDataSource<WalkSummarySection, WalkDiaryEntity>(
        collectionView: walkSummaryCollectionView,
        cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalkSummaryCollectionViewCell.identifier,
                for: indexPath
            ) as? WalkSummaryCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureView(itemIdentifier)
            return cell
        }
    )
    
    private let searchBar = UISearchBar()
    private let walkSummaryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let noResultLabel = UILabel()
    
    init(reactor: WalkSummaryReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setTracking()
    }
    
    func bind(reactor: WalkSummaryReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: WalkSummaryReactor) {
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        walkSummaryCollectionView.rx.itemSelected
            .map { Reactor.Action.diaryItemSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: WalkSummaryReactor) {
        reactor.state
            .map { $0.filteredData }
            .bind(with: self) { owner, data in
                owner.updateSnapshot(data: data)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isHiddenResultLabel }
            .distinctUntilChanged()
            .bind(to: noResultLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDiary)
            .compactMap { $0 }
            .bind(with: self) { owner, diaryData in
                let viewModel = DetailViewModel(detailViewType: .viewer(walkDiary: diaryData))
                let viewController = DetailViewController(viewModel: viewModel)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setTracking() {
        Tracking.logScreen(name: Tracking.Screen.walkCollection, from: self)
        
        searchBar.rx.textDidBeginEditing
            .bind { _ in
                Tracking.logEvent(Tracking.Event.searchWalk)
            }
            .disposed(by: disposeBag)
        
        walkSummaryCollectionView.rx.itemSelected
            .bind { _ in
                Tracking.logEvent(Tracking.Event.tapSummaryWalkPreview)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        searchBar.placeholder = .StringLiterals.WalkSummary.searchPlaceholder
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        
        walkSummaryCollectionView.backgroundColor = .backgroundPrimary
        walkSummaryCollectionView.keyboardDismissMode = .onDrag
        walkSummaryCollectionView.showsVerticalScrollIndicator = false
        walkSummaryCollectionView.collectionViewLayout = configureCollectionViewLayout()
        walkSummaryCollectionView.register(
            WalkSummaryCollectionViewCell.self,
            forCellWithReuseIdentifier: WalkSummaryCollectionViewCell.identifier
        )
        
        noResultLabel.text = .StringLiterals.WalkSummary.summaryEmptyTitle
        noResultLabel.textColor = .textSecondary
        noResultLabel.font = .bodyRegular
        noResultLabel.textAlignment = .center
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            searchBar,
            walkSummaryCollectionView,
            noResultLabel
        )
    }
    
    private func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        walkSummaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        noResultLabel.snp.makeConstraints {
            $0.center.equalTo(walkSummaryCollectionView)
        }
    }
    
    private func updateSnapshot(data: [WalkDiaryEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<WalkSummarySection, WalkDiaryEntity>()
        snapshot.appendSections(WalkSummarySection.allCases)
        snapshot.appendItems(data, toSection: .main)
        walkSummaryCollectionDataSource.apply(snapshot)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let height = (screenWidth - 81) / 2 + 217
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(height)
        )
        
        let groupLayout = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let sectionLayout = NSCollectionLayoutSection(group: groupLayout)
        sectionLayout.interGroupSpacing = 24
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        return layout
    }
}
