//
//  TranslationManager.swift
//  ET
//
//  Created by HungNguyen on 11/12/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum LanguageType {
    case fromLanguage(_ model: LanguageModel)
    case toLanguage(_ model: LanguageModel)
}

enum UserDefaultKey {
    case fromLanguage
    case toLanguage
}

extension UserDefaultKey {
    var key: String {
        switch self {
        case .fromLanguage: return "from"
        case .toLanguage: return "to"
        }
    }
}

class TranslationManager {
    
    static let shared = TranslationManager()
    
    func getDefaultLanguage() -> String { return Locale.current.languageCode ?? "en" }
    
    func saveLanguage(type languageType: LanguageType) {
        switch languageType {
        case .fromLanguage(let model):
            DataManager.shared.saveData(model.toJSON(), UserDefaultKey.fromLanguage.key)
        case .toLanguage(let model):
            DataManager.shared.saveData(model.toJSON(), UserDefaultKey.toLanguage.key)
        }
    }
    
    func loadLanguage(for type: UserDefaultKey) -> LanguageModel? {
        var param: [String: Any]?
        switch type {
        case .fromLanguage:
            param = DataManager.shared.getData(for: UserDefaultKey.fromLanguage.key)
        case .toLanguage:
            param = DataManager.shared.getData(for: UserDefaultKey.toLanguage.key)
        }
        
        guard let params = param else { return nil }
        return LanguageModel(JSON: params)
    }
    
}
