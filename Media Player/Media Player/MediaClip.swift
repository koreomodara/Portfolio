//
//  MediaClip.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import Foundation
import AVFoundation
import SwiftUI

class MediaClip: Codable, ObservableObject {
   
    
    var id: UUID
    var name: String
    var path: String
    
    var url: URL {
        get{
            return URL(fileURLWithPath: path)
        }
    }
    
    var rate: Float = 1.0
    
    var inTime: ATime
    var outTime: ATime
    
    var timeRange: CMTimeRange {
        get {
            return CMTimeRange(start: inTime.cmtime, end: outTime.cmtime)
        }
        set {
            inTime.cmtime = newValue.start
            outTime.cmtime = newValue.end
        }
    }
    
    var thumbNail: Image {
        
        get {
            if let thumbNailCached = thumbNailCached {
                return thumbNailCached
            }
            else {
                return Image(systemName: "photo")
            }
        }
    }
    
    @Published var thumbNailCached: Image?
    
    
    var inTimeDisplay: String {
        Timecode(time: inTime.cmtime, rate: rate).display
    }
    
    var outTimeDisplay: String {
        Timecode(time: outTime.cmtime, rate: rate).display
    }
    
    var player: AVPlayer
    
    enum CodingKeys: CodingKey {
        case id, name, path, rate, inTime, outTime
    }
    
    init(id: UUID, name: String, path: String, rate: Float){
        self.id = id
        self.name = name
        self.path = path
        self.rate = rate
        inTime = ATime.zero
        outTime = ATime.zero
       player = AVPlayer()
        player = AVPlayer(url: url)
        
    }
    
    convenience init(name: String, path: String, rate: Float){
        self.init(id:UUID(), name: name, path: path, rate: rate )
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.path = try container.decode(String.self, forKey: .path)
        self.name = try container.decode(String.self, forKey: .name)
        self.rate = try container.decode(Float.self, forKey: .rate)
        self.inTime = try container.decode(ATime.self, forKey: .inTime)
        self.outTime = try container.decode(ATime.self, forKey: .outTime)
        player = AVPlayer()
         player = AVPlayer(url: url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.path, forKey: .name)
        try container.encode(self.rate, forKey: .rate)
        try container.encode(self.inTime, forKey: .inTime)
        try container.encode(self.outTime, forKey: .outTime)
        try container.encode(self.name, forKey: .name)
        
    }
    
    func loadThumbNail() async throws{
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        let image = try await generator.image(at: .zero).image
        self.thumbNailCached = Image(image, scale: 1.0, label: Text(name))
        
    }
}
    
    extension MediaClip: Hashable {
        static func == (lhs: MediaClip, rhs: MediaClip) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
}
