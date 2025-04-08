//
//  WalkSummaryViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

final class WalkSummaryViewController: UIViewController {
    
    private let viewModel: WalkSummaryViewModel
    private let viewWillAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
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
    private lazy var walkSummaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    init(viewModel: WalkSummaryViewModel) {
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
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
    }
    
    private func configureBind() {
        let input = WalkSummaryViewModel.Input(
            viewWillAppear: viewWillAppearRelay.asObservable(),
            searchTextDidChange: searchBar.rx.text.orEmpty.asObservable(),
            diaryDataDidTap: walkSummaryCollectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.filteredWalkDiaryData
            .drive(with: self) { owner, data in
                owner.updateSnapshot(data: data)
            }
            .disposed(by: disposeBag)
        
        output.moveToDetailView
            .drive(with: self) { owner, diaryData in
                let viewModel = DetailViewModel(detailViewType: .viewer(walkDiary: diaryData))
                let viewController = DetailViewController(viewModel: viewModel)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        /// 뷰 내부 로직
        searchBar.rx.searchButtonClicked
            .bind(with: self) { owner, _ in
                owner.searchBar.resignFirstResponder()
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
        walkSummaryCollectionView.register(
            WalkSummaryCollectionViewCell.self,
            forCellWithReuseIdentifier: WalkSummaryCollectionViewCell.identifier
        )
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            searchBar,
            walkSummaryCollectionView
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
