//
//  ClipData.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import Foundation
import SwiftUI

class ClipData: ObservableObject {
    @Published var playlist: MediaPlaylist = MediaPlaylist(clips: [])
}
