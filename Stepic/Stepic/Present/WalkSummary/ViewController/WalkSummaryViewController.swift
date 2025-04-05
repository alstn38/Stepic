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
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<WalkSummarySection>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalkSummaryCollectionViewCell.identifier,
                for: indexPath
            ) as? WalkSummaryCollectionViewCell else { return UICollectionViewCell() }

            cell.configureView(item)
            return cell
        }
    )
    
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
    
    private func configureBind() {
        let input = WalkSummaryViewModel.Input(viewDidLoad: Observable.just(()))
        let output = viewModel.transform(from: input)
        
        output.walkDiaryData
            .map { [WalkSummarySection(items: $0)] }
            .drive(walkSummaryCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        /// 뷰 내부 로직
        walkSummaryCollectionView.rx.modelSelected(WalkDiaryEntity.self)
            .bind(with: self) { owner, diaryData in
                let viewModel = DetailViewModel(detailViewType: .viewer(walkDiary: diaryData))
                let viewController = DetailViewController(viewModel: viewModel)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        walkSummaryCollectionView.backgroundColor = .backgroundPrimary
        walkSummaryCollectionView.showsVerticalScrollIndicator = false
        walkSummaryCollectionView.register(
            WalkSummaryCollectionViewCell.self,
            forCellWithReuseIdentifier: WalkSummaryCollectionViewCell.identifier
        )
    }
    
    private func configureHierarchy() {
        view.addSubview(walkSummaryCollectionView)
    }
    
    private func configureLayout() {
        walkSummaryCollectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
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
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        return layout
    }
}
