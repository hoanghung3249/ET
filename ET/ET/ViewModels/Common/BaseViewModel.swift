//
//  BaseViewModel.swift
//  ET
//
//  Created by HungNguyen on 10/30/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class BaseViewModel {
    let disposeBag = DisposeBag()
    let shouldReloadData = BehaviorRelay<Void?>(value: nil)
    let shouldReloadSections = BehaviorRelay<IndexSet?>(value: nil)
    let shouldReloadRows = BehaviorRelay<[IndexPath]?>(value: nil)
    lazy var activityIndicator = ActivityIndicator() // For checking loading status
    var requestProcessTracking: [PublishSubject<Void>] = [] // For tracking multithreads request
    let didRequestError = BehaviorRelay<Error?>(value: nil)
    
    // MARK: - Init BaseViewModel
    init() {
    }
    
    deinit {
        print("Deinit: \(type(of: self))")
    }
    
    /// Clear all data for refresh
    func clearAll() {} // Override
    
    /// Refresh data
    func refreshData() {
        clearAll()
    }
    
    func requestError(_ error: Error) {
        didRequestError.accept(error)
    }
    
    func reloadData() { shouldReloadData.accept(()) }
    
    func reloadSections(_ sections: IndexSet) { shouldReloadSections.accept(sections) }
    
    func reloadRows(_ rows: [IndexPath]) { shouldReloadRows.accept(rows) }
    
}

// ======================================================================
// MARK: - Request Tracking Flow
// ======================================================================
extension BaseViewModel {
    func clearRequestTracking() {
        requestProcessTracking = []
    }
    
    func requestTrackingCompletedAt(_ index: Int) {
        requestProcessTracking[safe: index]?.onCompleted()
    }
    
    func requestTrackingErrorAt(_ index: Int, error: Error) {
        requestProcessTracking[safe: index]?.onError(error)
    }
}
