//
//  WalkViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit
import Photos

import Lottie
import RxCocoa
import RxDataSources
import RxGesture
import RxSwift
import SnapKit
import YPImagePicker

final class WalkViewController: UIViewController {
    
    private let viewModel: WalkViewModel
    private let photoDidDeleteRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<WalkPictureSection>(
        configureCell: { [weak self] _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalkPictureCollectionViewCell.identifier,
                for: indexPath
            ) as? WalkPictureCollectionViewCell else { return UICollectionViewCell() }
            
            cell.deleteButton.rx.tap
                .map { indexPath.item }
                .bind { [weak self] index in
                    self?.photoDidDeleteRelay.accept(index)
                }
                .disposed(by: cell.disposeBag)
            
            cell.configureView(item)
            return cell
        }
    )
    
    private let weatherView = WeatherView()
    private let countDownView = CountDownView()
    private let durationStackView = UIStackView()
    private let durationTimeLabel = UILabel()
    private let timeTitleLabel = UILabel()
    private let durationDistanceLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private lazy var pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
    private let walkAnimationView = LottieAnimationView(name: "walkLight")
    private let albumButtonView = WalkButtonView(longGesture: false, buttonImage: .photo)
    private let pauseButtonView = WalkButtonView(longGesture: true, buttonImage: .squareFill)
    private let cameraButtonView = WalkButtonView(longGesture: false, buttonImage: .camera)
    
    init(viewModel: WalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBind()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureBind() {
        let startTrigger = PublishRelay<Void>()
        let didAddPhotoRelay = PublishRelay<[WalkPhotoEntity]>()
        
        let input = WalkViewModel.Input(
            viewDidLoad: Observable.just(()),
            startTrigger: startTrigger.asObservable(),
            albumButtonDidTap: albumButtonView.rx.tapGesture().map { _ in }.asObservable(),
            photoButtonDidTap: cameraButtonView.rx.tapGesture().map { _ in }.asObservable(),
            pauseButtonLongDidPress: pauseButtonView.longTapGesture.asObservable(),
            didAddPhoto: didAddPhotoRelay.asObservable(),
            deletePhoto: photoDidDeleteRelay.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.weatherLocationData
            .drive(with: self) { owner, data in
                owner.weatherView.configureView(data)
            }
            .disposed(by: disposeBag)
        
        output.timer
            .drive(durationTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.distance
            .drive(durationDistanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.walkPhotoData
            .map { [WalkPictureSection.main(items: $0)] }
            .drive(pictureCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
            
        output.presentPickerView
            .drive(with: self) { owner, source in
                owner.presentImagePicker(source: source) { selectPhotos in
                    didAddPhotoRelay.accept(selectPhotos)
                }
            }
            .disposed(by: disposeBag)
        
        output.moveToSummaryView
            .drive(with: self) { owner, walkResult in
                let viewModel = DetailViewModel(walkResultData: walkResult)
                let viewController = DetailViewController(viewModel: viewModel)
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.modalPresentationStyle = .overFullScreen
                navigationController.modalTransitionStyle = .crossDissolve
                owner.present(navigationController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.presentAlert
            .drive(with: self) { owner, alertType in
                switch alertType {
                case .messageError(let title, let message):
                    owner.presentWarningAlert(title: title, message: message)
                case .locationSetting:
                    owner.presentToSettingAppWithLocation()
                }
            }
            .disposed(by: disposeBag)
        
        countDownView.startAnimation {
            startTrigger.accept(())
        }
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundRunning
        
        durationStackView.axis = .horizontal
        durationStackView.distribution = .equalCentering
        
        durationTimeLabel.textColor = .textPrimary
        durationTimeLabel.font = .titleExtraLarge
        
        timeTitleLabel.text = .StringLiterals.Walk.timeTitle
        timeTitleLabel.textColor = .textPrimary
        timeTitleLabel.font = .mediumRegular
        
        durationDistanceLabel.textColor = .textPrimary
        durationDistanceLabel.font = .titleExtraLarge
        
        distanceTitleLabel.text = .StringLiterals.Walk.distanceTitle
        distanceTitleLabel.textColor = .textPrimary
        distanceTitleLabel.font = .mediumRegular
        
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.register(
            WalkPictureCollectionViewCell.self,
            forCellWithReuseIdentifier: WalkPictureCollectionViewCell.identifier
        )
        
        walkAnimationView.loopMode = .loop
        walkAnimationView.play()
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            weatherView,
            durationStackView,
            timeTitleLabel,
            distanceTitleLabel,
            pictureCollectionView,
            walkAnimationView,
            albumButtonView,
            pauseButtonView,
            cameraButtonView
        )
        
        durationStackView.addArrangedSubviews(
            durationTimeLabel,
            durationDistanceLabel
        )
        
        view.addSubview(countDownView)
    }
    
    private func configureLayout() {
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        
        countDownView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        weatherView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        durationStackView.snp.makeConstraints {
            $0.top.equalTo(weatherView.snp.bottom).offset(44)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(durationTimeLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(durationTimeLabel)
        }
        
        distanceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(durationDistanceLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(durationDistanceLabel)
        }
        
        pictureCollectionView.snp.makeConstraints {
            $0.top.equalTo(distanceTitleLabel.snp.bottom).offset(86.adjustedHeight)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(screenWidth - 120)
        }
        
        walkAnimationView.snp.makeConstraints {
            $0.centerY.equalTo(pauseButtonView.snp.top).offset(-80.adjustedHeight)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(150)
            $0.width.equalTo(200)
        }
        
        albumButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.leading.equalToSuperview().offset((screenWidth - 156) / 4)
        }
        
        pauseButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        cameraButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.trailing.equalToSuperview().inset((screenWidth - 156) / 4)
        }
    }
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout {
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let spacing: CGFloat = 65
        let cellLength: CGFloat = screenWidth - (spacing * 2)
        
        let layout = CarouselLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: cellLength, height: cellLength)
        layout.sectionInset = UIEdgeInsets(top: .zero, left: spacing, bottom: .zero, right: spacing)
        
        return layout
    }
    
    private func presentImagePicker(source: WalkViewModel.ImagePickerSource, onResult: @escaping ([WalkPhotoEntity]) -> Void) {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.showsPhotoFilters = false
        config.library.preSelectItemOnMultipleSelection = false
        config.library.defaultMultipleSelection = true
        config.onlySquareImagesFromCamera = false
        
        switch source {
        case .library(let maxCount):
            config.library.maxNumberOfItems = maxCount
            config.startOnScreen = .library
            config.screens = [.library]
        case .camera(let maxCount):
            config.library.maxNumberOfItems = maxCount
            config.startOnScreen = .photo
            config.screens = [.photo]
        }
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { items, _ in
            var walkPhotos: [WalkPhotoEntity] = []
            
            for item in items {
                switch item {
                case .photo(let photo):
                    let image = photo.image
                    let location = photo.asset?.location
                    
                    walkPhotos.append(WalkPhotoEntity(image: image, location: location))
                    
                default:
                    break
                }
            }
            
            onResult(walkPhotos)
            picker.dismiss(animated: true)
        }
        
        self.present(picker, animated: true)
    }
}
