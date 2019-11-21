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
    let selectCameraView = CameraView()
    let translateText = BehaviorRelay<String?>(value: nil)
    let finalText = BehaviorRelay<String>(value: "")
    var translateModel = TranslateModel()
    
    override init() {
        super.init()
    }
    
    func loadSelectLanguageView(in view: UIView, _ seletedIndex: Int, _ selectedLanguage: LanguageModel) {
        view.addSubview(selectLanguageView)
        selectLanguageView.selectedIndex = seletedIndex
        selectLanguageView.inputLanguage.accept(selectedLanguage)
        selectLanguageView.scaleEqualSuperView()
        selectLanguageView.animateDetailView(true)
    }
        
    func requestTranslateText() {
        let sourceText = translateText.value ?? ""
        if sourceText.isEmpty {
            finalText.accept("")
            return
        }
        translateModel.sourceText = sourceText
        ETServiceManager.shared.request(.translate(translateModel), mapObject: DataModel<ListTranslateModel>.self)
        .trackActivity(activityIndicator)
            .subscribe(onNext: { [weak self] (response) in
                guard let self = self, let model = response.data, let translateResponse = model.translations.first else { return }
                self.finalText.accept(translateResponse.translatedText ?? "")
            }, onError: { [weak self] (error) in
                guard let self = self else { return }
                self.requestError(error)
            }).disposed(by: disposeBag)
    }
}
