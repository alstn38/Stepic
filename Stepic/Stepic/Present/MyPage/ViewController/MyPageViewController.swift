//
//  MyPageViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    private let settingButton = UIBarButtonItem()
    private let myPageInfoView = MyPageInfoView()
    
    init(viewModel: MyPageViewModel) {
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
        let selectDateDidChangeRelay = PublishRelay<YearMonth>()
        
        let input = MyPageViewModel.Input(
            viewDidLoad: Observable.just(()),
            selectDateDidChange: selectDateDidChangeRelay.asObservable(),
            totalWalkButtonDidTap: myPageInfoView.totalWalkButton.rx.tapGesture().map { _ in }.asObservable(),
            monthWalkButtonDidTap: myPageInfoView.monthWalkButton.rx.tapGesture().map { _ in }.asObservable(),
            bookmarkButtonDidTap: myPageInfoView.bookmarkButton.rx.tapGesture().map { _ in }.asObservable()
        )
        
        let output = viewModel.transform(from: input)
        
        output.selectedDate
            .drive(with: self) { owner, yearMonth in
                owner.myPageInfoView.configureView(yearMonth)
            }
            .disposed(by: disposeBag)
        
        output.myPageInfoItems
            .drive(with: self) { owner, myPageInfoItem in
                owner.myPageInfoView.configureView(myPageInfoItem)
            }
            .disposed(by: disposeBag)
        
        output.moveToSummaryView
            .drive(with: self) { owner, type in
                let viewModel = WalkSummaryViewModel(viewType: type)
                let viewController = WalkSummaryViewController(viewModel: viewModel)
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        /// 뷰 내부 로직
        myPageInfoView.calendarButton.rx.tap
            .bind(with: self) { owner, _ in
                let monthPicker = MonthPickerViewController() { selected in
                    selectDateDidChangeRelay.accept(selected)
                }
                
                monthPicker.modalPresentationStyle = .pageSheet
                if let sheet = monthPicker.sheetPresentationController {
                    sheet.detents = [
                        .custom(resolver: { context in
                            return context.maximumDetentValue * 0.3
                        })
                    ]
                }
                
                owner.present(monthPicker, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        settingButton.image = .gearShape
        settingButton.tintColor = .textPrimary
        
        navigationItem.rightBarButtonItem = settingButton
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            myPageInfoView
        )
    }
    
    private func configureLayout() {
        myPageInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
