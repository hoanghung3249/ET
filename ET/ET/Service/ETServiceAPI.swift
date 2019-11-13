//
//  ETServiceAPI.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum ETServiceAPI {
    
    case supportedLanguge
    case translate(_ translateModel: TranslateModel)
    
}

extension ETServiceAPI: TargetType {
    var baseURL: URL {
        return URL(string: APIURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .supportedLanguge: return APIURL.supportedLanguage
        case .translate: return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .supportedLanguge, .translate:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var params: [String: Any] {
        var param = [String: Any]()
        param.updateValue(Constant.APIKey, forKey: "key")
        switch self {
        case .supportedLanguge:
            param.updateValue(TranslationManager.shared.getDefaultLanguage(), forKey: "target")
        case .translate(let model):
            param.updateValue("text", forKey: "format")
            param.updateValue(model.sourceText, forKey: "q")
            param.updateValue(model.target, forKey: "target")
            param.updateValue(model.sourceLanguage, forKey: "source")
        }
        return param
    }
    
    var task: Task {
        switch self {
        case .supportedLanguge, .translate:
            return .requestParameters(parameters: params, encoding: URLEncoding())
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    
    
}
