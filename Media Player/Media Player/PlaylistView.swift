//
//  PlaylistView.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject var clipData: ClipData
    @Binding var clips: [MediaClip]
    @StateObject var playlist: MediaPlaylist
    @State private var selectedClip: MediaClip?
    @State private var isImporting = false
    
    var body: some View {
        VStack {
            List(selection: $selectedClip){
                ForEach(clips, id: \.id) { clip in
                   MediaClipRow(clip: clip)
                    //Text(clip.name)
                        .tag(clip)
                }
                .onMove(perform: { indices, newOffSet in
                    playlist.clips.move(fromOffsets: indices, toOffset: newOffSet)
                    Task {
                        await playlist.createComposition()
                    }
                })
            }
            .onChange(of: selectedClip, perform: { newClip in
                if let newClip = newClip {
                    clipData.playlist.seekTo(clip: newClip)
                }
            })
            HStack{
                Button(action: {
                    isImporting = true
                }, label: {
                    Image(systemName: "plus")
                })
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.mpeg4Movie], onCompletion: { result in switch result {
                case .success(let url):
                    clipData.playlist.add(url: url) { clip in
                        print("finished add: \(clip.name)")
                              selectedClip = clip
                    }
                case .failure(let error):
                        print(error)
                }
                    
            })
                Button(action: {
                    if let selectedClip = selectedClip {
                        clipData.playlist.remove(clip: selectedClip)
                        Task {
                            await clipData.playlist.createComposition()
                        }
                    }
                }, label: {
                    Image(systemName: "minus")
                })
                
                if let selectedClip = selectedClip {
                    NavigationLink(destination: ClipEditView(clip: selectedClip)) {
                        Text(selectedClip.name)
                    }
                }
                
                Spacer()
            }
            
        }
    }
}

//#Preview {
    //PlaylistView()
//}
//onMove(perform: { indices, newOffSet in
    //playlist.clips.move(fromOffsets: indices, toOffset: newOffSet)
   // Task {
