//
//  TabbarViewController.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit

struct SegmentItem {
    var name: String
    var image: UIImage
}

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = Color.tabbarColor()
        tabBar.tintColor = Color.mainColor()
        tabBar.unselectedItemTintColor = Color.unSeletedTab()
        setupViewController()
        self.delegate = self
    }
    
    private func setupViewController() {
        let translateVC = ETStoryboard.main.instantiateViewController(ofType: TranslateViewController.self)
        let navTranslateVC = BaseETNavigation(rootViewController: translateVC)
        navTranslateVC.tabBarItem = UITabBarItem(title: "Translate", image: #imageLiteral(resourceName: "subtitles"), selectedImage: #imageLiteral(resourceName: "subtitles"))
//        navTranslateVC.setupTitle("Translate")
        navTranslateVC.navigationBar.isHidden = true
        
        let historyVC = ETStoryboard.main.instantiateViewController(ofType: HistoryViewController.self)
        let navHistoryVC = BaseETNavigation(rootViewController: historyVC)
        navHistoryVC.tabBarItem = UITabBarItem(title: "History", image: #imageLiteral(resourceName: "history"), selectedImage: #imageLiteral(resourceName: "history"))
        navHistoryVC.setupTitle("History")
        
        let settingsVC = ETStoryboard.main.instantiateViewController(ofType: SettingViewController.self)
        let navSettingsVC = BaseETNavigation(rootViewController: settingsVC)
        navSettingsVC.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "settings"), selectedImage: #imageLiteral(resourceName: "settings"))
        navSettingsVC.setupTitle("Settings")

        self.viewControllers = [navTranslateVC, navHistoryVC, navSettingsVC]
        self.selectedViewController = navTranslateVC
    }
    
}

// MARK: - Support Method
extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.tabBar.isHidden = false
    }
    
}
