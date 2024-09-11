//
//  CaptureHandler.swift
//  CameraApp
//
//  Created by kore omodara on 3/25/24.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreImage
import Vision

//= what it is : what it inherits from
@Observable
class CaptureHandler: NSObject {
    
    var frame: CGImage?
    private let context = CIContext()
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentCaptureDevice: AVCaptureDevice?
    private var currentCaptureInput: AVCaptureInput?
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var activePhotoSettings = AVCapturePhotoSettings()
    private var permissionGranted = false
    
    private let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTripleCamera, .builtInDualWideCamera, .builtInTrueDepthCamera, .builtInLiDARDepthCamera]
    var discoverySession: AVCaptureDevice.DiscoverySession?
    
    var preview: Preview?
    
    private var videoDeviceRotationCoordinator: AVCaptureDevice.RotationCoordinator!
    private var videoRotationAngleForHorizonLevelPreviewObservation: NSKeyValueObservation?
    
    private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .quality
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    var catcher: PhotoCatcher!
    
    var faces: [VNFaceObservation] = []
    var canvasFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var currentOrientation: InterfaceOrientation = .portrait
    
    var hands: [VNHumanHandPoseObservation] = []
    var gestureProcessor = HandGestureProcessor()
    var lastObservationTimestamp = Date()
    
    override init() {
        super.init()
        
        Task {
            await checkCameraPermission()
            self.configure()
            self.session.startRunning()
        }
        
    }
    
    func checkCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            //user has granted cam access
            permissionGranted = true
            
        case .notDetermined:
            // user hasnt been asked yet
            permissionGranted = await AVCaptureDevice.requestAccess(for: .video)
            
            //combine 2 other cases into default case
        default:
            permissionGranted = false
            
        }
    }
    
    func configure() {
        guard permissionGranted else { return }
        
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else
        { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        
        preview = Preview(session: session, gravity: .resizeAspect)
        
        if session.canAddInput(captureDeviceInput) {
            session.addInput(captureDeviceInput)
            videoDeviceInput = captureDeviceInput
            currentCaptureDevice = videoDevice
            currentCaptureInput = videoDeviceInput
            
            DispatchQueue.main.async {
                self.createDeviceRotationCoordinator()
            }
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        session.addOutput(videoOutput)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality //change to balanced?
            //will save lowres version proxy to device to free up app space and allow app to take more pics, then will maximize the rsolution once app is done taking pics
            photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
            photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
            photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
            
            activePhotoSettings = resetPhotoSettings()
        }
        
        session.commitConfiguration()
    }
    
    func capturePhoto() {
        
        let photoSettings = AVCapturePhotoSettings(from: activePhotoSettings)
        let videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelCapture
        
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoRotationAngle = videoRotationAngle
            }
            
            self.catcher = PhotoCatcher(settings: photoSettings)
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self.catcher)
        }
    }
    
    private func createDeviceRotationCoordinator() {
        videoDeviceRotationCoordinator = AVCaptureDevice.RotationCoordinator(device: videoDeviceInput.device, previewLayer: preview?.previewLayer)
        preview?.previewLayer.connection?.videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelPreview
        
        videoRotationAngleForHorizonLevelPreviewObservation = videoDeviceRotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) {
            _, change in
            
            guard let videoRotationAngleForHorizonLevelPreview = change.newValue else { return }
            
            self.preview?.previewLayer.connection?.videoRotationAngle = videoRotationAngleForHorizonLevelPreview
        }
    }
    
    func changeCameraInput(device: AVCaptureDevice) {
        if let captureInput = currentCaptureInput {
            session.removeInput(captureInput)
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device) else { return }
        guard session.canAddInput(videoDeviceInput) else { return }
        currentCaptureDevice = device
        currentCaptureInput = videoDeviceInput
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
    }
    
    func isCurrentInput(device: AVCaptureDevice) -> Bool {
        return device.uniqueID == currentCaptureDevice?.uniqueID
    }
    
    
    func resetPhotoSettings() -> AVCapturePhotoSettings {
        var photoSettings = AVCapturePhotoSettings()
        
        //capture heif photos when supported
        if photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        //set the flash to auto mode
        if videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }
        //Enable high res photos
        photoSettings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String:
                photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
//        //Setup url for live photo movie
//        if enableLivePhoto && photoOutput.isLivePhotoCaptureSupported {
//            //live photo is not supported in movie mode
//            photoSettings.livePhotoMovieFileURL = LivePhotoMovieUniqueTemporaryDirectoryFileURL()
//        }
        
        photoSettings.photoQualityPrioritization = photoQualityPrioritizationMode
        
        return photoSettings
    }
}

extension CaptureHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    //delegate method for capture, this method receives the pixels for the pixels in one frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        print("captureOutput")
        //change depending on whats detected
        //detectFace(image: cgImage, handler: handleFaces)
        detectHand(image: cgImage, handler: handleHandPoses)
        
        DispatchQueue.main.async { [self] in
            self.frame = cgImage
        }
    }
    //convert the pixel data into a CGimage
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}

extension CaptureHandler {
    
    func detectFace(image: CGImage, handler: @escaping VNRequestCompletionHandler) {
        let imageRequestHandler = VNImageRequestHandler(cgImage: image)
        let request = VNDetectFaceLandmarksRequest(completionHandler: handler)
       
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
    
    func handleFaces(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        
        DispatchQueue.main.async {
            self.checkPreviewSize()
            self.faces = observations
        }
    }
    
    func checkPreviewSize() {
        guard let activeFormat = currentCaptureDevice?.activeFormat else { return }
        
        guard let previewLayer = preview?.previewLayer else { return }
        let frame = previewLayer.frame
        
        if videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelPreview == 90 {
            //we are in portrait mode
            let captureW = Double(activeFormat.formatDescription.dimensions.height)
            let captureH = Double(activeFormat.formatDescription.dimensions.width)
            
            let scaleFactor = captureW / frame.width
            let w = captureW / scaleFactor
            let h = captureH / scaleFactor
            let x = (frame.width - w) / 2.0
            let y = (frame.height - h) / 2.0
            canvasFrame = CGRect(x: x, y: y, width: w, height: h)
            currentOrientation = .portrait
        }
        
    }
}

