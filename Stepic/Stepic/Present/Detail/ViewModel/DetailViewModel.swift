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
        let bookMarkButtonDidTap: Observable<Void>
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
        let bookMarkState: Driver<Bool>
        let walkResultData: Driver<WalkResultEntity>
        let photoData: Driver<[WalkPhotoEntity]>
        let presentPickerView: Driver<ImagePickerSource>
        let presentAlert: Driver<(title: String, message: String)>
        let dismissToRoot: Driver<Void>
    }
    
    private let walkRecordRepository: WalkRecordRepository
    private let weatherLocationRepository: WeatherLocationRepository
    
    private let maxPhotoCount: Int = 10
    private let bookMarkStateRelay = BehaviorRelay<Bool>(value: false)
    private let walkResultData: WalkResultEntity
    private let photoDataRelay: BehaviorRelay<[WalkPhotoEntity]>
    private var walkRecordInfoData = WalkRecordInfoEntity()
    private var routeViewImage: UIImage?
    private let disposeBag = DisposeBag()
    
    init(
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self),
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self),
        walkResultData: WalkResultEntity,
        walkPhotoData: [WalkPhotoEntity])
    {
        self.walkRecordRepository = walkRecordRepository
        self.weatherLocationRepository = weatherLocationRepository
        self.walkResultData = walkResultData
        self.photoDataRelay = BehaviorRelay(value: walkPhotoData)
    }
    
    func transform(from input: Input) -> Output {
        let presentPickerViewRelay = PublishRelay<ImagePickerSource>()
        let presentAlertRelay = PublishRelay<(title: String, message: String)>()
        let dismissToRootRelay = PublishRelay<Void>()
        
        input.bookMarkButtonDidTap
            .bind(with: self) { owner, _ in
                var newState = owner.bookMarkStateRelay.value
                newState.toggle()
                owner.bookMarkStateRelay.accept(newState)
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
                        weatherSymbol: owner.walkResultData.weather.symbolName,
                        weatherDescription: owner.walkResultData.weather.description,
                        temperature: owner.walkResultData.weather.temperature,
                        startTime: owner.walkResultData.tracking.startTime,
                        endTime: owner.walkResultData.tracking.endTime,
                        startLocation: owner.walkResultData.tracking.startLocation,
                        endLocation: owner.walkResultData.tracking.endLocation,
                        duration: owner.walkResultData.tracking.duration,
                        distance: owner.walkResultData.tracking.distance,
                        startDate: owner.walkResultData.tracking.startDate,
                        pathCoordinates: owner.walkResultData.tracking.pathCoordinates,
                        photos: owner.photoDataRelay.value,
                        emotion: owner.walkRecordInfoData.emotion?.rawValue ?? 0,
                        recordTitle: owner.walkRecordInfoData.title,
                        content: owner.walkRecordInfoData.content,
                        thumbnailImage: routeViewImage
                    )
                    try owner.walkRecordRepository.save(entity: newData)
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
            bookMarkState: bookMarkStateRelay.asDriver(),
            walkResultData: Observable.just(walkResultData).asDriver(onErrorDriveWith: .empty()),
            photoData: photoDataRelay.asDriver(),
            presentPickerView: presentPickerViewRelay.asDriver(onErrorDriveWith: .empty()),
            presentAlert: presentAlertRelay.asDriver(onErrorDriveWith: .empty()),
            dismissToRoot: dismissToRootRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

// MARK: - ImagePickerSource
extension DetailViewModel {
    
    enum ImagePickerSource {
        case library(maxCount: Int)
        case camera(maxCount: Int)
    }
}
