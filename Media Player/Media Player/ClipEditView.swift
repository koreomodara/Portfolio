//
//  ClipEditView.swift
//  Media Player
//
//  Created by kore omodara on 11/9/23.
//

import SwiftUI
import AVKit

struct ClipEditView: View {
    @EnvironmentObject var clipData: ClipData
    @State var clip: MediaClip
    @State var inTimeDisplay: String = "-"
    @State var outTimeDisplay: String = "-"
    @State var currentTimeDisplay: String = "-"
    
    var body: some View {
        VStack {
            VideoPlayer(player: clip.player)
            HStack {
                Button(action: {
                    let ct = clip.player.currentTime()
                    clip.inTime = ATime.fromCMTime(ct)
                    Task { @MainActor in
                        await clipData.playlist.createComposition()
                    }
                }, label: {
                Text("In")
                })
                
                Text(inTimeDisplay)
                    .monospaced()
                
                //out button
                
                Button(action: {
                    let ct = clip.player.currentTime()
                    clip.inTime = ATime.fromCMTime(ct)
                    Task { @MainActor in
                        await clipData.playlist.createComposition()
                    }
                }, label: {
                    Text("Out")
                })
                Text(outTimeDisplay)
                    .monospaced()
                
                Spacer()
                
                Text(currentTimeDisplay)
                    .monospaced()
            }
            .padding(5)
        }
        .onAppear {
            inTimeDisplay = clip.inTimeDisplay
            outTimeDisplay = clip.outTimeDisplay
            currentTimeDisplay = Timecode(time: clip.player.currentTime(), rate: clip.rate).display
            let interval = CMTime(value: 1, timescale: CMTimeScale(clip.rate))
            clip.player.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { time in
                self.currentTimeDisplay = Timecode(time: time, rate: clip.rate).display
            })
        }
    }
}

//#Preview {
  //  ClipEditView()
//}
