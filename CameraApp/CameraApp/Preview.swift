//
//  Preview.swift
//  CameraApp
//
//  Created by kore omodara on 3/25/24.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

struct Preview: UIViewControllerRepresentable {
    
    let previewLayer: AVCaptureVideoPreviewLayer
    let gravity: AVLayerVideoGravity
    
    init(session: AVCaptureSession, gravity: AVLayerVideoGravity) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.gravity = gravity
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PreviewViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        previewLayer.videoGravity = gravity
        uiViewController.view.layer.addSublayer(previewLayer)
        previewLayer.frame = uiViewController.view.bounds
    }
    
    //FIXED IT - 
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: ()) {
        if let pLayer = uiViewController.view.layer.sublayers?.first {
            pLayer.removeFromSuperlayer()
        }
    }
}

class PreviewViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        //when rotation happens, we need to reset the preview layer frame
        //works on the assumptoin that preview layer is the first layer on the vie 
        if let pLayer = view.layer.sublayers?.first {
            pLayer.frame = self.view.frame
        }
    }
}
