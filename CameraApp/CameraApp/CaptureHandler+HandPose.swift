//
//  CaptureHandler+HandPose.swift
//  CameraApp
//
//  Created by kore omodara on 4/3/24.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreImage
import Vision

extension CaptureHandler {
    
    func detectHand(image: CGImage, handler: @escaping VNRequestCompletionHandler) {
        let imageRequestHandler = VNImageRequestHandler(cgImage: image)
        let request = VNDetectHumanHandPoseRequest(completionHandler: handler)
       
        print("detectHand")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            }
            catch let error as NSError {
                print(error)
                return
            }
        }
    }
    
    func handleHandPoses(request: VNRequest, error: Error?) {
        print("handleHandPoses")
        guard let observations = request.results as? [VNHumanHandPoseObservation] else { return }
        
        
        for observation in observations {
            do {
                let thumbPoints = try observation.recognizedPoints(.thumb)
                let indexPoints = try observation.recognizedPoints(.indexFinger)
                
                guard let thumbTipPoint = thumbPoints[.thumbTip],
                      let indexTipPoint = indexPoints[.indexTip] else { return }
                
                guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else { return }
                
                let thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
                let indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
                DispatchQueue.main.async {
                    self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
                }
            }
            catch {
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.checkPreviewSize()
            self.hands = observations
        }
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            return
        }
        lastObservationTimestamp = Date()
        
        guard let previewLayer = preview?.previewLayer else { return }
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
}
