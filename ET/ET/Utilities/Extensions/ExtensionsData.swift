//
//  ExtensionsData.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation

extension Data {
    func toJSON() -> [String: Any]? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [String: Any] else { return nil }
            return json
        } catch (let error) {
            print("Error when convert data to dictionary \(error)")
            return nil
        }
    }
}
