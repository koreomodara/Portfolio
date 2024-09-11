//
//  Media_PlayerApp.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import SwiftUI

@main
struct Media_PlayerApp: App {
    @StateObject private var clipData = ClipData()
    @State private var isImporting = false
    // @State private var isExporting = false
    @State private var playlistUrl: URL?
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(playlist: clipData.playlist)
                .environmentObject(clipData)
        }
        .commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                //open
                
                Button(action: {
                    isImporting = true
                    
                }, label: {
                    Text("open..")
                })
                .keyboardShortcut("o")
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.propertyList], onCompletion: {
                    result in
                    switch result {
                    case .success(let url):
                        do {
                            let newPlaylist = try MediaPlaylist.load(url: url)
                            playlistUrl = url
                            
                            Task { @MainActor in
                                for clip in newPlaylist.clips{
                                    try await clip.loadThumbNail()
                                }
                                
                                clipData.playlist.clips = newPlaylist.clips
                                await clipData.playlist.createComposition()
                            }
                            
                        }
                        catch{
                            print("error")
                        }
                        
                    case .failure(let error):
                        print("errro girl")
                    }
                })
                
                //Save
                Button(action: {
                    guard let url = playlistUrl else { return }
                    do {
                        try clipData.playlist.save(url: url)
                    }
                    catch {
                        print("error")
                    }
                }, label: {
                    Text("Save")
                })
                .keyboardShortcut("s")
                
                //save as
                Button(action: {
                    if let url = showSaveAsPanel() {
                        do {
                            try clipData.playlist.save(url: url)
                            playlistUrl = url
                        }
                        catch {
                            print(error)
                        }
                    }
                }, label: {
                    Text("Save As..")
                })
                //Export As
                Button(action: {
                    if let url = showExportPanel() {
                        Task {
                            await clipData.playlist.export(url: url)
                        }
                    }
                }, label:{
                    Text("Export...")
                })
            }
        }
    }
    
    func showSaveAsPanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.propertyList]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save Playlist As"
        savePanel.message = "Choose a folder and a name to save your movie playlist."
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
        
    }
    
    func showExportPanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.movie, .quickTimeMovie, .mpeg4Movie]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Export Playlist As"
        savePanel.message = "Choose a folder and a name to export your playlist as a movie."
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
}
