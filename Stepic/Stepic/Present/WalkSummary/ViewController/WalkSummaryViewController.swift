//
//  WalkSummaryViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import UIKit

import SnapKit

final class WalkSummaryViewController: UIViewController {
    
    private lazy var walkSummaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        walkSummaryCollectionView.backgroundColor = .backgroundPrimary
        walkSummaryCollectionView.showsVerticalScrollIndicator = false
        walkSummaryCollectionView.delegate = self // TODO: 이후 삭제
        walkSummaryCollectionView.dataSource = self // TODO: 이후 삭제
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

// TODO: 이후 삭제
extension WalkSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalkSummaryCollectionViewCell.identifier,
            for: indexPath
        ) as? WalkSummaryCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
}
