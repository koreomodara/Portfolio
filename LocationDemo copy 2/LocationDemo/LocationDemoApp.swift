//
//  LocationDemoApp.swift
//  LocationDemo
//
//  Created by kore omodara on 2/26/24.
//Objects
//Location
//LocationStore
//PhotoAsset

//Views 
//LoStoreView
//LoView
//CreateLoView

import SwiftUI

@main
struct LocationDemoApp: App {
    
    @State var store: LoStore
    
    init() {
        do {
            self.store = try LoStore.load(filename: "Locations")
        }
        catch {
            self.store = LoStore.example()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            
           ContentView()
                .environment(store)
            
        }
    }
}
