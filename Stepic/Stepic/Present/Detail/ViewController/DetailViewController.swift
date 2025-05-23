//
//  DetailViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

import RxCocoa
import RxDataSources
import RxGesture
import RxSwift
import SnapKit
import YPImagePicker

final class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let photoDidDeleteRelay = PublishRelay<Int>()
    private let cameraActionDidTap = PublishRelay<Void>()
    private let libraryActionDidTap = PublishRelay<Void>()
    private let deleteButtonDidTapRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<DetailPhotoSection>(
        configureCell: { [weak self] _, collectionView, indexPath, item in
            switch item {
            case .photo(let data, let viewMode):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailPictureCollectionViewCell.identifier,
                    for: indexPath
                ) as? DetailPictureCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureView(data, viewMode: viewMode)
                cell.deleteButton.rx.tap
                    .map { indexPath.item }
                    .bind { [weak self] index in
                        self?.photoDidDeleteRelay.accept(index)
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell

            case .addPlaceholder:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailAddPictureCollectionViewCell.identifier,
                    for: indexPath
                ) as? DetailAddPictureCollectionViewCell else { return UICollectionViewCell() }
                cell.addPictureButton.rx.tap
                    .bind { [weak self] _ in
                        self?.presentActionSheet()
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        }
    )
    
    private let moreButton = UIBarButtonItem()
    private let bookMarkButton = UIBarButtonItem()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let walkInfoView = WalkInfoView()
    private let pictureSelectView = PictureSelectView()
    private let recordView = RecordView()
    private let routeView = RouteView()
    private let recordButton = UIButton(type: .system)
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
        configureBind()
    }
    
    private func configureBind() {
        let didAddPhotoRelay = PublishRelay<[WalkPhotoEntity]>()
        let saveButtonDidTapRelay = PublishRelay<Void>()
        
        let input = DetailViewModel.Input(
            viewDidLoad: Observable.just(()),
            bookMarkButtonDidTap: bookMarkButton.rx.tap.asObservable(),
            deleteButtonDidTap: deleteButtonDidTapRelay.asObservable(),
            photoDidDelete: photoDidDeleteRelay.asObservable(),
            photoDidAdd: didAddPhotoRelay.asObservable(),
            cameraActionDidTap: cameraActionDidTap.asObservable(),
            libraryActionDidTap: libraryActionDidTap.asObservable(),
            emotionDidSelect: recordView.emotionButtonDidTap.asObservable(),
            titleDidChange: recordView.titleTextField.rx.text.orEmpty.asObservable(),
            contentDidChange: recordView.contentTextView.rx.text.orEmpty.asObservable(),
            routeViewDidUpdate: routeView.mapViewDidCapture,
            recordButtonDidTap: saveButtonDidTapRelay.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.viewMode
            .drive(with: self) { owner, viewMode in
                switch viewMode {
                case .create:
                    Tracking.logScreen(name: Tracking.Screen.walkRecord, from: self)
                    break
                case .viewer:
                    Tracking.logScreen(name: Tracking.Screen.walkDetail, from: self)
                    owner.recordView.configureViewerMode()
                    owner.recordButton.isHidden = true
                    owner.navigationItem.rightBarButtonItems?.insert(owner.moreButton, at: 0)
                }
            }
            .disposed(by: disposeBag)
        
        output.walkDiaryEntity
            .compactMap { $0 }
            .drive(with: self) { owner, walkDiary in
                let walkRecord = WalkRecordInfoEntity(
                    emotion: EmotionTypeEntity(rawValue: walkDiary.emotion),
                    title: walkDiary.recordTitle,
                    content: walkDiary.content ?? ""
                )
                owner.recordView.configureView(walkRecord)
            }
            .disposed(by: disposeBag)
        
        output.bookMarkState
            .drive(with: self) { owner, isSelected in
                let image: UIImage = isSelected ? .bookmarkFill : .bookmark
                owner.bookMarkButton.image = image
            }
            .disposed(by: disposeBag)
        
        output.walkResultData
            .drive(with: self) { owner, data in
                owner.walkInfoView.configureView(data)
                owner.routeView.configureView(with: data.tracking.pathCoordinates)
            }
            .disposed(by: disposeBag)
        
        output.photoData
            .drive(with: self) { owner, photos in
                owner.routeView.configureView(with: photos)
            }
            .disposed(by: disposeBag)
        
        output.photoData
            .withLatestFrom(output.viewMode) { ($0, $1) }
            .map { [weak self] data, viewMode in
                var items = data.map { DetailPhotoItem.photo($0, viewMode: viewMode) }
                
                if case .create = viewMode {
                    if items.count < 10 { items.append(.addPlaceholder) }
                } else if case .viewer = viewMode {
                    if items.isEmpty { self?.hiddenPictureSelectView() }
                }
                
                return [DetailPhotoSection(items: items)]
            }
            .drive(pictureSelectView.pictureCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.presentPickerView
            .drive(with: self) { owner, source in
                owner.presentImagePicker(source: source) { selectPhotos in
                    didAddPhotoRelay.accept(selectPhotos)
                }
            }
            .disposed(by: disposeBag)
        
        output.presentAlert
            .drive(with: self) { owner, alert in
                let (title, message) = alert
                owner.presentWarningAlert(title: title, message: message)
            }
            .disposed(by: disposeBag)
        
        output.dismissToRoot
            .drive(with: self) { owner, _ in
                owner.dismissToRoot()
            }
            .disposed(by: disposeBag)
        
        output.popToRoot
            .drive(with: self) { owner, _ in
                owner.presentGenericAlert(
                    title: .StringLiterals.Alert.deleteActionTitle,
                    message: .StringLiterals.Alert.deleteSuccessMessage
                ) {
                    owner.navigationController?.popToRootViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        /// View 전용 내부 로직
        contentView.rx.tapGesture()
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        recordView.textDidEditing
            .bind(with: self) { owner, _ in
                owner.scrollToRecordView()
            }
            .disposed(by: disposeBag)
        
        recordButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentSaveConfirmationAlert(
                    title: .StringLiterals.Detail.endWalkButton,
                    message: .StringLiterals.Alert.walkSaveWarningMessage
                ) {
                    saveButtonDidTapRelay.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentMoreActionSheet()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        bookMarkButton.tintColor = .textPrimary
        navigationItem.rightBarButtonItems = [bookMarkButton]
        
        moreButton.image = .ellipsis
        moreButton.tintColor = .textPrimary
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        scrollView.showsVerticalScrollIndicator = false
        
        recordButton.configuration = configureMainButtonButtonConfiguration(title: .StringLiterals.Detail.endWalkButton)
        recordButton.layer.cornerRadius = 10
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            walkInfoView,
            pictureSelectView,
            recordView,
            routeView,
            recordButton
        )
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        walkInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview()
        }
        
        pictureSelectView.snp.makeConstraints {
            $0.top.equalTo(walkInfoView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        recordView.snp.makeConstraints {
            $0.top.equalTo(pictureSelectView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        routeView.snp.makeConstraints {
            $0.top.equalTo(recordView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(routeView.snp.bottom).offset(76)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(54)
        }
    }
    
    private func presentActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(
            title: .StringLiterals.Alert.photoActionCamera,
            style: .default
        ) { [weak self] _ in
            self?.cameraActionDidTap.accept(())
        }
        
        let libraryAction = UIAlertAction(
            title: .StringLiterals.Alert.photoActionLibrary,
            style: .default
        ) { [weak self] _ in
            self?.libraryActionDidTap.accept(())
        }

        let cancelAction = UIAlertAction(
            title: .StringLiterals.Alert.locationAlertCancel,
            style: .cancel
        )

        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func presentMoreActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(
            title: .StringLiterals.Alert.deleteActionTitle,
            style: .destructive
        ) { [weak self] _ in
            self?.presentGenericCancelAlert(
                title: .StringLiterals.Alert.deleteAlertTitle,
                message: .StringLiterals.Alert.deleteAlertMessage
            ) { [weak self] in
                self?.deleteButtonDidTapRelay.accept(())
            }
        }

        let cancelAction = UIAlertAction(
            title: .StringLiterals.Alert.locationAlertCancel,
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func presentImagePicker(source: DetailViewModel.ImagePickerSource, onResult: @escaping ([WalkPhotoEntity]) -> Void) {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.showsPhotoFilters = false
        config.library.preSelectItemOnMultipleSelection = false
        config.library.defaultMultipleSelection = true
        config.onlySquareImagesFromCamera = false
        config.showsPhotoFilters = true
        
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
    
    private func hiddenPictureSelectView() {
        self.pictureSelectView.snp.remakeConstraints {
            $0.top.equalTo(self.walkInfoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)
        }
        self.pictureSelectView.alpha = 0
        self.view.layoutIfNeeded()
    }
    
    private func scrollToRecordView() {
        let visibleTopY = scrollView.contentOffset.y
        let recordTopY = recordView.convert(CGPoint.zero, to: scrollView).y - 20
        
        guard visibleTopY < recordTopY else { return }
        
        scrollView.setContentOffset(
            CGPoint(x: 0, y: recordTopY),
            animated: true
        )
    }
}
