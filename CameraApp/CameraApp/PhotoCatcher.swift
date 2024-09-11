//
//  PhotoCap.swift
//  CameraApp
//
//  Created by kore omodara on 3/27/24.
//

import Foundation
import AVFoundation
import Photos


class PhotoCatcher: NSObject, AVCapturePhotoCaptureDelegate {
    
    var settings: AVCapturePhotoSettings
    var photoData: Data?
    
    init(settings: AVCapturePhotoSettings, photoData: Data? = nil) {
        self.settings = settings
        self.photoData = photoData
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: (any Error)?) {
        if let error = error {
            print(error)
            return
        }
        photoData = deferredPhotoProxy?.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error = error {
            print(error)
            return
        }
        
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        if let error = error {
            print(error)
            return
        }
        savePhotoDataToPhotoLibrary(resolvedSettings: resolvedSettings)
    }
    
    func savePhotoDataToPhotoLibrary(resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("savePhotoDataToPhotoLibrary")
        guard let data = photoData else {
            print("no photo data resource in saveDataToPhotoLibrary")
            return
        }
        
        //
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.uniformTypeIdentifier = self.settings.processedFileType.map { $0.rawValue }
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    var resourceType = PHAssetResourceType.photo
                    if (resolvedSettings.deferredPhotoProxyDimensions.width > 0) && 
                        (resolvedSettings.deferredPhotoProxyDimensions.height > 0) {
                        resourceType = PHAssetResourceType.photoProxy
                    }
                    
                    creationRequest.addResource(with: resourceType, data: data, options: options)
                },
                completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to library")
                        print(error.localizedDescription)
                    }
                    
                })
            }
        }
    }
}

    
