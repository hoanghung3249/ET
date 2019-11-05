//
//  Color.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit

class Color {
    static func mainColor() -> UIColor {
        return UIColor(red: 27.0/255.0, green: 224.0/255.0, blue: 123.0/255.0, alpha: 0.7)
    }
    
    static func tabbarColor() -> UIColor {
        return UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1)
    }
    
    static func unSeletedTab() -> UIColor {
        return UIColor(red: 133.0/255.0, green: 132.0/255.0, blue: 139.0/255.0, alpha: 1)
    }
    
    static func unSelectedButton() -> UIColor {
        return UIColor(red: 25.0/255.0, green: 212.0/255.0, blue: 116.0/255.0, alpha: 1)
    }
    
}
class Font: UIFont {
    
    static func fontAvenirNext(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir Next", size: size)!
    }
    
    static func fontAvenirNextBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size)!
    }
}
