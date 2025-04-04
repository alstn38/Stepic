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
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<DetailPhotoSection>(
        configureCell: { [weak self] _, collectionView, indexPath, item in
            switch item {
            case .photo(let data):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailPictureCollectionViewCell.identifier,
                    for: indexPath
                ) as? DetailPictureCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureView(data)
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
        
        configureBind()
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureBind() {
        let didAddPhotoRelay = PublishRelay<[WalkPhotoEntity]>()
        
        let input = DetailViewModel.Input(
            bookMarkButtonDidTap: bookMarkButton.rx.tap.asObservable(),
            photoDidDelete: photoDidDeleteRelay.asObservable(),
            photoDidAdd: didAddPhotoRelay.asObservable(),
            cameraActionDidTap: cameraActionDidTap.asObservable(),
            libraryActionDidTap: libraryActionDidTap.asObservable(),
            emotionDidSelect: recordView.emotionButtonDidTap.asObservable(),
            titleDidChange: recordView.titleTextField.rx.text.orEmpty.asObservable(),
            contentDidChange: recordView.contentTextView.rx.text.orEmpty.asObservable(),
            routeViewDidUpdate: routeView.mapViewDidCapture,
            recordButtonDidTap: recordButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
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
            .map { data in
                var items = data.map { DetailPhotoItem.photo($0) }
                if items.count < 10 {
                    items.append(.addPlaceholder)
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
    }
    
    private func configureNavigation() {
        bookMarkButton.image = .bookmark
        bookMarkButton.tintColor = .textPrimary
        
        navigationItem.rightBarButtonItem = bookMarkButton
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
    
    private func presentImagePicker(source: DetailViewModel.ImagePickerSource, onResult: @escaping ([WalkPhotoEntity]) -> Void) {
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
