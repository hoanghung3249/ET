//
//  ListLanguageCell.swift
//  ET
//
//  Created by HungNguyen on 11/8/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit

class ListLanguageCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadSupportedLanguage(_ model: LanguageModel) {
        lblName.text = model.name ?? ""
        self.accessoryType = model.selected ? .checkmark : .none
    }

}
