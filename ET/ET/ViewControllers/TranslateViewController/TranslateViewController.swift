//
//  TranslateViewController.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit

class TranslateViewController: BaseViewController {
    @IBOutlet weak var vwAction: ActionView!
    @IBOutlet weak var vwLanguage: LanguageView!
    @IBOutlet weak var txvFromLanguage: UITextView!
    @IBOutlet weak var txvToLanguage: UITextView!
    @IBOutlet weak var btnTranslate: UIButton!
    @IBOutlet weak var btnRemoveTextFromLanguage: UIButton!
    @IBOutlet weak var btnSpeakerFromLanguage: UIButton!
    @IBOutlet weak var btnSpeakerToLanguage: UIButton!
    
    var viewModel = TranslateViewModel()
    
    override func redrawLayout() {
        setupButtonInTextView()
    }
    
    override func bindingViewModel() {
        bindCommonAction(viewModel)
        txvFromLanguage.rx.text.bind(to: viewModel.translateText).disposed(by: disposeBag)
        
        viewModel.selectLanguageView.selectedLanguage.bind(to: vwLanguage.selectedLanguage).disposed(by: disposeBag)
        
        vwLanguage.translateModel.asObservable()
            .subscribe(onNext: { [weak self] (model) in
                guard let self = self else { return }
                self.viewModel.translateModel = model
            }).disposed(by: disposeBag)
        
        viewModel.finalText.asDriver()
            .drive(onNext: { [weak self] (finalText) in
                guard let self = self else { return }
                self.txvToLanguage.text = finalText
            }).disposed(by: disposeBag)
        
        viewModel.fromLanguageBehavior.bind(to: vwLanguage.fromLanguageBehavior).disposed(by: disposeBag)
        viewModel.toLanguageBehavior.bind(to: vwLanguage.toLanguageBehavior).disposed(by: disposeBag)
    }
    
    override func observeSignal() {
        txvFromLanguage.rx.text.asDriver()
            .drive(onNext: { [weak self] (text) in
                guard let self = self, let text = text else { return }
                self.btnRemoveTextFromLanguage.isHidden = text.isEmpty
                self.btnSpeakerFromLanguage.isHidden = text.isEmpty
            }).disposed(by: disposeBag)
        
        btnRemoveTextFromLanguage.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.txvFromLanguage.text = ""
            }).disposed(by: disposeBag)
        
        txvToLanguage.rx.text.asDriver()
            .drive(onNext: { [weak self] (text) in
                guard let self = self, let text = text else { return }
                self.btnSpeakerToLanguage.isHidden = text.isEmpty
            }).disposed(by: disposeBag)
        
        vwLanguage.selectLanguageSignal
            .subscribe(onNext: { [weak self] (index, language) in
                guard let self = self else { return }
                self.viewModel.loadSelectLanguageView(in: self.view, index, language)
            }).disposed(by: disposeBag)
        
        btnTranslate.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.viewModel.requestTranslateText()
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - Support Method
private extension TranslateViewController {
    
    func setupButtonInTextView() {
        let buttonFrame = btnRemoveTextFromLanguage.frame
        let exclusivePath = UIBezierPath(rect: buttonFrame)
        txvFromLanguage.textContainer.exclusionPaths = [exclusivePath]
    }
    
}
