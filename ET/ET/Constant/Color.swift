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
        return UIColor(red: 255.0/255.0, green: 173.0/255.0, blue: 14.0/255.0, alpha: 0.7)
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
