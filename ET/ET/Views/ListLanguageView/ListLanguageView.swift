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
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedIndex = 1
    var languageName = ""
    var isSearching = false
    let inputLanguage = PublishRelay<LanguageModel>()
    let selectedLanguage = PublishRelay<(Int, String)>()
    private var listLanguage = [LanguageModel]()
    private var fillerListLanguage = [LanguageModel]()
    
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
        setupSearchBar()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        observeSignal()
        addGesture()
        prepareLanguage()
        setupTbv()
        setupSearchBar()
        
    }
    
    func observeSignal() {
        inputLanguage.asObservable().subscribe(onNext: { [weak self] (model) in
            guard let self = self else { return }
            if self.isSearching {
                let index = self.fillerListLanguage.firstIndex(where: {$0.name == model.name})
                self.markLanguage(index ?? 0)
            } else {
                let index = self.listLanguage.firstIndex(where: {$0.name == model.name})
                self.markLanguage(index ?? 0)
            }
        }).disposed(by: disposed)
        
        btnDone.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedLanguage.accept((self.selectedIndex, self.getSelectedLanguage()))
                self.animateDetailView(false)
                self.searchBar.text = ""
                self.isSearching = false
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
    
    private func prepareLanguage() {
        if isSearching {
            fillerListLanguage = supportedLanguage
        } else {
            listLanguage = supportedLanguage
        }
    }
    
    private func getSelectedLanguage() -> String {
        return isSearching ? fillerListLanguage.first(where: {$0.selected})?.name ?? "" : listLanguage.first(where: {$0.selected})?.name ?? ""
    }
    
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
// MARK: - SearchBar Delegate

extension ListLanguageView:UISearchBarDelegate {
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Tìm kiếm"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.isSearching = false
            self.fillerListLanguage.removeAll()
        } else {
            self.isSearching = true
            self.fillerListLanguage = listLanguage.filter({ (language) -> Bool in
                let name = language.name ?? ""
                let searchName = name.lowercased().contains(searchText.lowercased())
                return searchName
            })
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tbvListLanguage.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
}

// MARK: - TableView Datasource & Delegate
extension ListLanguageView: UITableViewDataSource, UITableViewDelegate {
    private func modelFor(_ row: Int) -> LanguageModel {
        return isSearching ? fillerListLanguage[safe: row] ?? LanguageModel() : listLanguage[safe: row] ?? LanguageModel()
    }
    
    private func markLanguage(_ index: Int) {
        if isSearching {
            fillerListLanguage.forEach { $0.selected = false } ; fillerListLanguage[index].selected = true
        } else {
            listLanguage.forEach { $0.selected = false } ; listLanguage[index].selected = true
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tbvListLanguage.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? fillerListLanguage.count : listLanguage.count
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
