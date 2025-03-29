//
//  WalkButtonView.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import SnapKit

final class WalkButtonView: UIView {
    
    private let buttonImage: UIImage
    private let buttonImageView = UIImageView()
    
    init(buttonImage: UIImage) {
        self.buttonImage = buttonImage
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

    private func configureView() {
        self.layer.cornerRadius = 26
        self.backgroundColor = .backgroundButton
        
        buttonImageView.image = buttonImage
        buttonImageView.contentMode = .scaleAspectFit
        buttonImageView.tintColor = .white
    }
    
    private func configureHierarchy() {
        self.addSubview(buttonImageView)
    }
    
    private func configureLayout() {
        buttonImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
    }
}
