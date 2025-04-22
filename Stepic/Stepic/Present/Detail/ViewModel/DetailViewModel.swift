//
//  DetailViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import UIKit

import RxSwift
import RxCocoa

final class DetailViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let bookMarkButtonDidTap: Observable<Void>
        let deleteButtonDidTap: Observable<Void>
        let photoDidDelete: Observable<Int>
        let photoDidAdd: Observable<[WalkPhotoEntity]>
        let cameraActionDidTap: Observable<Void>
        let libraryActionDidTap: Observable<Void>
        let emotionDidSelect: Observable<EmotionTypeEntity>
        let titleDidChange: Observable<String>
        let contentDidChange: Observable<String>
        let routeViewDidUpdate: Observable<UIImage>
        let recordButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let viewMode: Driver<DetailViewType>
        let walkDiaryEntity: Driver<WalkDiaryEntity?>
        let bookMarkState: Driver<Bool>
        let walkResultData: Driver<WalkResultEntity>
        let photoData: Driver<[WalkPhotoEntity]>
        let presentPickerView: Driver<ImagePickerSource>
        let presentAlert: Driver<(title: String, message: String)>
        let dismissToRoot: Driver<Void>
        let popToRoot: Driver<Void>
    }
    
    private let detailViewType: DetailViewType
    private let walkRecordRepository: WalkRecordRepository
    private let weatherLocationRepository: WeatherLocationRepository
    
    private let maxPhotoCount: Int = 10
    private var walkDiaryEntity: WalkDiaryEntity?
    private let bookMarkStateRelay = BehaviorRelay<Bool>(value: false)
    private let walkResultDataRelay = BehaviorRelay<WalkResultEntity>(value: .dummy())
    private let photoDataRelay = BehaviorRelay<[WalkPhotoEntity]>(value: [])
    
    private var walkRecordInfoData = WalkRecordInfoEntity()
    private var routeViewImage: UIImage?
    private let disposeBag = DisposeBag()
    
    init(
        detailViewType: DetailViewType,
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self),
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self)
    ) {
        self.detailViewType = detailViewType
        self.walkRecordRepository = walkRecordRepository
        self.weatherLocationRepository = weatherLocationRepository
    }
    
    func transform(from input: Input) -> Output {
        let presentPickerViewRelay = PublishRelay<ImagePickerSource>()
        let presentAlertRelay = PublishRelay<(title: String, message: String)>()
        let dismissToRootRelay = PublishRelay<Void>()
        let popToRootRelay = PublishRelay<Void>()
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                switch owner.detailViewType {
                case .create(let walkResult, let walkPhotos):
                    owner.walkResultDataRelay.accept(walkResult)
                    owner.photoDataRelay.accept(walkPhotos)
                    
                case .viewer(let walkDiary):
                    do {
                        let originalData = try owner.walkRecordRepository.fetch(by: walkDiary.id)
                        let walkResult = owner.mapperWalkResultEntity(originalData)
                        owner.walkResultDataRelay.accept(walkResult)
                        owner.photoDataRelay.accept(originalData.photos)
                        owner.bookMarkStateRelay.accept(originalData.isBookmarked)
                        owner.walkDiaryEntity = originalData
                    } catch {
                        presentAlertRelay.accept((
                            title: .StringLiterals.Alert.storageErrorAlertTitle,
                            message: error.localizedDescription
                        ))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.bookMarkButtonDidTap
            .bind(with: self) { owner, _ in
                var newState = owner.bookMarkStateRelay.value
                newState.toggle()
                Tracking.logEvent(Tracking.Event.toggleBookmark)
                
                switch owner.detailViewType {
                case .create:
                    owner.bookMarkStateRelay.accept(newState)
                    
                case .viewer(let walkDiary):
                    let newWalkDiary = walkDiary.changeBookMark(newState)
                    
                    do {
                        try owner.walkRecordRepository.updateBookmark(entity: newWalkDiary)
                        owner.bookMarkStateRelay.accept(newState)
                    } catch {
                        presentAlertRelay.accept((
                            title: .StringLiterals.Alert.storageErrorAlertTitle,
                            message: error.localizedDescription
                        ))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.deleteButtonDidTap
            .bind(with: self) { owner, _ in
                guard let originalData = owner.walkDiaryEntity else {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Alert.storageErrorAlertTitle,
                        message: StorageError.imageDeleteFailed.localizedDescription
                    ))
                    return
                }
                do {
                    try owner.walkRecordRepository.delete(entity: originalData)
                    popToRootRelay.accept(())
                } catch {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Alert.storageErrorAlertTitle,
                        message: error.localizedDescription
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        input.photoDidDelete
            .bind(with: self) { owner, index in
                var newData = owner.photoDataRelay.value
                newData.remove(at: index)
                owner.photoDataRelay.accept(newData)
            }
            .disposed(by: disposeBag)
        
        input.photoDidAdd
            .bind(with: self) { owner, inputPhotos in
                Task {
                    do {
                        let currentLocation = try await owner.weatherLocationRepository.getCurrentLocation()
                        
                        let photos = inputPhotos.map { photo in
                            if photo.location == nil {
                                return WalkPhotoEntity(image: photo.image, location: currentLocation)
                            } else {
                                return photo
                            }
                        }
                        
                        let newPhotoData = owner.photoDataRelay.value + photos
                        owner.photoDataRelay.accept(newPhotoData)
                    } catch {
                        presentAlertRelay.accept((
                            title: "Photo Location Error",
                            message: error.localizedDescription
                        ))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.cameraActionDidTap
            .withUnretained(self)
            .map { $0.0.maxPhotoCount - $0.0.photoDataRelay.value.count }
            .bind { possibleCount in
                presentPickerViewRelay.accept(.camera(maxCount: possibleCount))
            }
            .disposed(by: disposeBag)
        
        input.libraryActionDidTap
            .withUnretained(self)
            .map { $0.0.maxPhotoCount - $0.0.photoDataRelay.value.count }
            .bind { possibleCount in
                presentPickerViewRelay.accept(.library(maxCount: possibleCount))
            }
            .disposed(by: disposeBag)
        
        input.emotionDidSelect
            .bind(with: self) { owner, emotionType in
                owner.walkRecordInfoData.emotion = emotionType
            }
            .disposed(by: disposeBag)
        
        input.titleDidChange
            .bind(with: self) { owner, title in
                owner.walkRecordInfoData.title = title
            }
            .disposed(by: disposeBag)
        
        input.contentDidChange
            .bind(with: self) { owner, content in
                owner.walkRecordInfoData.content = content
            }
            .disposed(by: disposeBag)
        
        input.routeViewDidUpdate
            .bind(with: self) { owner, image in
                owner.routeViewImage = image
            }
            .disposed(by: disposeBag)
        
        input.recordButtonDidTap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self) {
                owner,
                _ in
                /// 감정 입력
                guard owner.walkRecordInfoData.emotion != nil else {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Detail.inputRequiredTitle,
                        message: .StringLiterals.Detail.walkEmotionSelectMessage
                    ))
                    return
                }
                
                /// 제목 입력
                guard !owner.walkRecordInfoData.title.isEmpty else {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Detail.inputRequiredTitle,
                        message: .StringLiterals.Detail.walkTitleSettingMessage
                    ))
                    return
                }
                
                /// 지도 썸네일 저장
                guard let routeViewImage = owner.routeViewImage else {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Storage.imageSaveFailedMessage,
                        message: .StringLiterals.Alert.mapThumbnailSaveFailedMessage
                    ))
                    return
                }
                
                do {
                    let newData = WalkDiaryEntity(
                        id: UUID().uuidString,
                        isBookmarked: owner.bookMarkStateRelay.value,
                        weatherSymbol: owner.walkResultDataRelay.value.weather.symbolName,
                        weatherDescription: owner.walkResultDataRelay.value.weather.description,
                        temperature: owner.walkResultDataRelay.value.weather.temperature,
                        startTime: owner.walkResultDataRelay.value.tracking.startTime,
                        endTime: owner.walkResultDataRelay.value.tracking.endTime,
                        startLocation: owner.walkResultDataRelay.value.tracking.startLocation,
                        endLocation: owner.walkResultDataRelay.value.tracking.endLocation,
                        duration: owner.walkResultDataRelay.value.tracking.duration,
                        distance: owner.walkResultDataRelay.value.tracking.distance,
                        startDate: owner.walkResultDataRelay.value.tracking.startDate,
                        pathCoordinates: owner.walkResultDataRelay.value.tracking.pathCoordinates,
                        photos: owner.photoDataRelay.value,
                        emotion: owner.walkRecordInfoData.emotion?.rawValue ?? 0,
                        recordTitle: owner.walkRecordInfoData.title,
                        content: owner.walkRecordInfoData.content,
                        thumbnailImage: routeViewImage
                    )
                    try owner.walkRecordRepository.save(entity: newData)
                    Tracking.logEvent(Tracking.Event.saveRecord)
                    Tracking.logEvent(Tracking.Event.selectEmotion, parameters: [
                        Tracking.Event.selectEmotion: owner.walkRecordInfoData.emotion?.rawValue ?? 0
                    ])
                    
                    if !owner.walkRecordInfoData.content.isEmpty {
                        Tracking.logEvent(Tracking.Event.editContent)
                    }
                    
                    dismissToRootRelay.accept(())
                } catch {
                    presentAlertRelay.accept((
                        title: .StringLiterals.Alert.storageErrorAlertTitle,
                        message: error.localizedDescription
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            viewMode: Observable.just(detailViewType).asDriver(onErrorDriveWith: .empty()),
            walkDiaryEntity: Observable.just(walkDiaryEntity).asDriver(onErrorDriveWith: .empty()),
            bookMarkState: bookMarkStateRelay.asDriver(),
            walkResultData: walkResultDataRelay.asDriver(),
            photoData: photoDataRelay.asDriver(),
            presentPickerView: presentPickerViewRelay.asDriver(onErrorDriveWith: .empty()),
            presentAlert: presentAlertRelay.asDriver(onErrorDriveWith: .empty()),
            dismissToRoot: dismissToRootRelay.asDriver(onErrorDriveWith: .empty()),
            popToRoot: popToRootRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func mapperWalkResultEntity(_ data: WalkDiaryEntity) -> WalkResultEntity {
        let weatherLocation = WeatherLocationEntity(
            city: data.startLocation.city,
            district: data.startLocation.district,
            street: data.startLocation.street,
            symbolName: data.weatherSymbol,
            description: data.weatherDescription,
            temperature: data.temperature
        )
        
        let tracking = WalkTrackingEntity(
            startTime: data.startTime,
            endTime: data.endTime,
            startLocation: data.startLocation,
            endLocation: data.endLocation,
            duration: data.duration,
            distance: data.distance,
            pathCoordinates: data.pathCoordinates,
            startDate: data.startDate
        )
        
        return WalkResultEntity(weather: weatherLocation, tracking: tracking)
    }
}

// MARK: - ImagePickerSource
extension DetailViewModel {
    
    enum ImagePickerSource {
        case library(maxCount: Int)
        case camera(maxCount: Int)
    }
    
    enum DetailViewType {
        case create(walkResult: WalkResultEntity, walkPhotos: [WalkPhotoEntity])
        case viewer(walkDiary: WalkDiaryEntity)
    }
}
