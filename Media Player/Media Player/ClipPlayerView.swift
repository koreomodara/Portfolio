//
//  ClipPlayerView.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import SwiftUI
import AVKit

struct ClipPlayerView: View {
    @StateObject var playlist: MediaPlaylist
    var body: some View {
        VStack {
            VideoPlayer(player: playlist.player)
            HStack {
                //buttons
            }
        }
    }
}

//#Preview {
   // ClipPlayerView()
//}
