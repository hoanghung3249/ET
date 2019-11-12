//
//  TranslateModel.swift
//  ET
//
//  Created by HungNguyen on 11/11/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import ObjectMapper

class ListTranslateModel: Mappable {
    var translations: [TranslateModel] = []
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        translations       <- map["translations"]
    }
}

class TranslateModel: Mappable {
    var sourceLanguage = ""
    var sourceText = ""
    var target = ""
    
    var translatedText: String?
    var detectedSourceLanguage: String?
    
    
    init() {}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        translatedText                      <- map["translatedText"]
        detectedSourceLanguage              <- map["detectedSourceLanguage"]
    }
}
