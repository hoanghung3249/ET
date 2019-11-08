//
//  ListLanguageView.swift
//  ET
//
//  Created by HungNguyen on 11/8/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit

class ListLanguageView: BaseCustomView {

    @IBOutlet weak var vwBound: UIView!
    @IBOutlet weak var vwLanguage: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tbvListLanguage: UITableView!
    
    deinit {
        for gesture in vwBound.gestureRecognizers ?? [] { vwBound.removeGestureRecognizer(gesture) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        observeSignal()
        addGesture()
        setupTbv()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        observeSignal()
        addGesture()
        setupTbv()
    }
    
    func observeSignal() {
        btnDone.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in self?.animateDetailView(false) })
            .disposed(by: disposed)
    }
    
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        vwBound.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        animateDetailView(false)
    }
    
}

// MARK: - Support Method
extension ListLanguageView {
    
    private func setupTbv() {
        tbvListLanguage.dataSource = self
        tbvListLanguage.delegate = self
        let nib = UINib(nibName: "ListLanguageCell", bundle: nil)
        tbvListLanguage.register(nib, forCellReuseIdentifier: "ListLanguageCell")
    }
    
    func animateDetailView(_ isShow: Bool = true) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: { [weak self] in
            guard let self = self else { return }
            self.vwLanguage.frame.origin.y = isShow ? self.frame.origin.y + 120 : self.frame.size.height
            self.vwBound.alpha = isShow ? 0.3 : 0.0
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.layoutIfNeeded()
                if !(isShow) { self.removeFromSuperview() }
        })
    }
    
}

// MARK: - TableView Datasource & Delegate
extension ListLanguageView: UITableViewDataSource, UITableViewDelegate {
    
    private func modelFor(_ row: Int) -> LanguageModel { return supportedLanguage[safe: row] ?? LanguageModel() }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportedLanguage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ListLanguageCell.self, at: indexPath)
        cell.loadSupportedLanguage(modelFor(indexPath.row))
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.accessoryType = .none
//    }
    
}
