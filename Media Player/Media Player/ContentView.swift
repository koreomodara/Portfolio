//
//  ContentView.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var clipData: ClipData
    //@Binding var clips: [MediaClip]
    @StateObject var playlist: MediaPlaylist
    //@State private var selectedClip: MediaClip?
    //@State private var isImporting: false
    
    
    var body: some View {
        NavigationStack {
            HStack (spacing:0){
                PlaylistView(clips: $playlist.clips, playlist: playlist)
                    .frame(minWidth: 300, maxWidth: 400)
                ClipPlayerView(playlist: playlist)
                
            }
        }
        
    }
}
//#Preview {
//   ContentView()
//
