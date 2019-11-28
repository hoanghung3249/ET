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

class CameraViewController: BaseViewController {
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var previewVw: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var swapCameraButton: UIButton!
    var viewModel = CameraViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setupCamera(in: previewVw)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopRunningCamera()
    }
    
    override func bindingViewModel() {
        bindCommonAction(viewModel)
        
        viewModel.isFlashOn.asDriver()
            .drive(onNext: { [weak self] (isOn) in
                guard let self = self else { return }
                self.toggleFlashButton.setImage(isOn ? #imageLiteral(resourceName: "FlashOnIcon") : #imageLiteral(resourceName: "FlashOffIcon"), for: .normal)
            }).disposed(by: disposeBag)
    }
    
    override func observeSignal() {
        
        captureButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.viewModel.camera.capturePhoto()
            }).disposed(by: disposeBag)
        
        backView.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        selectPhotoButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                // Open photo library
                self.presentImagePicker()
            }).disposed(by: disposeBag)
        
        toggleFlashButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.viewModel.isFlashOn.accept(!(self.viewModel.isFlashOn.value))
            }).disposed(by: disposeBag)
        
        swapCameraButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.viewModel.camera.swapCamera()
            }).disposed(by: disposeBag)
    }
}


