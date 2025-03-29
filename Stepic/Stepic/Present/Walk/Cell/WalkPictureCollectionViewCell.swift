//
//  WalkPictureCollectionViewCell.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import SnapKit

final class WalkPictureCollectionViewCell: UICollectionViewCell, ReusableViewProtocol {
    
    private let imageView = UIImageView()
    private let deleteButton = UIButton()
    
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
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.backgroundButton.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOffset = CGSize(width: 5, height: 10)
        contentView.layer.shadowPath = nil
        
        imageView.backgroundColor = .yellow // TODO: 이후 제거
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        deleteButton.configuration = configureButtonConfiguration()
        deleteButton.layer.cornerRadius = 10
        deleteButton.clipsToBounds = true
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            imageView,
            deleteButton
        )
    }
    
    private func configureLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(20)
        }
    }
    
    private func configureButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.image = .xMark
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 10)
        configuration.baseBackgroundColor = .accessoryBackground
        configuration.baseForegroundColor = .accessoryContent
        
        return configuration
    }
}
