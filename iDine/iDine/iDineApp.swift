//
//  iDineApp.swift
//  iDine
//
//  Created by kore omodara on 1/18/24.
//

import SwiftUI

@main
struct iDineApp: App {
    @StateObject var order = Order()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(order)
        }
    }
}
