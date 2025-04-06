//
//  MyPageViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/5/25.
//

import Foundation

import RxCocoa
import RxSwift

final class MyPageViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let selectDateDidChange: Observable<YearMonth>
        let totalWalkButtonDidTap: Observable<Void>
        let monthWalkButtonDidTap: Observable<Void>
        let bookmarkButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let selectedDate: Driver<YearMonth>
        let myPageInfoItems: Driver<MyPageInfoViewItem>
        let moveToSummaryView: Driver<WalkSummaryViewModel.WalkSummaryViewType>
        let emotionStaticData: Driver<[EmotionCount]>
    }
    
    private let walkDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
    private let walkRecordRepository: WalkRecordRepository
    private let disposeBag = DisposeBag()
    
    init(
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self)
    ) {
        self.walkRecordRepository = walkRecordRepository
    }
    
    func transform(from input: Input) -> Output {
        let selectedDateRelay = BehaviorRelay<YearMonth>(value: YearMonth(year: 0, month: 0))
        let myPageInfoItemsRelay = BehaviorRelay<MyPageInfoViewItem>(value: MyPageInfoViewItem.dummy())
        let moveToSummaryViewRelay = PublishRelay<WalkSummaryViewModel.WalkSummaryViewType>()
        let emotionStaticDataRelay = BehaviorRelay<[EmotionCount]>(value: [])
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                let todayDate = owner.getTodayDate()
                let yearMonth = YearMonth(year: todayDate.year, month: todayDate.month)
                selectedDateRelay.accept(yearMonth)
                
                let allData = owner.walkRecordRepository.fetchAll()
                owner.walkDiaryDataRelay.accept(allData)
                let myPageInfo = owner.createMyPageInfo(
                    from: owner.walkDiaryDataRelay.value,
                    year: todayDate.year,
                    month: todayDate.month
                )
                myPageInfoItemsRelay.accept(myPageInfo)
            }
            .disposed(by: disposeBag)
        
        input.selectDateDidChange
            .bind(with: self) { owner, yearMonth in
                selectedDateRelay.accept(yearMonth)
                
                let myPageInfo = owner.createMyPageInfo(
                    from: owner.walkDiaryDataRelay.value,
                    year: yearMonth.year,
                    month: yearMonth.month
                )
                myPageInfoItemsRelay.accept(myPageInfo)
            }
            .disposed(by: disposeBag)
        
        input.totalWalkButtonDidTap
            .map { WalkSummaryViewModel.WalkSummaryViewType.entire }
            .bind(to: moveToSummaryViewRelay)
            .disposed(by: disposeBag)
        
        input.monthWalkButtonDidTap
            .withLatestFrom(selectedDateRelay)
            .map { WalkSummaryViewModel.WalkSummaryViewType.monthly(select: $0) }
            .bind(to: moveToSummaryViewRelay)
            .disposed(by: disposeBag)
        
        input.bookmarkButtonDidTap
            .map { WalkSummaryViewModel.WalkSummaryViewType.bookMark }
            .bind(to: moveToSummaryViewRelay)
            .disposed(by: disposeBag)
        
        walkDiaryDataRelay
            .withLatestFrom(selectedDateRelay) { ($0, $1) }
            .bind(with: self) { owner,  data in
                let (walkDiaryList, yearMonth) = data
                let emotionData = owner.createEmotionCounts(
                    from: walkDiaryList,
                    yearMonth: yearMonth
                )
                emotionStaticDataRelay.accept(emotionData)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedDate: selectedDateRelay.asDriver(),
            myPageInfoItems: myPageInfoItemsRelay.asDriver(),
            moveToSummaryView: moveToSummaryViewRelay.asDriver(onErrorDriveWith: .empty()),
            emotionStaticData: emotionStaticDataRelay.asDriver()
        )
    }
    
    private func getTodayDate() -> YearMonth {
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        return YearMonth(year: year, month: month)
    }
    
    private func createMyPageInfo(
        from diaryList: [WalkDiaryEntity],
        year: Int,
        month: Int
    ) -> MyPageInfoViewItem {
        let calendar = Calendar.current
        
        /// 전달받은 연/월에 해당하는 산책 리스트 필터링
        let selectedMonthWalks = diaryList.filter {
            let walkDate = $0.startDate
            return calendar.component(.year, from: walkDate) == year &&
                   calendar.component(.month, from: walkDate) == month
        }
        
        return MyPageInfoViewItem(
            totalTime: selectedMonthWalks.reduce(0) { $0 + $1.duration },
            totalDistance: selectedMonthWalks.reduce(0) { $0 + $1.distance },
            totalWalkCount: diaryList.count,
            monthWalkCount: selectedMonthWalks.count,
            bookMarkWalkCount: diaryList.filter { $0.isBookmarked }.count
        )
    }
    
    private func createEmotionCounts(
        from diaryList: [WalkDiaryEntity],
        yearMonth: YearMonth
    ) -> [EmotionCount] {
        let calendar = Calendar.current
        
        let filtered = diaryList.filter {
            calendar.component(.year, from: $0.startDate) == yearMonth.year &&
            calendar.component(.month, from: $0.startDate) == yearMonth.month
        }
        
        var emotionDict: [EmotionTypeEntity: Int] = [:]
        EmotionTypeEntity.allCases.forEach { emotionDict[$0] = 0 }

        for diary in filtered {
            if let emotion = EmotionTypeEntity(rawValue: diary.emotion) {
                emotionDict[emotion, default: 0] += 1
            }
        }

        let maxCount = emotionDict.values.max() ?? 0

        return EmotionTypeEntity.allCases.map { emotion in
            EmotionCount(
                emotion: emotion,
                count: emotionDict[emotion] ?? 0,
                isMostFrequent: (emotionDict[emotion] == maxCount) && maxCount > 0
            )
        }
    }
}
