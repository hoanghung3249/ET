//
//  ExtensionDictionary.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation

extension Dictionary {
    func toData() -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data
        } catch (let error) {
            print("Cannot convert dictionary to data: \(error.localizedDescription)")
            return nil
        }
    }
}
