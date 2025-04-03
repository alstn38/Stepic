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
        
    }
    
    struct Output {
        let walkResultData: Driver<WalkResultEntity>
    }
    
    private let walkResultData: WalkResultEntity
    
    init(walkResultData: WalkResultEntity) {
        self.walkResultData = walkResultData
    }
    
    func transform(from input: Input) -> Output {
        let walkResultDataRelay = BehaviorRelay(value: walkResultData)
        
        return Output(walkResultData: Observable.just(walkResultData).asDriver(onErrorDriveWith: .empty()))
    }
}
