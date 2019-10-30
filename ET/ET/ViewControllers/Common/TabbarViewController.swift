//
//  TabbarViewController.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = Color.mainColor()
        tabBar.tintColor = UIColor.red
        tabBar.unselectedItemTintColor = UIColor.white
        setupViewController()
        self.delegate = self
    }
    
    private func setupViewController() {
        let translateVC = ETStoryboard.main.instantiateViewController(ofType: TranslateViewController.self)
        let navTranslateVC = BaseETNavigation(rootViewController: translateVC)
//        let homeVC = MMStoryboard.home.instantiateViewController(ofType: HomeViewController.self)
//        let naviHomePageVC = BaseNavigationViewController(rootViewController: homeVC)
//        naviHomePageVC.tabBarItem = UITabBarItem(title: "Trang chủ", image: #imageLiteral(resourceName: "001-home"), selectedImage: #imageLiteral(resourceName: "002-house-black-silhouette-without-door"))
//        naviHomePageVC.setupTitle("Trang chủ")
//
//        let likeVC = MMStoryboard.home.instantiateViewController(ofType: LikeViewController.self)
//        let naviLikePageVC = BaseNavigationViewController(rootViewController: likeVC)
//        naviLikePageVC.tabBarItem = UITabBarItem(title: "Yêu thích", image: #imageLiteral(resourceName: "003-like"), selectedImage: #imageLiteral(resourceName: "004-favorite-heart-button"))
//        naviLikePageVC.setupTitle("Yêu thích")
//
//        let postVC = MMStoryboard.home.instantiateViewController(ofType: PostViewController.self)
//        let naviPostPageVC = BaseNavigationViewController(rootViewController: postVC)
//        naviPostPageVC.tabBarItem = UITabBarItem(title: "Đăng bài", image: #imageLiteral(resourceName: "005-plus"), selectedImage: UIImage(named: ""))
//        naviPostPageVC.setupTitle("Đăng bài")
//
//        let menuVC = MMStoryboard.home.instantiateViewController(ofType: MenuViewController.self)
//        let naviMenuPageVC = BaseNavigationViewController(rootViewController: menuVC)
//        naviMenuPageVC.tabBarItem = UITabBarItem(title: "Danh sách", image:#imageLiteral(resourceName: "007-menu"), selectedImage: UIImage(named: ""))
//        naviMenuPageVC.setupTitle("Danh sách")
//
//        self.viewControllers = [naviHomePageVC,naviLikePageVC,naviPostPageVC,naviMenuPageVC]
//        self.selectedViewController = naviHomePageVC
    }
    
}

// MARK: - Support Method
extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.tabBar.isHidden = false
    }
    
}
