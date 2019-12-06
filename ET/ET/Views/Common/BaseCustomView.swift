//
//  BaseCustomView.swift
//  ET
//
//  Created by HungNguyen on 11/5/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BaseCustomView: UIView {
    let swapLanguageBehavior = PublishRelay<Void>()
    
    let disposed = DisposeBag()
    
    func configure() { }
}
