//
//  DataManager.swift
//  ET
//
//  Created by HungNguyen on 11/12/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    func saveData(_ languageDic: [String: Any], _ key: String) {
        let userDefault = UserDefaults.standard
        
        if userDefault.value(forKey: key) != nil { userDefault.removeObject(forKey: key) }
        
        let userData = NSKeyedArchiver.archivedData(withRootObject: languageDic)
        userDefault.set(userData, forKey: key)
        userDefault.synchronize()
    }
    
    func removeData(for key: String) {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: key)
        userDefault.synchronize()
    }
    
    func getData(for key: String) -> [String: Any]?{
        let userDefault = UserDefaults.standard
        if let languageData = userDefault.value(forKey: key) as? Data{
            let languageDic = NSKeyedUnarchiver.unarchiveObject(with: languageData) as? [String: Any]
            return languageDic
        }
        return nil
    }
}
