//
//  WalkSummaryCollectionViewCell.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import UIKit

import SnapKit

final class WalkSummaryCollectionViewCell: UICollectionViewCell, ReusableViewProtocol {
    
    private let monthLabel = UILabel()
    private let dayLabel = UILabel()
    
    private let cellInfoView = UIView()
    private let imageViewStackView = UIStackView()
    private let walkImageView = UIImageView()
    private let mapImageView = UIImageView()
    private let weatherImageView = UIImageView()
    private let cityNameLabel = UILabel()
    private let weatherLabel = UILabel()
    let bookmarkButton = UIButton()
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
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let lineView = UIView()
    
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
        
        bookmarkButton.configuration = configureButtonConfiguration()
        
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
        
        titleLabel.text = "제목을 말합니다" // TODO: 이후 삭제
        titleLabel.textColor = .textPrimary
        titleLabel.font = .captionBold
        titleLabel.numberOfLines = 1
        
        contentLabel.text = "길게쓰는\n말이아무거나일단\n두줄이나와야하기때문\n에나은" // TODO: 이후 삭제
        contentLabel.textColor = .textPrimary
        contentLabel.font = .captionRegular
        contentLabel.numberOfLines = 2
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            monthLabel,
            dayLabel,
            cellInfoView
        )
        
        cellInfoView.addSubviews(
            imageViewStackView,
            weatherImageView,
            cityNameLabel,
            weatherLabel,
            bookmarkButton,
            infoStackView,
            titleLabel,
            contentLabel,
            lineView
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
        monthLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalTo(contentView.snp.leading).offset(40)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(monthLabel)
        }
        
        cellInfoView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(73)
        }
        
        imageViewStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
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
        
        bookmarkButton.snp.makeConstraints {
            $0.centerY.equalTo(weatherImageView)
            $0.trailing.equalToSuperview().inset(18)
            $0.size.equalTo(20)
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(weatherImageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.height.equalTo(45)
        }
        
        emotionImageView.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(24)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
    }
    
    private func configureButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .bookmark
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18)
        configuration.baseForegroundColor = .textPrimary
        
        return configuration
    }
}
