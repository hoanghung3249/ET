//
//  CameraViewController.swift
//  ET
//
//  Created by DUY HANDS0ME on 11/25/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import Photos
import Vision

class CameraViewController: BaseViewController {
    @IBOutlet weak var vwLanguage: LanguageView!
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var switchCameras: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var backView: UIButton!
    let camera = CameraManager()
    var requests = [VNRequest]()
    
    override func configuration() {
        captureButton.toCicle()
        setupLanguageView()
        configureCameraController()
    }
    
    override func observeSignal() {
        
        backView.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.remove()
//                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        toggleFlashButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if self.camera.flashMode == .on {
                    self.camera.flashMode = .off
                    self.toggleFlashButton.setImage(#imageLiteral(resourceName: "FlashOffIcon"), for: .normal)
                } else {
                    self.camera.flashMode = .on
                    self.toggleFlashButton.setImage(#imageLiteral(resourceName: "FlashOnIcon"), for: .normal)
                }
            }).disposed(by: disposeBag)
        
        captureButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.camera.captureImage { [weak self](image, error) in
                    guard let _ = self,let image = image else {
                        print(error ?? "Image capture error")
                        return
                    }
                    try? PHPhotoLibrary.shared().performChangesAndWait {
                        print(image)
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Support method
private extension CameraViewController {
    
    func setupLanguageView() {
        vwLanguage.vwSuper.backgroundColor = .clear
        vwLanguage.lblFromLanguage.textColor = .white
        vwLanguage.lblToLanguage.textColor = .white
        vwLanguage.imgReverse.image = UIImage(named: "reverse@2x")
    }
    
    func configureCameraController() {
        camera.prepare { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
            }
            try? self.camera.displayPreview(on: self.capturePreviewView)
        }
    }
}
