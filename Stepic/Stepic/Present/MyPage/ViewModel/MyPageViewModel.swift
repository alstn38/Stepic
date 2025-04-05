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
    }
    
    struct Output {
        let selectedDate: Driver<YearMonth>
        let myPageInfoItems: Driver<MyPageInfoViewItem>
    }
    
    private var walkDiaryData: [WalkDiaryEntity] = []
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
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                let todayDate = owner.getTodayDate()
                let yearMonth = YearMonth(year: todayDate.year, month: todayDate.month)
                selectedDateRelay.accept(yearMonth)
                
                owner.walkDiaryData = owner.walkRecordRepository.fetchAll()
                let myPageInfo = owner.createMyPageInfo(
                    from: owner.walkDiaryData,
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
                    from: owner.walkDiaryData,
                    year: yearMonth.year,
                    month: yearMonth.month
                )
                myPageInfoItemsRelay.accept(myPageInfo)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedDate: selectedDateRelay.asDriver(),
            myPageInfoItems: myPageInfoItemsRelay.asDriver()
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
        let now = Date()
        
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
}
