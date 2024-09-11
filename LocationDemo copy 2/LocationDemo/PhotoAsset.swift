//
//  PhotoAsset.swift
//  LocationDemo
//
//  Created by kore omodara on 3/18/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class PhotoAsset: Codable, Identifiable, Hashable {
    
    let id: UUID
    
    //url to the image fiel on storage
    var url: URL
    
    var absoluteURL: URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectoryURL!.appending(component: url.path())
    }
    
    var contentType: UTType
    
    var image: Image {
        return Image(uiImage: uiImage)
    }
    
    var sourceImage: UIImage?
    
    var uiImage: UIImage {
        if sourceImage == nil {
            if let img = UIImage(contentsOfFile: absoluteURL.path()) {
                sourceImage = img
                return img
            }
            else {
                return UIImage(systemName: "photo")!
            }
        }
        else {
            return sourceImage!
        }
    }
    
    init(id: UUID, url: URL, contentType: UTType, sourceImage: UIImage? = nil) {
        self.id = id
        self.url = url
        self.contentType = contentType
        self.sourceImage = sourceImage
    }
    
    convenience init(url: URL, contentType: UTType) {
        self.init(id: UUID(), url: url, contentType: contentType, sourceImage: nil)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case contentType
    }
    
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
       lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PhotoAsset: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .jpeg, importing: { received in
            return copyRecFile(received, contentType: .jpeg)
            
        })
        
        FileRepresentation(importedContentType: .png, importing: { received in
            return copyRecFile(received, contentType: .png)
            
        })
        
        FileRepresentation(importedContentType: .heic, importing: { received in
            return copyRecFile(received, contentType: .heic)
            
        })
    }
    
    static func copyRecFile(_ received: ReceivedTransferredFile, contentType: UTType) -> PhotoAsset {
        let now = Date().formatted(Date.ISO8601FormatStyle().timeSeparator(.omitted).dateSeparator(.dash))
        let name = "\(now)-\(received.file.lastPathComponent)"
        guard let assetUrl = URL(string: name) else {
            return PhotoAsset(url: URL(string: "missing")!, contentType: contentType)
        }
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let copyDst = documentsDirectoryURL!.appending(path: assetUrl.path())
        
        try? FileManager.default.copyItem(at: received.file, to: copyDst)
        
        return PhotoAsset(url: assetUrl, contentType: contentType)
    }
    
    func deleteFile() {
        do {
            try FileManager.default.removeItem(at: absoluteURL)
            print("succez")
        }
        catch {
            print(error)
        }
    }
}
