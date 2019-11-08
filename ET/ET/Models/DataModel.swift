//
//  DataModel.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import ObjectMapper

class DataModel<T>: Mappable where T: BaseMappable {
    
    var data: T?
    
    func mapping(map: Map) {
        data        <- map["data"]
    }
    
    required init?(map: Map) {}
}
