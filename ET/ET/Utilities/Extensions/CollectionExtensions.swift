//
//  CollectionExtensions.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        var i = self.startIndex
        while i != self.endIndex {
            if i == index {
                return self[index]
            }
            i = self.index(after: i)
        }
        return nil
    }
}
