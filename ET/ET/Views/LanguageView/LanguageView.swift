//
//  LanguageView.swift
//  ET
//
//  Created by HungNguyen on 11/5/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LanguageView: BaseCustomView {
    
    @IBOutlet weak var vwFromLanguage: UIView!
    @IBOutlet weak var vwToLanguage: UIView!
    @IBOutlet weak var lblFromLanguage: UILabel!
    @IBOutlet weak var lblToLanguage: UILabel!
    @IBOutlet weak var btnSelectFromLg: UIButton!
    @IBOutlet weak var btnSelectToLg: UIButton!
    
    /*
     1: From Language
     2: To Language
     */
    let selectLanguageSignal = PublishRelay<(Int, String)>()
    let selectedLanguage = PublishRelay<(Int, String)>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        observeSignal()
        bindData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        observeSignal()
        bindData()
    }
    
    func bindData() {
        selectedLanguage.asObservable()
            .subscribe(onNext: { [weak self] (index, language) in
                guard let self = self else { return }
                switch index {
                case 1: self.lblFromLanguage.text = language
                case 2: self.lblToLanguage.text = language
                default: break
                }
            }).disposed(by: disposed)
    }
    
    func observeSignal() {
        btnSelectFromLg.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.selectLanguageSignal.accept((1, self.lblFromLanguage.text ?? ""))
            }).disposed(by: disposed)
        
        btnSelectToLg.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.selectLanguageSignal.accept((2, self.lblToLanguage.text ?? ""))
            }).disposed(by: disposed)
    }
    
}
