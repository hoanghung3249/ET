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
    let selectLanguageSignal = PublishRelay<(Int, LanguageModel)>()
    let selectedLanguage = PublishRelay<(Int, String)>()
    let fromLanguageBehavior = BehaviorRelay<String>(value: "")
    let toLanguageBehavior = BehaviorRelay<String>(value: "")
    let translateModel = BehaviorRelay<TranslateModel>(value: TranslateModel())
    
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
                case 1: self.fromLanguageBehavior.accept(language)
                case 2: self.toLanguageBehavior.accept(language)
                default: break
                }
            }).disposed(by: disposed)
        

        fromLanguageBehavior.asObservable().subscribe(onNext: { [weak self] (name) in
            guard let self = self else { return }
            TranslationManager.shared.saveLanguage(type: .fromLanguage(self.getLanguageModel(name) ?? LanguageModel("English", "en")))
            self.lblFromLanguage.text = name
            }).disposed(by: disposed)

        toLanguageBehavior.asObservable().subscribe(onNext: { [weak self] (name) in
            guard let self = self else { return }
            TranslationManager.shared.saveLanguage(type: .toLanguage(self.getLanguageModel(name) ?? LanguageModel("English", "en")))
            self.lblToLanguage.text = name
            }).disposed(by: disposed)
        
        Observable.combineLatest(fromLanguageBehavior.asObservable(), toLanguageBehavior.asObservable()) { [weak self] (fromLng, toLng) -> (TranslateModel) in
            guard let self = self else { return TranslateModel() }
            let translateModel = TranslateModel()
            translateModel.sourceLanguage = self.getLanguage(from: fromLng) ?? ""
            translateModel.target = self.getLanguage(from: toLng) ?? ""
            return translateModel
            }.bind(to: translateModel).disposed(by: disposed)
    }
    
    func observeSignal() {
        btnSelectFromLg.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let languageModel = LanguageModel(self.lblFromLanguage.text, self.getLanguage(from: self.lblFromLanguage.text ?? ""))
                self.selectLanguageSignal.accept((1, languageModel))
            }).disposed(by: disposed)
        
        btnSelectToLg.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let languageModel = LanguageModel(self.lblToLanguage.text, self.getLanguage(from: self.lblToLanguage.text ?? ""))
                self.selectLanguageSignal.accept((2, languageModel))
            }).disposed(by: disposed)
    }
    
}

// MARK: - Support Method
private extension LanguageView {
    
    func getLanguage(from name: String) -> String? {
        let language = TranslationManager.shared.supportedLanguage.filter({$0.name == name}).first?.language
        return language
    }
    
    func getLanguageModel(_ name: String) -> LanguageModel? {
        return TranslationManager.shared.supportedLanguage.first(where: {$0.name == name})
    }
    
}
