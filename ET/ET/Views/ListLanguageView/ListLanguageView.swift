//
//  ListLanguageView.swift
//  ET
//
//  Created by HungNguyen on 11/8/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import RxCocoa

class ListLanguageView: BaseCustomView {

    @IBOutlet weak var vwBound: UIView!
    @IBOutlet weak var vwLanguage: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tbvListLanguage: UITableView!
    var selectedIndex = 1
    var languageName = ""
    let inputLanguage = PublishRelay<LanguageModel>()
    let selectedLanguage = PublishRelay<(Int, String)>()
    private var listLanguage = [LanguageModel]()
    
    deinit {
        for gesture in vwBound.gestureRecognizers ?? [] { vwBound.removeGestureRecognizer(gesture) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        observeSignal()
        addGesture()
        prepareLanguage()
        setupTbv()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        observeSignal()
        addGesture()
        prepareLanguage()
        setupTbv()
    }
    
    func observeSignal() {
        inputLanguage.asObservable().subscribe(onNext: { [weak self] (model) in
            guard let self = self else { return }
            let index = self.listLanguage.firstIndex(where: {$0.name == model.name})
            self.markLanguage(index ?? 0)
            }).disposed(by: disposed)
        
        btnDone.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedLanguage.accept((self.selectedIndex, self.getSelectedLanguage()))
                self.animateDetailView(false)
            }).disposed(by: disposed)
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
    
    private func prepareLanguage() { listLanguage = supportedLanguage }
    
    private func getSelectedLanguage() -> String { return listLanguage.first(where: {$0.selected})?.name ?? "" }
    
    func animateDetailView(_ isShow: Bool = true) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: { [weak self] in
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
    
    private func modelFor(_ row: Int) -> LanguageModel { return listLanguage[safe: row] ?? LanguageModel() }
    
    private func markLanguage(_ index: Int) {
        listLanguage.forEach { $0.selected = false }
        listLanguage[index].selected = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tbvListLanguage.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listLanguage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ListLanguageCell.self, at: indexPath)
        cell.loadSupportedLanguage(modelFor(indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        markLanguage(indexPath.row)
    }
    
}
