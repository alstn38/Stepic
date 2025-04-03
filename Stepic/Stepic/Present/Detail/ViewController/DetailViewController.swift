//
//  DetailViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift
import SnapKit

final class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let bookMarkButton = UIBarButtonItem()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let walkInfoView = WalkInfoView()
    private let pictureSelectView = PictureSelectView()
    private let recordView = RecordView()
    private let routeView = RouteView()
    private let recordButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBind()
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureBind() {
        let input = DetailViewModel.Input()
        let output = viewModel.transform(from: input)
        
        output.walkResultData
            .drive(with: self) { owner, data in
                owner.walkInfoView.configureView(data)
            }
            .disposed(by: disposeBag)
        
        /// View 전용 내부 로직
        contentView.rx.tapGesture()
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        recordView.textDidEditing
            .bind(with: self) { owner, _ in
                owner.scrollToRecordView()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        bookMarkButton.image = .bookmark
        bookMarkButton.tintColor = .textPrimary
        
        navigationItem.rightBarButtonItem = bookMarkButton
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        scrollView.showsVerticalScrollIndicator = false
        
        recordButton.configuration = configureMainButtonButtonConfiguration(title: .StringLiterals.Detail.endWalkButton)
        recordButton.layer.cornerRadius = 10
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            walkInfoView,
            pictureSelectView,
            recordView,
            routeView,
            recordButton
        )
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        walkInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview()
        }
        
        pictureSelectView.snp.makeConstraints {
            $0.top.equalTo(walkInfoView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        recordView.snp.makeConstraints {
            $0.top.equalTo(pictureSelectView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        routeView.snp.makeConstraints {
            $0.top.equalTo(recordView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(routeView.snp.bottom).offset(76)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(54)
        }
    }
    
    private func scrollToRecordView() {
        let visibleTopY = scrollView.contentOffset.y
        let recordTopY = recordView.convert(CGPoint.zero, to: scrollView).y - 20
        
        guard visibleTopY < recordTopY else { return }
        
        scrollView.setContentOffset(
            CGPoint(x: 0, y: recordTopY),
            animated: true
        )
    }
}
