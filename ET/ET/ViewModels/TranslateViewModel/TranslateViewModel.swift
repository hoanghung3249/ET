//
//  TranslateViewModel.swift
//  ET
//
//  Created by HungNguyen on 11/4/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TranslateViewModel: BaseViewModel {
    let selectLanguageView = ListLanguageView()
    
    override init() {
        super.init()
    }
    
    func loadSelectLanguageView(in view: UIView) {
        view.addSubview(selectLanguageView)
        selectLanguageView.scaleEqualSuperView()
        selectLanguageView.animateDetailView(true)
    }
    
}
