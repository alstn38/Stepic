//
//  DetailAddPictureCollectionViewCell.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import SnapKit

final class DetailAddPictureCollectionViewCell: UICollectionViewCell, ReusableViewProtocol {
    
    private let addPictureView = UIView()
    private let addPictureButton = UIButton()
    
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
        contentView.backgroundColor = .backgroundSecondary
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        addPictureView.backgroundColor = .textPlaceholder
        addPictureView.layer.cornerRadius = 10
        addPictureView.clipsToBounds = true
        
        addPictureButton.configuration = configureButtonConfiguration()
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            addPictureView,
            addPictureButton
        )
    }
    
    private func configureLayout() {
        addPictureView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        
        addPictureButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(40)
        }
    }
    
    private func configureButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .photoBadgePlus
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28)
        configuration.baseForegroundColor = .textPrimary
        
        return configuration
    }
}
