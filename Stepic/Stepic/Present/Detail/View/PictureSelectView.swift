//
//  PictureSelectView.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import SnapKit

final class PictureSelectView: UIView {
    
    private let title = UILabel()
    lazy var pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        title.text = .StringLiterals.Detail.photoTitle
        title.textColor = .textPrimary
        title.font = .titleLarge
        
        pictureCollectionView.delegate = self // TODO: 이후 삭제
        pictureCollectionView.dataSource = self // TODO: 이후 삭제
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.register(
            DetailAddPictureCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailAddPictureCollectionViewCell.identifier
        )
        pictureCollectionView.register(
            DetailPictureCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailPictureCollectionViewCell.identifier
        )
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            title,
            pictureCollectionView
        )
    }
    
    private func configureLayout() {
        title.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
        }
        
        pictureCollectionView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(195)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let screenWidth: CGFloat = self.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let groupWidth = screenWidth - (22 * 2)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(groupWidth),
            heightDimension: .fractionalHeight(1)
        )
        
        let groupLayout = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let sectionLayout = NSCollectionLayoutSection(group: groupLayout)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        sectionLayout.interGroupSpacing = 22
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 22,
            bottom: 4,
            trailing: 22
        )
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        return layout
    }
}

// TODO: 이후 삭제
extension PictureSelectView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 3 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DetailAddPictureCollectionViewCell.identifier,
                for: indexPath
            ) as? DetailAddPictureCollectionViewCell else { return UICollectionViewCell() }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DetailPictureCollectionViewCell.identifier,
                for: indexPath
            ) as? DetailPictureCollectionViewCell else { return UICollectionViewCell() }
            
            return cell
        }
    }
}
