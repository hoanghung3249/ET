//
//  ProgressView.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class ProgressView {
    
    static let shared = ProgressView()
    var indicator = NVActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    var containerView = UIView()
    
    func show(_ view: UIView){
        
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(white: 0x000000, alpha: 0.4)
        indicator.type = .ballClipRotate
        indicator.color = .green
        indicator.center = CGPoint(x: view.bounds.width/2,y: view.bounds.height/2)
        indicator.startAnimating()
        containerView.addSubview(indicator)
        
        view.addSubview(containerView)
    }
    
    func hide(){
        indicator.stopAnimating()
        containerView.removeFromSuperview()
    }
    
}
