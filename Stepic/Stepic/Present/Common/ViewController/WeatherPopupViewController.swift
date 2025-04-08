//
//  WeatherPopupViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/8/25.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class WeatherAttributionPopupViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let appleWeatherLinkView = UIControl()
    private let appleLogoImageView = UIImageView()
    private let weatherLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let dismissButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
        configureBind()
    }
    
    private func configureBind() {
        backgroundView.rx
            .tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        dismissButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        appleWeatherLinkView.rx.tapGesture().when(.recognized)
            .bind { _ in
                if let url = URL(string: "https://weatherkit.apple.com/legal-attribution.html") {
                    UIApplication.shared.open(url)
                }
            }
            .disposed(by: disposeBag)
    }

    private func configureView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        containerView.backgroundColor = .backgroundPrimary
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true

        titleLabel.text = .StringLiterals.Common.weatherInfoSource
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .textPrimary

        appleLogoImageView.image = UIImage(systemName: "apple.logo")
        appleLogoImageView.tintColor = .label
        appleLogoImageView.contentMode = .scaleAspectFit

        weatherLabel.text = "Weather"
        weatherLabel.font = .systemFont(ofSize: 15, weight: .medium)
        weatherLabel.textColor = .textPrimary

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .accessoryContent
        chevronImageView.contentMode = .scaleAspectFit

        appleWeatherLinkView.backgroundColor = .backgroundSecondary
        appleWeatherLinkView.layer.cornerRadius = 8

        dismissButton.setTitle(.StringLiterals.Common.genericAlertConfirm, for: .normal)
        dismissButton.setTitleColor(.systemBlue, for: .normal)
        dismissButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    private func configureHierarchy() {
        view.addSubviews(
            backgroundView,
            containerView
        )

        containerView.addSubviews(
            titleLabel,
            appleWeatherLinkView,
            dismissButton
        )

        appleWeatherLinkView.addSubviews(
            appleLogoImageView,
            weatherLabel,
            chevronImageView
        )
    }

    private func configureLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        appleWeatherLinkView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        appleLogoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        weatherLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(appleLogoImageView.snp.trailing).offset(8)
        }

        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.width.equalTo(8)
        }

        dismissButton.snp.makeConstraints {
            $0.top.equalTo(appleWeatherLinkView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}
