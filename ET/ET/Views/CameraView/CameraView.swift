//
//  CameraView.swift
//  ET
//
//  Created by DUY HANDS0ME on 11/20/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import Photos

class CameraView: BaseViewController {
    
    @IBOutlet weak var vwLanguage: LanguageView!
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var switchCameras: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var backView: UIButton!
    //    var viewModel = TranslateViewModel()
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    //
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    //
    var photoOutput: AVCapturePhotoOutput?
    //
    var previewLayer: AVCaptureVideoPreviewLayer?
    //
    var flashMode = AVCaptureDevice.FlashMode.off
    //
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?

    override func bindingViewModel() {
        //        bindCommonAction(viewModel)
        //        viewModel.selectLanguageView.selectedLanguage.bind(to: vwLanguage.selectedLanguage).disposed(by: disposeBag)
        //
        //        vwLanguage.translateModel.asObservable()
        //            .subscribe(onNext: { [weak self] (model) in
        //                guard let self = self else { return }
        //                self.viewModel.translateModel = model
        //            }).disposed(by: disposeBag)
        captureButton.toCicle()
        configureCameraController()
        
    }
    
    override func observeSignal() {
        
        backView.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        toggleFlashButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if self.flashMode == .on {
                    self.flashMode = .off
                    self.toggleFlashButton.setImage(#imageLiteral(resourceName: "FlashOffIcon"), for: .normal)
                } else {
                    self.flashMode = .on
                    self.toggleFlashButton.setImage(#imageLiteral(resourceName: "FlashOnIcon"), for: .normal)
                }
            }).disposed(by: disposeBag)
        
        switchCameras.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                do {
                    try self.switchCamera()
                }
                catch {
                    print(error)
                }
                switch self.currentCameraPosition {
                case .some(.front):
                    self.switchCameras.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
                    
                case .some(.rear):
                    self.switchCameras.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
                    
                case .none:
                    return
                }
            }).disposed(by: disposeBag)
        
        captureButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.captureImage {(image, error) in
                    guard let image = image else {
                        print(error ?? "Image capture error")
                        return
                    }
                    try? PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }
                }
            }).disposed(by: disposeBag)
    }
}
extension CameraView {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            if let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified).devices.first {
                let cameras = [session]
                for camera in cameras {
                    if camera.position == .front {
                        self.frontCamera = camera
                    }
                    
                    if camera.position == .back {
                        self.rearCamera = camera
                        
                        try camera.lockForConfiguration()
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            } else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
        }
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
}
// MARK: - Camera
extension CameraView {
    func switchCamera() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)

            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            } else { throw CameraControllerError.invalidOperation }
        }
        
        func switchToRearCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            } else { throw CameraControllerError.invalidOperation }
        }
    
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
        
    }
}
//MARK: - CaptureImage
extension CameraView {
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
}
extension CameraView: AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = UIImage(data: photo.fileDataRepresentation()!)
            self.photoCaptureCompletionBlock?(imageData, nil)
    }
}
extension CameraView {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    func configureCameraController() {
        self.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.displayPreview(on: self.capturePreviewView)
        }
    }
}
// Vision
extension CameraView {
    func handle(buffer: CMSampleBuffer) {
      guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
        return
      }

      let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
      guard let image = ciImage.toUIImage() else {
        return
      }

//      makeRequest(image: image)
    }
    
}
