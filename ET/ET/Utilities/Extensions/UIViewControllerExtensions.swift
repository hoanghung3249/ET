//
//  UIViewControllerExtensions.swift
//  ET
//
//  Created by HungNguyen on 11/27/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addCustomChildViewController(_ child: UIViewController) {
        let root = UIApplication.shared.keyWindow?.rootViewController
        child.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        child.view.alpha = 0
        UIView.transition(with: child.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            root!.addChild(child)
            root!.view.addSubview(child.view)
            child.didMove(toParent: root)
            child.view.alpha = 1
        }, completion: nil)
    }
    
    func remove() {
        guard parent != nil else { return }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else { return }
            self.view.alpha = 0
        }, completion: { [weak self] (_) in
            guard let self = self else { return }
            self.willMove(toParent: nil)
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
}
