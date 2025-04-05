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
    
    func configureView(_ data: WeatherLocationEntity) {
        weatherImageView.image = UIImage(systemName: data.symbolName)
        locationLabel.text = data.city + " " + data.district
        weatherLabel.text = data.description + " " + data.temperature
    }
    
    private func configureView() {
        weatherImageView.contentMode = .scaleAspectFill
        weatherImageView.tintColor = .textPrimary
        
        locationLabel.textColor = .textPrimary
        locationLabel.font = .bodyBold
        
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
        self.snp.makeConstraints {
            $0.width.equalTo(300)
            $0.height.equalTo(44)
        }
        
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
