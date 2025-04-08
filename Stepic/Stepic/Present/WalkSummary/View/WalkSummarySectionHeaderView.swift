//
//  WalkSummarySectionHeaderView.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import UIKit

import SnapKit

final class WalkSummarySectionHeaderView: UICollectionReusableView, ReusableViewProtocol {
    
    private let monthLabel = UILabel()
    private let dayLabel = UILabel()
    
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
        monthLabel.text = "3월" // TODO: 이후 삭제
        monthLabel.textColor = .textPrimary
        monthLabel.font = .bodyRegular
        
        dayLabel.text = "25" // TODO: 이후 삭제
        dayLabel.textColor = .textPrimary
        dayLabel.font = .titleExtraLargeMedium
    }
    
    private func configureHierarchy() {
        addSubviews(
            monthLabel,
            dayLabel
        )
    }
    
    private func configureLayout() {
        monthLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}
