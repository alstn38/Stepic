//
//  WalkInfoView.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

import SnapKit

final class WalkInfoView: UIView {
    
    private let title = UILabel()
    
    private let weatherView = UIView()
    private let weatherIconImageView = UIImageView()
    private let weatherStatusLabel = UILabel()
    private let weatherTemperatureLabel = UILabel()
    private let weatherTitleLabel = UILabel()
    
    private let locationView = UIView()
    private let locationLineView = UIView()
    private let startLocationLabel = UILabel()
    private let startCityLabel = UILabel()
    private let startCityTitleLabel = UILabel()
    private let arrivalLocationLabel = UILabel()
    private let arrivalCityLabel = UILabel()
    private let arrivalCityTitleLabel = UILabel()
    
    private let timeView = UIView()
    private let timeLineView = UIView()
    private let startTimeLabel = UILabel()
    private let startTimeTitleLabel = UILabel()
    private let arrivalTimeLabel = UILabel()
    private let arrivalTimeTitleLabel = UILabel()
    private let durationTimeLabel = UILabel()
    private let durationTimeTitleLabel = UILabel()
    private let distanceLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private let todayDateLabel = UILabel()
    
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
        
        weatherIconImageView.image = UIImage(systemName: "sun.max") // TODO: 이후삭제
        weatherStatusLabel.text = "맑음" // TODO: 이후 삭제
        weatherTemperatureLabel.text = "7°C" // TODO: 이후 삭제
        startLocationLabel.text = "광진구 능동로" // TODO: 이후 삭제
        startCityLabel.text = "서울특별시" // TODO: 이후 삭제
        arrivalLocationLabel.text = "강남구 테헤란로" // TODO: 이후 삭제
        arrivalCityLabel.text = "서울특별시" // TODO: 이후 삭제
        startTimeLabel.text = "오후 11시 15분" // TODO: 이후 삭제
        arrivalTimeLabel.text = "오전 2시 15분" // TODO: 이후 삭제
        durationTimeLabel.text = "1시간 45분 23초" // TODO: 이후 삭제
        distanceLabel.text = "8.23km" // TODO: 이후 삭제
        todayDateLabel.text = "2025년 3월 15일 화요일" // TODO: 이후 삭제
        
        title.text = .StringLiterals.Detail.walkInfoTitle
        weatherTitleLabel.text = .StringLiterals.Detail.weatherTitle
        startCityTitleLabel.text = .StringLiterals.Detail.startingPointTitle
        arrivalCityTitleLabel.text = .StringLiterals.Detail.endingPointTitle
        startTimeTitleLabel.text = .StringLiterals.Detail.startTimeTitle
        arrivalTimeTitleLabel.text = .StringLiterals.Detail.endTimeTitle
        durationTimeTitleLabel.text = .StringLiterals.Detail.durationTimeTitle
        distanceTitleLabel.text = .StringLiterals.Detail.distanceTitle
        
        title.textColor = .textPrimary
        title.font = .titleLarge
        
        weatherIconImageView.tintColor = .textPrimary
        weatherIconImageView.contentMode = .scaleAspectFill
        
        [weatherView, locationView, timeView].forEach {
            $0.backgroundColor = .backgroundSecondary
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        [locationLineView, timeLineView].forEach {
            $0.backgroundColor = .textPlaceholder
        }
        
        [weatherStatusLabel, startTimeLabel, arrivalTimeLabel,
         durationTimeLabel, distanceLabel].forEach {
            $0.textColor = .textPrimary
            $0.font = .bodyBold
        }
        
        [startLocationLabel, arrivalLocationLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .textPrimary
            $0.font = .bodyBold
        }
        
        [weatherTemperatureLabel, startCityLabel, arrivalCityLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .textPrimary
            $0.font = .captionRegular
        }
        
        [weatherTitleLabel, startCityTitleLabel, arrivalCityTitleLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .textSecondary
            $0.font = .captionRegular
        }
        
        [startTimeTitleLabel, arrivalTimeTitleLabel,
         durationTimeTitleLabel, distanceTitleLabel, todayDateLabel].forEach {
            $0.textColor = .textSecondary
            $0.font = .captionRegular
        }
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            title,
            weatherView,
            weatherIconImageView,
            weatherStatusLabel,
            weatherTemperatureLabel,
            weatherTitleLabel,
            locationView,
            locationLineView,
            startLocationLabel,
            startCityLabel,
            startCityTitleLabel,
            arrivalLocationLabel,
            arrivalCityLabel,
            arrivalCityTitleLabel,
            timeView,
            timeLineView,
            startTimeLabel,
            startTimeTitleLabel,
            arrivalTimeLabel,
            arrivalTimeTitleLabel,
            durationTimeLabel,
            durationTimeTitleLabel,
            distanceLabel,
            distanceTitleLabel,
            todayDateLabel
        )
    }
    
    private func configureLayout() {
        let screenWidth: CGFloat = self.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
        }
        
        weatherView.snp.makeConstraints {
            let size = (screenWidth - (22 * 2)) * 0.28
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(22)
            $0.size.equalTo(size)
        }
        
        weatherIconImageView.snp.makeConstraints {
            $0.top.equalTo(weatherView).offset(22.adjustedHeight)
            $0.leading.equalTo(weatherView).offset(14.adjustedWidth)
            $0.size.equalTo(32)
        }
        
        weatherStatusLabel.snp.makeConstraints {
            $0.top.equalTo(weatherIconImageView)
            $0.leading.equalTo(weatherIconImageView.snp.trailing).offset(8)
        }
        
        weatherTemperatureLabel.snp.makeConstraints {
            $0.bottom.equalTo(weatherIconImageView)
            $0.leading.equalTo(weatherIconImageView.snp.trailing).offset(8)
        }
        
        weatherTitleLabel.snp.makeConstraints {
            $0.centerX.equalTo(weatherView)
            $0.bottom.equalTo(weatherView).inset(15.adjustedHeight)
        }
        
        locationView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.leading.equalTo(weatherView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(weatherView)
        }
        
        locationLineView.snp.makeConstraints {
            $0.centerX.equalTo(locationView)
            $0.width.equalTo(1)
            $0.verticalEdges.equalTo(locationView).inset(11)
        }
        
        startLocationLabel.snp.makeConstraints {
            $0.top.equalTo(locationView).offset(22.adjustedHeight)
            $0.centerX.equalTo(locationLineView.snp.leading).offset(60.adjustedWidth)
        }
        
        startCityLabel.snp.makeConstraints {
            $0.top.equalTo(startLocationLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(startLocationLabel)
        }
        
        startCityTitleLabel.snp.makeConstraints {
            $0.centerX.equalTo(startLocationLabel)
            $0.bottom.equalTo(locationView).inset(15.adjustedHeight)
        }
        
        arrivalLocationLabel.snp.makeConstraints {
            $0.top.equalTo(locationView).offset(22.adjustedHeight)
            $0.centerX.equalTo(locationLineView.snp.trailing).inset(60.adjustedWidth)
        }
        
        arrivalCityLabel.snp.makeConstraints {
            $0.top.equalTo(arrivalLocationLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(arrivalLocationLabel)
        }
        
        arrivalCityTitleLabel.snp.makeConstraints {
            $0.centerX.equalTo(arrivalLocationLabel)
            $0.bottom.equalTo(locationView).inset(15.adjustedHeight)
        }
        
        timeView.snp.makeConstraints {
            $0.top.equalTo(weatherView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(161)
            $0.bottom.equalToSuperview()
        }
        
        timeLineView.snp.makeConstraints {
            $0.bottom.equalTo(timeView).inset(33)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalTo(timeView).inset(4)
        }
        
        startTimeLabel.snp.makeConstraints {
            $0.top.equalTo(timeView).offset(20)
            $0.leading.equalTo(timeView).offset(22)
        }
        
        startTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(startTimeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeView).offset(22)
        }
        
        arrivalTimeLabel.snp.makeConstraints {
            $0.top.equalTo(timeView).offset(20)
            $0.leading.equalTo(timeView.snp.centerX)
        }
        
        arrivalTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(arrivalTimeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeView.snp.centerX)
        }
        
        durationTimeLabel.snp.makeConstraints {
            $0.top.equalTo(startTimeTitleLabel.snp.bottom).offset(22)
            $0.leading.equalTo(timeView).offset(22)
        }
        
        durationTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(durationTimeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeView).offset(22)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(arrivalTimeTitleLabel.snp.bottom).offset(22)
            $0.leading.equalTo(timeView.snp.centerX)
        }
        
        distanceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeView.snp.centerX)
        }
        
        todayDateLabel.snp.makeConstraints {
            $0.top.equalTo(timeLineView.snp.bottom).offset(10)
            $0.leading.equalTo(timeView).offset(22)
        }
    }
}
