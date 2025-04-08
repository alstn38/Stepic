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
        let searchTextDidChange: Observable<String>
        let diaryDataDidTap: Observable<IndexPath>
    }
    
    struct Output {
        let filteredWalkDiaryData: Driver<[WalkDiaryEntity]>
        let moveToDetailView: Driver<WalkDiaryEntity>
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
        let originalWalkDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
        let filteredWalkDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
        let moveToDetailViewRelay = PublishRelay<WalkDiaryEntity>()
        
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
                
                originalWalkDiaryDataRelay.accept(sectionItems)
                filteredWalkDiaryDataRelay.accept(sectionItems)
            }
            .disposed(by: disposeBag)
        
        input.searchTextDidChange
            .withLatestFrom(originalWalkDiaryDataRelay) { ($0, $1) }
            .map { query, items -> [WalkDiaryEntity] in
                let lowercasedQuery = query.lowercased()
                
                guard !lowercasedQuery.isEmpty else {
                    return items
                }

                return items.filter { diary in
                    let titleMatch = diary.recordTitle.lowercased().contains(lowercasedQuery)
                    let contentMatch = (diary.content?.lowercased().contains(lowercasedQuery) ?? false)
                    let locationMatch = [
                        diary.startLocation.city,
                        diary.startLocation.district,
                        diary.startLocation.street
                    ]
                    .joined(separator: " ")
                    .lowercased()
                    .contains(lowercasedQuery)

                    return titleMatch || contentMatch || locationMatch
                }
            }
            .bind(to: filteredWalkDiaryDataRelay)
            .disposed(by: disposeBag)
        
        input.diaryDataDidTap
            .map { filteredWalkDiaryDataRelay.value[$0.row] }
            .bind(to: moveToDetailViewRelay)
            .disposed(by: disposeBag)
        
        return Output(
            filteredWalkDiaryData: filteredWalkDiaryDataRelay.asDriver(),
            moveToDetailView: moveToDetailViewRelay.asDriver(onErrorDriveWith: .empty())
        )
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
