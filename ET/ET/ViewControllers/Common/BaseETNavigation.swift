//
//  BaseETNavigation.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit

class BaseETNavigation: UINavigationController {
    
    deinit {
        print("Deinit view")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicView()
    }
    
    //MARK:- Support function
    private func setupBasicView() {
        self.navigationBar.barTintColor = Color.mainColor()
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Font.fontAvenirNextBold(20),NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public func setupTitle(_ titleName:String) {
        navigationBar.topItem?.title = titleName
    }

}

// MARK: - Gesture Delegate
extension BaseETNavigation: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
