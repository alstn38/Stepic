//
//  MyPageViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

import SnapKit

final class MyPageViewController: UIViewController {
    
    private let settingButton = UIBarButtonItem()
    private let myPageInfoView = MyPageInfoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
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
