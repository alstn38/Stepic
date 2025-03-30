//
//  DetailViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

import SnapKit

final class DetailViewController: UIViewController {
    
    private let bookMarkButton = UIBarButtonItem()
    private let walkInfoView = WalkInfoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            walkInfoView
        )
    }
    
    private func configureLayout() {
        walkInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
