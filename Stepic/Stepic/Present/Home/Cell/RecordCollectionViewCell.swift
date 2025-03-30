//
//  RecordCollectionViewCell.swift
//  Stepic
//
//  Created by 강민수 on 3/28/25.
//

import UIKit

import SnapKit

final class RecordCollectionViewCell: UICollectionViewCell, ReusableViewProtocol {
    
    private let imageViewStackView = UIStackView()
    private let walkImageView = UIImageView()
    private let mapImageView = UIImageView()
    private let weatherImageView = UIImageView()
    private let cityNameLabel = UILabel()
    private let weatherLabel = UILabel()
    private let infoStackView = UIStackView()
    private let emotionStackView = UIStackView()
    private let emotionImageView = UIImageView()
    private let emotionTitleLabel = UILabel()
    private let timeStackView = UIStackView()
    private let durationTimeLabel = UILabel()
    private let timeTitleLabel = UILabel()
    private let distanceStackView = UIStackView()
    private let travelDistanceLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private let lineView = UIView()
    private let dateLabel = UILabel()
    
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
        contentView.backgroundColor = .backgroundSecondary
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        imageViewStackView.axis = .horizontal
        imageViewStackView.spacing = 4
        imageViewStackView.alignment = .fill
        imageViewStackView.distribution = .fillEqually
        
        walkImageView.layer.cornerRadius = 10
        walkImageView.clipsToBounds = true
        walkImageView.backgroundColor = .yellow // TODO: 이후 삭제
        
        mapImageView.layer.cornerRadius = 10
        mapImageView.clipsToBounds = true
        mapImageView.backgroundColor = .blue // TODO: 이후 삭제
        
        weatherImageView.image = UIImage(systemName: "sun.max") // TODO: 이후 삭제
        weatherImageView.contentMode = .scaleAspectFill
        weatherImageView.tintColor = .textPrimary
        
        cityNameLabel.text = "서울특별시 광진구" // TODO: 이후 서버 연결
        cityNameLabel.textColor = .textPrimary
        cityNameLabel.font = .titleSmall
        
        weatherLabel.text = "맑음 7°C" // TODO: 이후 서버 연결
        weatherLabel.textColor = .textPrimary
        weatherLabel.font = .captionRegular
        
        infoStackView.axis = .horizontal
        infoStackView.distribution = .equalCentering
        
        emotionStackView.axis = .vertical
        emotionStackView.alignment = .center
        emotionStackView.distribution = .equalCentering
        
        emotionImageView.image = .loveEmoji // TODO: 이후 삭제
        emotionImageView.contentMode = .scaleAspectFill
        emotionImageView.tintColor = .textPrimary
        
        emotionTitleLabel.text = .StringLiterals.Home.emotionTitle
        emotionTitleLabel.textColor = .textSecondary
        emotionTitleLabel.font = .captionRegular
        
        timeStackView.axis = .vertical
        timeStackView.alignment = .center
        timeStackView.distribution = .equalCentering
        
        durationTimeLabel.text = "16:23" // TODO: 이후 삭제
        durationTimeLabel.textColor = .textPrimary
        durationTimeLabel.font = .titleMedium
        
        timeTitleLabel.text = .StringLiterals.Home.timeTitle
        timeTitleLabel.textColor = .textSecondary
        timeTitleLabel.font = .captionRegular
        
        distanceStackView.axis = .vertical
        distanceStackView.alignment = .center
        distanceStackView.distribution = .equalCentering
        
        travelDistanceLabel.text = "3.21km" // TODO: 이후 삭제
        travelDistanceLabel.textColor = .textPrimary
        travelDistanceLabel.font = .titleMedium
        
        distanceTitleLabel.text = .StringLiterals.Home.distanceTitle
        distanceTitleLabel.textColor = .textSecondary
        distanceTitleLabel.font = .captionRegular
        
        lineView.backgroundColor = .textPlaceholder
        
        dateLabel.text = "2025년 3월 18일 화요일" // TODO: 이후 삭제
        dateLabel.textColor = .textSecondary
        dateLabel.font = .captionRegular
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            imageViewStackView,
            weatherImageView,
            cityNameLabel,
            weatherLabel,
            infoStackView,
            lineView,
            dateLabel
        )
        
        imageViewStackView.addArrangedSubviews(
            walkImageView,
            mapImageView
        )
        
        infoStackView.addArrangedSubviews(
            emotionStackView,
            timeStackView,
            distanceStackView
        )
        
        emotionStackView.addArrangedSubviews(
            emotionImageView,
            emotionTitleLabel
        )
        
        timeStackView.addArrangedSubviews(
            durationTimeLabel,
            timeTitleLabel
        )
        
        distanceStackView.addArrangedSubviews(
            travelDistanceLabel,
            distanceTitleLabel
        )
    }
    
    private func configureLayout() {
        imageViewStackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(4)
            $0.height.equalTo(imageViewStackView.snp.width).multipliedBy(0.5).offset(-2)
        }
        
        weatherImageView.snp.makeConstraints {
            $0.top.equalTo(imageViewStackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(32)
        }
        
        cityNameLabel.snp.makeConstraints {
            $0.top.equalTo(weatherImageView)
            $0.leading.equalTo(weatherImageView.snp.trailing).offset(8)
        }
        
        weatherLabel.snp.makeConstraints {
            $0.bottom.equalTo(weatherImageView)
            $0.leading.equalTo(weatherImageView.snp.trailing).offset(8)
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(weatherImageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.height.equalTo(45)
        }
        
        emotionImageView.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalTo(contentView).inset(10)
        }
    }
}
