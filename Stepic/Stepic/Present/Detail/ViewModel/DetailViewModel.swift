//
//  DetailViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

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
    }
    
    struct Output {
        let bookMarkState: Driver<Bool>
        let walkResultData: Driver<WalkResultEntity>
        let photoData: Driver<[WalkPhotoEntity]>
        let presentPickerView: Driver<ImagePickerSource>
        let presentAlert: Driver<(title: String, message: String)>
    }
    
    private let weatherLocationRepository: WeatherLocationRepository
    
    private let maxPhotoCount: Int = 10
    private let bookMarkStateRelay = BehaviorRelay<Bool>(value: false)
    private let walkResultData: WalkResultEntity
    private let photoDataRelay: BehaviorRelay<[WalkPhotoEntity]>
    private var walkRecordInfoData = WalkRecordInfoEntity()
    private let disposeBag = DisposeBag()
    
    init(
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self),
        walkResultData: WalkResultEntity,
        walkPhotoData: [WalkPhotoEntity])
    {
        self.weatherLocationRepository = weatherLocationRepository
        self.walkResultData = walkResultData
        self.photoDataRelay = BehaviorRelay(value: walkPhotoData)
    }
    
    func transform(from input: Input) -> Output {
        let presentPickerViewRelay = PublishRelay<ImagePickerSource>()
        let presentAlertRelay = PublishRelay<(title: String, message: String)>()
        
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
                print(emotionType.title)
            }
            .disposed(by: disposeBag)
        
        input.titleDidChange
            .bind(with: self) { owner, title in
                owner.walkRecordInfoData.title = title
                print(title)
            }
            .disposed(by: disposeBag)
        
        input.contentDidChange
            .bind(with: self) { owner, content in
                owner.walkRecordInfoData.content = content
                print(content)
            }
            .disposed(by: disposeBag)
        
        return Output(
            bookMarkState: bookMarkStateRelay.asDriver(),
            walkResultData: Observable.just(walkResultData).asDriver(onErrorDriveWith: .empty()),
            photoData: photoDataRelay.asDriver(),
            presentPickerView: presentPickerViewRelay.asDriver(onErrorDriveWith: .empty()),
            presentAlert: presentAlertRelay.asDriver(onErrorDriveWith: .empty())
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
