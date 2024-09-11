//
//  MoviePlaylist.swift
//  MoviePlayer
//
//  Created by Loren Olson on 10/31/23.
//

import Foundation
import AVFoundation



class MediaPlaylist: Codable, ObservableObject {
    
    @Published var clips: [MediaClip] = []
    
    var composition: AVComposition?
    
    @Published var player: AVPlayer = AVPlayer()
    
    var insertTimes: [CMTime] = []
    
    enum CodingKeys: CodingKey {
        case clips
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        clips = try container.decode([MediaClip].self, forKey: .clips)
        
        self.player = AVPlayer()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clips, forKey: .clips)
    }
    
    init(clips: [MediaClip]) {
        self.clips = clips
    }
    
    func add(url: URL, completion: @escaping (MediaClip) -> Void) {
        Task { @MainActor in
            let asset = AVAsset(url: url)
            //guard let track = try await asset.loadTracks(withMediaType: .video).first else { return }
            var tracks: [AVAssetTrack] = []
            do {
                tracks = try await asset.loadTracks(withMediaType: .video)
                print("tracks.count = \(tracks.count)")
            }
            catch {
                print(error)
            }
            guard let track = tracks.first else {
                print("No video track.")
                return
            }
            do {
                print("track load")
                let rate = try await track.load(.nominalFrameRate)
                let clip = MediaClip(name: url.lastPathComponent, path: url.path(), rate: rate)
                print("load duration")
                let duration = try await asset.load(.duration)
                clip.outTime = ATime.fromCMTime(clip.inTime.cmtime + duration)
                print("load Thumbnail")
                try await clip.loadThumbNail()
                clips.append(clip)
                
                await createComposition()
                
                completion(clip)
            }
            catch {
                print(error);
            }
            
        }
        
    }
    
    func seekTo(clip: MediaClip){
        if let index = clips.firstIndex(of: clip) {
            if index >= insertTimes.count {
                print("warning, insertTimes.count is \(insertTimes.count)")
                return
            }
            player.seek(to: insertTimes[index])
        }
    }
    
    func remove(clip: MediaClip) {
        if let index = clips.firstIndex(of: clip){
            clips.remove(at: index)
        }
    }
    
    func createComposition() async {
        let comp = AVMutableComposition()
        let trackVideo = comp.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        let trackAudio = comp.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
        var insertTime = CMTime.zero
        insertTimes = []
        
        for clip in clips {
            let asset = AVAsset(url: clip.url)
            
            var videoTracks: [AVAssetTrack]
            var audioTracks: [AVAssetTrack]
            do {
                videoTracks = try await asset.loadTracks(withMediaType: .video)
                audioTracks = try await asset.loadTracks(withMediaType: .audio)
            }
            catch {
                print(error)
                continue
            }
            
            guard videoTracks.count > 0 && audioTracks.count > 0 else { return }
            
            let videoAssetTrack = videoTracks[0] as AVAssetTrack
            let audioAssetTrack = audioTracks[0] as AVAssetTrack
            
            do {
                try trackVideo?.insertTimeRange(clip.timeRange, of: videoAssetTrack, at: insertTime)
                try trackAudio?.insertTimeRange(clip.timeRange, of: audioAssetTrack, at: insertTime)
                insertTimes.append(insertTime)
            }
            catch {
                print("insertTimeRange failed")
                print(error)
                print("----")
                print(error.localizedDescription)
                // maybe this should return nil?
                continue
            }
            
            insertTime = insertTime + clip.timeRange.duration
        }
        
        let composition = comp.copy() as! AVComposition
        let playerItem = AVPlayerItem(asset: composition)
        self.composition = composition
        player = AVPlayer(playerItem: playerItem)
    }
    
    func export(preset: String = AVAssetExportPresetHighestQuality, fileType: AVFileType = .mp4, url: URL ) async {
        await createComposition()
        guard let composition = composition else { return }
        
        guard await AVAssetExportSession.compatibility(ofExportPreset: preset, with: composition, outputFileType: fileType) else {
            return
        }
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: preset) else {
            return
        }
        exportSession.outputFileType = fileType
        exportSession.outputURL = url
        
        await exportSession.export()
    }
}

extension MediaPlaylist {
    func save(url: URL) throws {
        let encoder = PropertyListEncoder()
        let codedPlaylist: Data = try encoder.encode(self)
        try codedPlaylist.write(to: url)
        
    }
    static func load(url: URL) throws -> MediaPlaylist {
        let codedPlaylist = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let playlist: MediaPlaylist = try decoder.decode(MediaPlaylist.self, from: codedPlaylist)
        return playlist
    }
}
