//
//  StepicTabBarController.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

final class StepicTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBar()
    }
    
    private func configureTabBar() {
        view.backgroundColor = .backgroundPrimary
        configureTabBarController()
        configureTabBarAppearance()
    }
    
    private func configureTabBarController() {
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(
            title: .StringLiterals.TabBar.homeTitle,
            image: .homeImage,
            selectedImage: .homeImage
        )
        
        let myPageViewController = MyPageViewController()
        myPageViewController.tabBarItem = UITabBarItem(
            title: .StringLiterals.TabBar.myPageTitle,
            image: .personImage,
            selectedImage: .personImage
        )
        
        let exchangeNavigationController = UINavigationController(rootViewController: homeViewController)
        let coinInfoNavigationController = UINavigationController(rootViewController: myPageViewController)
        setViewControllers(
            [exchangeNavigationController, coinInfoNavigationController],
            animated: true
        )
    }
    
    private func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .accentPrimary
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.tintColor = .accentPrimary
    }
}
