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
import CameraKit_iOS

class CameraViewController: BaseViewController {
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var panelView: UIVisualEffectView!
    @IBOutlet weak var handleSwipeUp: UIButton!
    @IBOutlet weak var handleCapture: UIButton!
    @IBOutlet weak var handlePhoto: UIButton!
    @IBOutlet weak var previewView: CKFPreviewView!
    // vision
    var requests = [VNRequest]()

    override func configuration() {
        preView()
        setupPanelView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView.session?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.session?.stop()
    }
    
    override func observeSignal() {
        
        backView.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        handleSwipeUp.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.panelView.isUserInteractionEnabled = true
                self.handleCapture.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2) {
                    self.panelView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            }).disposed(by: disposeBag)
        
        handleCapture.rx.tap.asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if let session = self.previewView.session as? CKFPhotoSession {
                    session.capture({ (image, _) in
                        print(image)
                        self.startTextDetection()
                    }) { (_) in
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func handleSwipeDown(_ sender: Any) {
        self.panelView.isUserInteractionEnabled = false
        self.handleCapture.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.panelView.transform = CGAffineTransform(translationX: 0, y: self.panelView.frame.height)
        }
    }
    
}
extension CameraViewController:CKFSessionDelegate {
    func didChangeValue(session: CKFSession, value: Any, key: String) {
        print(key)
    }
    
    func preView(){
        let session = CKFPhotoSession()
        session.resolution = CGSize(width: 3024, height: 4032)
        session.delegate = self
        
        self.previewView.autorotate = true
        self.previewView.session = session
        self.previewView.previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func setupPanelView() {
        self.panelView.transform = CGAffineTransform(translationX: 0, y: self.panelView.frame.height + 5)
        self.panelView.isUserInteractionEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
extension CameraViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CameraSettingsViewController {
            vc.previewView = self.previewView
        }
    }
}
// textDetection
extension CameraViewController {
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
    }

    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        let result = observations.map({$0 as? VNTextObservation})
        print(result)
    }

}
// Truyền dữ liệu từ camera tới detector
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.right, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
            print(self.requests)
        } catch {
            print(error)
        }
    }
}


// MARK: - Vision
//@available(iOS 13.0, *)
//extension CameraViewController {
//    func visionText(_ img:UIImage) {
//        let request = VNRecognizeTextRequest { request, error in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else {
//                fatalError("Received invalid observations")
//            }
//
//            for observation in observations {
//                guard let bestCandidate = observation.topCandidates(1).first else {
//                    print("No candidate")
//                    continue
//                }
//
//                print("Found this candidate: \(bestCandidate.string)")
//            }
//        }
//        let requests = [request]
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let img = img.cgImage else {
//                fatalError("Missing image to scan")
//            }
//
//            let handler = VNImageRequestHandler(cgImage: img, options: [:])
//            try? handler.perform(requests)
//            print(requests)
//        }
//
//    }
//
//}
