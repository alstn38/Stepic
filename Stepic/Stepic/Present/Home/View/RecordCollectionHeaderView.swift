//
//  RecordCollectionHeaderView.swift
//  Stepic
//
//  Created by 강민수 on 3/28/25.
//

import UIKit

import SnapKit

final class RecordCollectionHeaderView: UICollectionReusableView, ReusableViewProtocol {
    
    private let titleLabel = UILabel()
    
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
        titleLabel.text = .StringLiterals.Home.recordTitle
        titleLabel.textColor = .textPrimary
        titleLabel.font = .titleLarge
    }
    
    private func configureHierarchy() {
        addSubview(titleLabel)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
}
