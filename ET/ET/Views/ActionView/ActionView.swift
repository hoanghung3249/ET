//
//  ActionView.swift
//  ET
//
//  Created by HungNguyen on 11/4/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ActionView: BaseCustomView {
    
    @IBOutlet var actionButtons: [UIButton]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setupSelectedButton()
//        addGesture()
//        observeSignal()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setupSelectedButton()
//        addGesture()
//        observeSignal()
    }
    
    private func setupSelectedButton() {
        guard let button = actionButtons.first else { return }
        button.isSelected = true
        setColorSelected(for: button, true)
    }
    
    @IBAction func actionButtonsTap(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = !sender.isSelected
        setColorSelected(for: sender, sender.isSelected)
        unSelectedButton(sender.tag)
    }
    
}

// MARK: - Support Method
private extension ActionView {
    
    func setColorSelected(for button: UIButton, _ isSelected: Bool) {
        button.setTitleColor(isSelected ? Color.mainColor() : .white
            , for: isSelected ? .selected : .normal)
        button.tintColor = isSelected ? Color.mainColor() : .white
        button.backgroundColor = isSelected ? .white : Color.unSelectedButton()
    }
    
    func unSelectedButton(_ tag: Int) {
        let arrButtons = actionButtons.filter({$0.tag != tag})
        arrButtons.forEach { [weak self] (button) in
            guard let self = self else { return }
            button.isSelected = false
            self.setColorSelected(for: button, false)
        }
    }
}
