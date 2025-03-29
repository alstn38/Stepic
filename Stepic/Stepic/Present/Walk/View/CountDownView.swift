//
//  CountDownView.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import Lottie
import SnapKit

final class CountDownView: UIView {
    
    private var animationView = LottieAnimationView()
    
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
    
    func startAnimation(completion: @escaping () -> Void) {
        self.isHidden = false
        
        animationView.play(
            fromFrame: 60,
            toFrame: 157,
            loopMode: .playOnce
        ) { completed in
            self.isHidden = true
            completion()
        }
    }
    
    private func configureView() {
        self.isHidden = true
        self.backgroundColor = .backgroundPrimary
        
        if self.traitCollection.userInterfaceStyle == .dark {
            animationView = LottieAnimationView(name: "countDownDark")
        } else {
            animationView = LottieAnimationView(name: "countDownLight")
        }
    }
    
    private func configureHierarchy() {
        addSubview(animationView)
    }
    
    private func configureLayout() {
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(150)
        }
    }
}
