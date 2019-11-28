//
//  Camera.swift
//  ET
//
//  Created by HungNguyen on 11/27/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RxSwift

class CameraManager: NSObject {
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var previewView: UIView!
    var didCapturePhoto = PublishSubject<UIImage?>()
    
    private let minimumZoom: CGFloat = 1.0
    private let maximumZoom: CGFloat = 3.0
    private var lastZoomFactor: CGFloat = 1.0
    
    deinit {
        for gesture in previewView.gestureRecognizers ?? [] {
            previewView.removeGestureRecognizer(gesture)
        }
        previewView.removeFromSuperview()
    }
    
    init(_ previewView: UIView) {
        super.init()
        self.previewView = previewView
        setupCaptureSession()
        setupGesture()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        } catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch))
        previewView.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        let device = input.device

        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }

        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)

        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.videoPreviewLayer.frame = self.previewView.bounds
                }, completion: nil)
            }
        }
    }
    
    /// Take photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// Stop the session when finish
    func stopRunning() {
        self.captureSession.stopRunning()
    }
    
    /// Turn on/off flash of device
    func toggleFlash(isOn: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = isOn ? .on : .off
                device.unlockForConfiguration()
            } catch(let error) {
                print("Torch could not be used: \(error.localizedDescription)")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    /// Swap camera and reconfigures camera session with new input
    func swapCamera() {

        // Get current input
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }

        // Begin new session configuration and defer commit
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }

        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        // Swap capture device inputs
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
    }

    /// Create new capture device with requested position
    fileprivate func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        
            for device in devices {
                if device.position == position {
                    return device
                }
            }
        return nil
    }
    
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    // Handle photo output
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        let image = UIImage(data: imageData)
        didCapturePhoto.onNext(image)
    }
    
}
