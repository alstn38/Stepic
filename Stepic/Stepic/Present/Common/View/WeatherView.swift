//
//  WeatherView.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import SnapKit

final class WeatherView: UIView {
    
    private let weatherImageView = UIImageView()
    private let locationLabel = UILabel()
    private let weatherLabel = UILabel()
    
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
        weatherImageView.image = UIImage(systemName: "sun.max") // TODO: 이후 삭제
        weatherImageView.contentMode = .scaleAspectFill
        weatherImageView.tintColor = .textPrimary
        
        locationLabel.text = "서울특별시 광진구" // TODO: 이후 서버 연결
        locationLabel.textColor = .textPrimary
        locationLabel.font = .bodyBold
        
        weatherLabel.text = "맑음 7°C" // TODO: 이후 서버 연결
        weatherLabel.textColor = .textPrimary
        weatherLabel.font = .captionRegular
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            weatherImageView,
            locationLabel,
            weatherLabel
        )
    }
    
    private func configureLayout() {
        weatherImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.size.equalTo(32)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(weatherImageView)
            $0.leading.equalTo(weatherImageView.snp.trailing).offset(8)
        }
        
        weatherLabel.snp.makeConstraints {
            $0.bottom.equalTo(weatherImageView)
            $0.leading.equalTo(weatherImageView.snp.trailing).offset(8)
        }
    }
}
