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
    
}

extension ETServiceAPI: TargetType {
    var baseURL: URL {
        return URL(string: APIURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .supportedLanguge: return APIURL.supportedLanguage
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .supportedLanguge: return .get
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
            param.updateValue(Locale.current.languageCode ?? "en", forKey: "target")
        }
        return param
    }
    
    var task: Task {
        switch self {
        case .supportedLanguge:
            return .requestParameters(parameters: params, encoding: URLEncoding())
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    
    
}
