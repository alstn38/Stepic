//
//  WalkSummaryViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/5/25.
//

import Foundation

import RxCocoa
import RxSwift

final class WalkSummaryViewModel: InputOutputModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let walkDiaryData: Driver<[WalkDiaryEntity]>
    }
    
    private let viewType: WalkSummaryViewType
    private let walkRecordRepository: WalkRecordRepository
    private let disposeBag = DisposeBag()
    
    init(
        viewType: WalkSummaryViewType,
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self)
    ) {
        self.viewType = viewType
        self.walkRecordRepository = walkRecordRepository
    }
    
    func transform(from input: Input) -> Output {
        let walkDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                let sectionItems: [WalkDiaryEntity]
                
                switch owner.viewType {
                case .entire:
                    sectionItems = owner.walkRecordRepository.fetchAll()
                    
                case .monthly(let select):
                    sectionItems = owner.walkRecordRepository.fetch(byYear: select.year, month: select.month)
                    
                case .bookMark:
                    sectionItems = owner.walkRecordRepository.fetchBookmarked()
                }
                
                walkDiaryDataRelay.accept(sectionItems)
            }
            .disposed(by: disposeBag)
        
        return Output(walkDiaryData: walkDiaryDataRelay.asDriver())
    }
}

// MARK: - WalkSummaryViewType
extension WalkSummaryViewModel {
    
    enum WalkSummaryViewType {
        case entire
        case monthly(select: YearMonth)
        case bookMark
    }
}
