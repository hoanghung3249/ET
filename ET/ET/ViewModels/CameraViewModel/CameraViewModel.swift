//
//  CameraViewModel.swift
//  ET
//
//  Created by HungNguyen on 11/27/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CameraViewModel: BaseViewModel {
    var camera: CameraManager!
    var didCapturePhoto = PublishSubject<UIImage?>()
    let isFlashOn = BehaviorRelay<Bool>(value: false)
    
    override init() {
        super.init()
        
        didCapturePhoto.asObservable().subscribe(onNext: { [weak self] (image) in
            guard let self = self, let image = image else { return }
            self.detectText(from: image)
        }).disposed(by: disposeBag)
        
        isFlashOn.asObservable().subscribe(onNext: { [weak self] (isOn) in
            guard let self = self, self.camera != nil else { return }
            self.camera.toggleFlash(isOn: isOn)
        }).disposed(by: disposeBag)
    }
    
    func setupCamera(in previewView: UIView) {
        camera = CameraManager(previewView)
        camera.didCapturePhoto.bind(to: didCapturePhoto).disposed(by: disposeBag)
    }
    
    func stopRunningCamera() { camera.stopRunning() }
    
}
