//
//  DetailPictureCollectionViewCell.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import RxSwift
import SnapKit

final class DetailPictureCollectionViewCell: UICollectionViewCell, ReusableViewProtocol {
    
    private let imageView = UIImageView()
    let deleteButton = UIButton()
    var disposeBag = DisposeBag()
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    func configureView(
        _ data: WalkPhotoEntity,
        viewMode: DetailViewModel.DetailViewType
    ) {
        imageView.image = data.image
        
        switch viewMode {
        case .create:
            deleteButton.isHidden = false
        case .viewer:
            deleteButton.isHidden = true
        }
    }
    
    private func configureView() {
        contentView.backgroundColor = .backgroundSecondary
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
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
            $0.edges.equalToSuperview().inset(4)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalTo(imageView).inset(4)
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
