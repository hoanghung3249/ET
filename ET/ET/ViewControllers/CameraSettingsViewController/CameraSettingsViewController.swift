//
//  CameraSettingsViewController.swift
//  ET
//
//  Created by DUY HANDS0ME on 11/26/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import UIKit
import CameraKit_iOS

class CameraSettingsViewController: UITableViewController {

   var previewView: CKFPreviewView!
    @IBOutlet weak var cameraSegmentControl: UISegmentedControl!
    @IBOutlet weak var flashSegmentControl: UISegmentedControl!
    @IBAction func handleCamera(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            session.cameraPosition = sender.selectedSegmentIndex == 0 ? .back : .front
        }
    }
    @IBAction func handleFlash(_ sender: UISegmentedControl) {
        if let session = self.previewView.session as? CKFPhotoSession {
            let values: [CKFPhotoSession.FlashMode] = [.auto, .on, .off]
            session.flashMode = values[sender.selectedSegmentIndex]
        }
    }
}
