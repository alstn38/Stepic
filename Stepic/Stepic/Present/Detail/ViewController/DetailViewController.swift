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
    
    private let disposeBag = DisposeBag()
    
    private let bookMarkButton = UIBarButtonItem()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let walkInfoView = WalkInfoView()
    private let recordView = RecordView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBind()
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureNavigation() {
        bookMarkButton.image = .bookmark
        bookMarkButton.tintColor = .textPrimary
        
        navigationItem.rightBarButtonItem = bookMarkButton
    }
    
    private func configureBind() {
        scrollView.rx.didScroll
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        contentView.rx.tapGesture()
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            walkInfoView,
            recordView
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
        
        recordView.snp.makeConstraints {
            $0.top.equalTo(walkInfoView.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview() // 항상 마지막 뷰는 해당 레이아웃 추가
        }
    }
}
