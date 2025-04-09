//
//  WalkSummaryReactor.swift
//  Stepic
//
//  Created by 강민수 on 4/8/25.
//

import Foundation

import ReactorKit

final class WalkSummaryReactor: Reactor {
    
    enum Action {
        case viewWillAppear
        case searchTextChanged(String)
        case diaryItemSelected(IndexPath)
    }
    
    enum Mutation {
        case setOriginalData([WalkDiaryEntity])
        case setFilteredData([WalkDiaryEntity])
        case setSelectedDiary(WalkDiaryEntity)
        case setHiddenResultLabel(Bool)
    }
    
    struct State {
        var originalData: [WalkDiaryEntity] = []
        var filteredData: [WalkDiaryEntity] = []
        var isHiddenResultLabel: Bool = true
        @Pulse var selectedDiary: WalkDiaryEntity?
    }
    
    let initialState: State = State()
    
    private let viewType: WalkSummaryReactor.WalkSummaryViewType
    private let walkRecordRepository: WalkRecordRepository
    
    init(
        viewType: WalkSummaryReactor.WalkSummaryViewType,
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self)
    ) {
        self.viewType = viewType
        self.walkRecordRepository = walkRecordRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let records: [WalkDiaryEntity]
            switch viewType {
            case .entire:
                records = walkRecordRepository.fetchAll()
            case .monthly(let select):
                records = walkRecordRepository.fetch(byYear: select.year, month: select.month)
            case .bookMark:
                records = walkRecordRepository.fetchBookmarked()
            }
            
            let shouldHiddenLabel = !records.isEmpty
            return Observable.concat([
                .just(.setOriginalData(records)),
                .just(.setHiddenResultLabel(shouldHiddenLabel))
            ])
            
        case .searchTextChanged(let query):
            let lowercasedQuery = query.lowercased()
            let items = currentState.originalData
            
            guard !lowercasedQuery.isEmpty else {
                return Observable.just(.setFilteredData(items))
            }
            
            let filtered = items.filter { diary in
                let titleMatch = diary.recordTitle.lowercased().contains(lowercasedQuery)
                let contentMatch = diary.content?.lowercased().contains(lowercasedQuery) ?? false
                let locationMatch = [
                    diary.startLocation.city,
                    diary.startLocation.district,
                    diary.startLocation.street
                ].joined(separator: " ").lowercased().contains(lowercasedQuery)
                
                return titleMatch || contentMatch || locationMatch
            }
            return Observable.just(.setFilteredData(filtered))
            
        case .diaryItemSelected(let indexPath):
            let item = currentState.filteredData[indexPath.row]
            return Observable.just(.setSelectedDiary(item))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setOriginalData(let data):
            newState.originalData = data
            newState.filteredData = data
            
        case .setFilteredData(let data):
            newState.filteredData = data
            
        case .setSelectedDiary(let diary):
            newState.selectedDiary = diary
            
        case .setHiddenResultLabel(let isHidden):
            newState.isHiddenResultLabel = isHidden
        }
        return newState
    }
}


// MARK: - WalkSummaryViewType
extension WalkSummaryReactor {
    
    enum WalkSummaryViewType {
        case entire
        case monthly(select: YearMonth)
        case bookMark
    }
}
