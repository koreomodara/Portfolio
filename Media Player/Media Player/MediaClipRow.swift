//
//  MediaclipRow.swift
//  Media Player
//
//  Created by kore omodara on 11/7/23.
//

import SwiftUI

struct MediaClipRow: View {
    var clip: MediaClip
    
    var body: some View{
        VStack {
            clip.thumbNail
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
                .cornerRadius(5)
        }
        
       
    }
}

//#Preview {
    //MediaclipRow()
//}
