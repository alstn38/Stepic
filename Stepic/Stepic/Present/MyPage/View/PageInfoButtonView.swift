//
//  PageInfoButtonView.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import SnapKit

final class PageInfoButtonView: UIView {
    
    private let image: UIImage
    private let title: String
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    
    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
        super.init(frame: .zero)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) {
                self.alpha = 0.5
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) {
                self.alpha = 1.0
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) {
                self.alpha = 1.0
            }
        }
    }
    
    func configureView(subTitle: String) {
        subTitleLabel.text = subTitle
    }

    private func configureView() {
        imageView.image = image
        imageView.tintColor = .textPrimary
        
        titleLabel.text = title
        titleLabel.textColor = .textSecondary
        titleLabel.font = .captionRegular
        
        subTitleLabel.text = " "
        subTitleLabel.textColor = .textPrimary
        subTitleLabel.font = .bodyBold
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            imageView,
            titleLabel,
            subTitleLabel
        )
    }
    
    private func configureLayout() {
        imageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
