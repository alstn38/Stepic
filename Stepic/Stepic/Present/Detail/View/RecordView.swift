//
//  RecordView.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

enum EmotionType: Int, CaseIterable {
    case love
    case happy
    case neutral
    case tired
    case sad
    case angry
    
    var title: String {
        switch self {
        case .love:
            return .StringLiterals.Detail.loveButtonTitle
        case .happy:
            return .StringLiterals.Detail.happyButtonTitle
        case .neutral:
            return .StringLiterals.Detail.neutralButtonTitle
        case .tired:
            return .StringLiterals.Detail.tiredButtonTitle
        case .sad:
            return .StringLiterals.Detail.sadButtonTitle
        case .angry:
            return .StringLiterals.Detail.angryButtonTitle
        }
    }
    
    var image: UIImage {
        switch self {
        case .love:
            return .loveEmoji
        case .happy:
            return .happyEmoji
        case .neutral:
            return .neutralEmoji
        case .tired:
            return .tiredEmoji
        case .sad:
            return .sadEmoji
        case .angry:
            return .angryEmoji
        }
    }
}

final class RecordView: UIView {
    
    var emotionButtonDidTap: Observable<EmotionType> {
        return emotionButtonRelay.asObservable()
    }
    
    private let emotionButtonRelay = PublishRelay<EmotionType>()
    private let disposeBag = DisposeBag()
    
    private let title = UILabel()
    private let emotionView = UIView()
    private let emotionStackView = UIStackView()
    private var emotionButtonArray = [UIButton]()
    private let recordView = UIView()
    private let recordLineView = UIView()
    private let titleTextField = UITextField()
    private let contentTextViewPlaceholder = UILabel()
    private let contentTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
        configureBind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBind() {
        emotionButtonArray.forEach { button in
            button.rx.tap
                .map { EmotionType(rawValue: button.tag)! }
                .bind(to: emotionButtonRelay)
                .disposed(by: disposeBag)
        }
        
        emotionButtonDidTap
            .bind(with: self) { owner, type in
                owner.emotionButtonArray.forEach {
                    $0.configuration?.baseForegroundColor = .accessoryBackground
                }
                owner.emotionButtonArray[type.rawValue].configuration?.baseForegroundColor = .textPrimary
            }
            .disposed(by: disposeBag)
        
        contentTextView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: contentTextViewPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        title.text = .StringLiterals.Detail.recordTitle
        title.textColor = .textPrimary
        title.font = .titleLarge
        
        [emotionView, recordView].forEach {
            $0.backgroundColor = .backgroundSecondary
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        emotionStackView.axis = .horizontal
        emotionStackView.distribution = .equalSpacing
        
        EmotionType.allCases.forEach { type in
            let button = UIButton()
            button.tag = type.rawValue
            button.configuration = configureButtonConfiguration(
                title: type.title,
                image: type.image
            )
            emotionButtonArray.append(button)
        }
        
        recordLineView.backgroundColor = .textPlaceholder

        titleTextField.tintColor = .textPrimary
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: .StringLiterals.Detail.recordTitlePlaceholder,
            attributes: [
                .foregroundColor: UIColor.textSecondary,
                .font: UIFont.captionBold
            ]
        )
        
        contentTextViewPlaceholder.isHidden = !contentTextView.text.isEmpty
        contentTextViewPlaceholder.text = .StringLiterals.Detail.recordContentPlaceholder
        contentTextViewPlaceholder.textColor = .textSecondary
        contentTextViewPlaceholder.font = .captionRegular
        
        contentTextView.tintColor = .textPrimary
        contentTextView.font = .captionRegular
        contentTextView.textColor = .textPrimary
        contentTextView.backgroundColor = .backgroundSecondary
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            title,
            emotionView,
            emotionStackView,
            recordView,
            recordLineView,
            titleTextField,
            contentTextView,
            contentTextViewPlaceholder
        )
        
        emotionButtonArray.forEach {
            emotionStackView.addArrangedSubview($0)
        }
    }
    
    private func configureLayout() {
        title.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
        }
        
        emotionView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(68)
        }
        
        emotionStackView.snp.makeConstraints {
            $0.top.equalTo(emotionView).offset(12)
            $0.horizontalEdges.equalTo(emotionView)
            $0.bottom.equalTo(emotionView).inset(8)
        }
        
        recordView.snp.makeConstraints {
            $0.top.equalTo(emotionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(180)
            $0.bottom.equalToSuperview()
        }
        
        recordLineView.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(38)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalTo(recordView).inset(4)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(recordView).offset(12)
            $0.horizontalEdges.equalTo(recordView).inset(12)
            $0.bottom.equalTo(recordLineView).inset(4)
        }
        
        contentTextViewPlaceholder.snp.makeConstraints {
            $0.top.equalTo(recordLineView.snp.bottom).offset(11.5)
            $0.leading.equalTo(recordView).offset(12)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(recordLineView.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(recordView).inset(9)
            $0.bottom.equalTo(recordView).inset(4)
        }
    }
    
    private func configureButtonConfiguration(title: String, image: UIImage) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        titleContainer.font = .captionRegular
        configuration.attributedTitle = AttributedString(
            title,
            attributes: titleContainer
        )
        
        let resizedImage = image
            .withRenderingMode(.alwaysTemplate)
            .resize(to: CGSize(width: 30, height: 30))
        
        configuration.image = resizedImage
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30)
        configuration.imagePadding = 4
        configuration.baseForegroundColor = .accessoryBackground
        configuration.imagePlacement = .top
        
        return configuration
    }
}
