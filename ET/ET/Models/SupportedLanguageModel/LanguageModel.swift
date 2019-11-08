//
//  LanguageModel.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import ObjectMapper

class ListLanguageModel: Mappable {
    var languages: [LanguageModel] = []
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        languages       <- map["languages"]
    }
    
}

class LanguageModel: Mappable {
    
    var language: String?
    var name: String?
    var selected: Bool = false
    
    init() {}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        language        <- map["language"]
        name            <- map["name"]
    }
}
