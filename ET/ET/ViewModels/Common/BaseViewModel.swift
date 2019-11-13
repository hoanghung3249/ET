//
//  BaseViewModel.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

var supportedLanguage = [LanguageModel]()

class BaseViewModel {
    let disposeBag = DisposeBag()
    let shouldReloadData = BehaviorRelay<Void?>(value: nil)
    let shouldReloadSections = BehaviorRelay<IndexSet?>(value: nil)
    let shouldReloadRows = BehaviorRelay<[IndexPath]?>(value: nil)
    lazy var activityIndicator = ActivityIndicator() // For checking loading status
    var requestProcessTracking: [PublishSubject<Void>] = [] // For tracking multithreads request
    let didRequestError = BehaviorRelay<Error?>(value: nil)
//    var supportedLanguage = [LanguageModel]()
    let fromLanguageBehavior = BehaviorRelay<String>(value: "")
    let toLanguageBehavior = BehaviorRelay<String>(value: "")
    
    // MARK: - Init BaseViewModel
    init() {
        if supportedLanguage.isEmpty { getSupportedLanguage() }
        firstSetupLanguage()
    }
    
    deinit {
        print("Deinit: \(type(of: self))")
    }
    
    /// Clear all data for refresh
    func clearAll() {} // Override
    
    /// Refresh data
    func refreshData() {
        clearAll()
    }
    
    func requestError(_ error: Error) {
        didRequestError.accept(error)
    }
    
    func reloadData() { shouldReloadData.accept(()) }
    
    func reloadSections(_ sections: IndexSet) { shouldReloadSections.accept(sections) }
    
    func reloadRows(_ rows: [IndexPath]) { shouldReloadRows.accept(rows) }
    
}

// ======================================================================
// MARK: - Request Tracking Flow
// ======================================================================
extension BaseViewModel {
    func clearRequestTracking() {
        requestProcessTracking = []
    }
    
    func requestTrackingCompletedAt(_ index: Int) {
        requestProcessTracking[safe: index]?.onCompleted()
    }
    
    func requestTrackingErrorAt(_ index: Int, error: Error) {
        requestProcessTracking[safe: index]?.onError(error)
    }
}

// MARK: - Support Method
extension BaseViewModel {
    
    private func getSupportedLanguage() {
        var listLanguageSupported: ListLanguageModel?
        let bundle = Bundle.main.path(forResource: "SupportedLanguage", ofType: "json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: bundle ?? ""), options: .mappedIfSafe)
            listLanguageSupported = ListLanguageModel(JSON: data.toJSON() ?? [String: Any]())
            supportedLanguage = listLanguageSupported?.languages ?? []
        } catch(let error) {
            print("Error when get supported language: \(error.localizedDescription)")
        }
    }
    
    func firstSetupLanguage() {
        // Load current device's language
        let currentLanguage = supportedLanguage.filter({$0.language == TranslationManager.shared.getDefaultLanguage() }).first
        
        if getDefaultLanguage(of: .fromLanguage) == nil && getDefaultLanguage(of: .toLanguage) == nil {
            // If default language nil, save the current language
            TranslationManager.shared.saveLanguage(type: .fromLanguage(currentLanguage ?? LanguageModel("English", "en")))
            TranslationManager.shared.saveLanguage(type: .toLanguage(currentLanguage ?? LanguageModel("English", "en")))
            fromLanguageBehavior.accept(currentLanguage?.name ?? "")
            toLanguageBehavior.accept(currentLanguage?.name ?? "")
        } else {
            // Load the last default language
            let fromLanguage = TranslationManager.shared.loadLanguage(for: .fromLanguage)
            let toLanguage = TranslationManager.shared.loadLanguage(for: .toLanguage)
            fromLanguageBehavior.accept(fromLanguage?.name ?? "")
            toLanguageBehavior.accept(toLanguage?.name ?? "")
        }
    }
    
    func getDefaultLanguage(of type: UserDefaultKey) -> LanguageModel? {
        guard let model = TranslationManager.shared.loadLanguage(for: type) else { return nil }
        return model
    }
}
