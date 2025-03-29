//
//  WalkButtonView.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class WalkButtonView: UIView {
    
    let tapGesture = UITapGestureRecognizer()
    var longTapGesture: Observable<Void> {
        return logTapGestureSubject.asObserver()
    }
    
    private let longGesture: Bool
    private let buttonImage: UIImage
    private var longPressTimer: Timer?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let logTapGestureSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let buttonImageView = UIImageView()
    
    init(longGesture: Bool, buttonImage: UIImage) {
        self.longGesture = longGesture
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
        
        if longGesture {
            feedbackGenerator.prepare()
            let longPressGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
            longPressGesture.minimumPressDuration = 0.1
            self.addGestureRecognizer(longPressGesture)
            
            buttonImageView.image = buttonImage
            buttonImageView.contentMode = .scaleAspectFit
            buttonImageView.tintColor = .white
        } else {
            self.addGestureRecognizer(tapGesture)
        }
        
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
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startLongPressAnimation()
        case .ended, .cancelled:
            resetButton()
        default:
            break
        }
    }
    
    private func startLongPressAnimation() {
        feedbackGenerator.impactOccurred()
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        })
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) {
            [weak self] _ in
            self?.logTapGestureSubject.onNext(())
            self?.resetButton()
            self?.feedbackGenerator.impactOccurred()
        }
    }
    
    private func resetButton() {
        self.layer.removeAllAnimations()
        longPressTimer?.invalidate()
        longPressTimer = nil
        
        self.transform = .identity
    }
}
