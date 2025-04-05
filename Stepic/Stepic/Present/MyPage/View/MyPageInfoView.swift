//
//  MyPageInfoView.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import SnapKit

final class MyPageInfoView: UIView {
    
    private let calendarTitleLabel = UILabel()
    let calendarButton = UIButton()
    
    private let timeView = UIView()
    private let timeImageView = UIImageView()
    private let timeTitleLabel = UILabel()
    private let timeDescriptionLabel = UILabel()
    
    private let walkView = UIView()
    private let walkImageView = UIImageView()
    private let walkTitleLabel = UILabel()
    private let walkDescriptionLabel = UILabel()
    
    private let recordView = UIView()
    private let recordLeftLineView = UIView()
    private let recordRightLineView = UIView()
    let totalWalkButton = PageInfoButtonView(image: .squareGrid, title: .StringLiterals.MyPage.allWalkTitle)
    let monthWalkButton = PageInfoButtonView(image: .calendar, title: .StringLiterals.MyPage.monthWalkTitle)
    let bookmarkButton = PageInfoButtonView(image: .bookmarkFill, title: .StringLiterals.MyPage.boomMarkTitle)
    
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
    
    func configureView(_ yearMonth: YearMonth) {
        let calendarTitle = DateFormatManager.shared.selectMonthTitle(
            year: yearMonth.year,
            month: yearMonth.month
        )
        
        calendarTitleLabel.text = calendarTitle
    }
    
    func configureView(_ data: MyPageInfoViewItem) {
        timeDescriptionLabel.text = DateFormatManager.shared.formattedDurationTime(from: data.totalTime)
        walkDescriptionLabel.text = String(format: "%.2fkm", data.totalDistance)
        
        let totalCountString = String(data.totalWalkCount) + .StringLiterals.MyPage.walkCountFormat
        let monthCountString = String(data.monthWalkCount) + .StringLiterals.MyPage.walkCountFormat
        let bookMarkCountString = String(data.bookMarkWalkCount) + .StringLiterals.MyPage.walkCountFormat
        
        totalWalkButton.configureView(subTitle: totalCountString)
        monthWalkButton.configureView(subTitle: monthCountString)
        bookmarkButton.configureView(subTitle: bookMarkCountString)
    }
    
    private func configureView() {
        calendarTitleLabel.textColor = .textPrimary
        calendarTitleLabel.font = .titleLarge
        
        calendarButton.configuration = configureCalendarButtonConfiguration()
        
        [timeView, walkView, recordView].forEach {
            $0.backgroundColor = .backgroundSecondary
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        [recordLeftLineView, recordRightLineView].forEach {
            $0.backgroundColor = .textPlaceholder
        }
        
        timeImageView.image = .timer
        timeImageView.tintColor = .textPrimary
        timeImageView.contentMode = .scaleAspectFit
        
        timeTitleLabel.text = .StringLiterals.MyPage.totalTimeTitle
        timeTitleLabel.textColor = .textSecondary
        timeTitleLabel.font = .captionRegular
        
        timeDescriptionLabel.textColor = .textPrimary
        timeDescriptionLabel.font = .bodyBold
        
        walkImageView.image = .figureWalk
        walkImageView.tintColor = .textPrimary
        walkImageView.contentMode = .scaleAspectFit
        
        walkTitleLabel.text = .StringLiterals.MyPage.totalDistanceTitle
        walkTitleLabel.textColor = .textSecondary
        walkTitleLabel.font = .captionRegular
        
        walkDescriptionLabel.textColor = .textPrimary
        walkDescriptionLabel.font = .bodyBold
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            calendarTitleLabel,
            calendarButton,
            timeView,
            timeImageView,
            timeTitleLabel,
            timeDescriptionLabel,
            walkView,
            walkImageView,
            walkTitleLabel,
            walkDescriptionLabel,
            recordView,
            recordLeftLineView,
            recordRightLineView,
            totalWalkButton,
            monthWalkButton,
            bookmarkButton
        )
    }
    
    private func configureLayout() {
        calendarTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(22)
        }
        
        calendarButton.snp.makeConstraints {
            $0.centerY.equalTo(calendarTitleLabel)
            $0.leading.equalTo(calendarTitleLabel.snp.trailing).offset(6)
            $0.size.equalTo(20)
        }
        
        timeView.snp.makeConstraints {
            $0.top.equalTo(calendarTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalTo(self.snp.centerX).offset(-5)
            $0.height.equalTo(98)
        }
        
        timeImageView.snp.makeConstraints {
            $0.top.equalTo(timeView).offset(12)
            $0.leading.equalTo(timeView).offset(20)
            $0.size.equalTo(33)
        }
        
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(timeImageView.snp.bottom).offset(6)
            $0.leading.equalTo(timeView).offset(20)
        }
        
        timeDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(timeTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeView).offset(20)
        }
        
        walkView.snp.makeConstraints {
            $0.top.equalTo(calendarTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(self.snp.centerX).offset(5)
            $0.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(98)
        }
        
        walkImageView.snp.makeConstraints {
            $0.top.equalTo(walkView).offset(12)
            $0.leading.equalTo(walkView).offset(20)
            $0.size.equalTo(33)
        }
        
        walkTitleLabel.snp.makeConstraints {
            $0.top.equalTo(walkImageView.snp.bottom).offset(6)
            $0.leading.equalTo(walkView).offset(20)
        }
        
        walkDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(walkTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(walkView).offset(20)
        }
        
        recordView.snp.makeConstraints {
            $0.top.equalTo(timeView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(89)
            $0.bottom.equalToSuperview()
        }
        
        let screenWidth: CGFloat = self.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let recordViewWidth = (screenWidth - 22 * 2)
        
        recordLeftLineView.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(23)
            $0.width.equalTo(1)
            $0.leading.equalTo(recordView).offset(recordViewWidth * 1 / 3)
            $0.bottom.equalTo(recordView).inset(10)
        }
        
        recordRightLineView.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(23)
            $0.width.equalTo(1)
            $0.leading.equalTo(recordView).offset(recordViewWidth * 2 / 3)
            $0.bottom.equalTo(recordView).inset(10)
        }
        
        totalWalkButton.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(12)
            $0.leading.equalTo(recordView).offset(18)
            $0.trailing.equalTo(recordLeftLineView).inset(18)
            $0.bottom.equalTo(recordView).inset(12)
        }
        
        monthWalkButton.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(12)
            $0.leading.equalTo(recordLeftLineView).offset(18)
            $0.trailing.equalTo(recordRightLineView).inset(18)
            $0.bottom.equalTo(recordView).inset(12)
        }
        
        bookmarkButton.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(12)
            $0.leading.equalTo(recordRightLineView).offset(18)
            $0.trailing.equalTo(recordView).inset(18)
            $0.bottom.equalTo(recordView).inset(12)
        }
    }
    
    private func configureCalendarButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .chevronDown
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12)
        configuration.baseForegroundColor = .accessoryContent
        
        return configuration
    }
}
