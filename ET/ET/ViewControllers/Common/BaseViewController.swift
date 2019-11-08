//
//  BaseViewController.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BaseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView?
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("Deinit ViewController: \(type(of: self))")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        configuration()
        bindingViewModel()
        observeSignal()
        localizeText()
        setupTableView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawLayout()
    }
    
    // MARK: - Configuration
    func configuration() {
    }
    
    func setUpIphoneSEScreen() {
        // Override
    }
    
    func localizeText() {
        // Override
    }
    
    func bindingViewModel() {
        // Override

    }
    
    func observeSignal() {
        // Override
    }
    
    // Use when need setup UI when init View
    func updateUI() {
        // Override
    }
    
    // Use to re-draw layout
    func redrawLayout() {
        // Override
    }
    
    // MARK: - Binding
    func bindCommonAction(_ viewModel: BaseViewModel) {
        bindLoadingHub(model: viewModel)
        
        // Reload tableview, collectionview
        viewModel.shouldReloadData
            .asDriver()
            .drive(onNext: { [weak self] reload in
                guard let self = self, reload != nil else { return }
                self.tableView?.reloadData()
                self.collectionView?.reloadData()
            }).disposed(by: disposeBag)
        
        // Reload tableView row
        viewModel.shouldReloadRows.asDriver()
            .drive(onNext: { [weak self] (indexPaths) in
                guard let self = self, let indexPaths = indexPaths else { return }
                self.tableView?.reloadRows(at: indexPaths, with: .automatic)
                self.collectionView?.reloadItems(at: indexPaths)
            }).disposed(by: disposeBag)
        
        // Reload tableView section
        viewModel.shouldReloadSections.asDriver()
            .drive(onNext: { [weak self] sections in
                guard let self = self, let sections = sections else { return }
                self.tableView?.reloadSections(sections, with: .none)
                self.collectionView?.reloadSections(sections)
            }).disposed(by: disposeBag)
        
        // Handle error
        viewModel.didRequestError.asDriver()
            .drive(onNext: { [weak self] error in
                guard let _ = self, let error = error else { return }
                print("show error")
            }).disposed(by: disposeBag)
    }
    
    func setupTableView() {
        //Override
    }
    
    func setupCollectionView() {
        //Override
    }
    
    func setupNavigation() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}

// MARK: - BaseViewController Extension
extension BaseViewController {
    
    func bindLoadingHub(model: BaseViewModel) {
        model.activityIndicator.asDriver()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (active) in
                guard let self = self else { return }
                if active {
                    // Show loading
                    self.showLoading()
                } else {
                    // Hide loading
                    self.hideLoading()
                }
            }).disposed(by: disposeBag)
    }
    
    func showLoading() {
        ProgressView.shared.show(self.view)
    }
    
    func hideLoading() {
        ProgressView.shared.hide()
    }
}
