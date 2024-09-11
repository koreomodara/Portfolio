//
//  PhoAssView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/20/24.
//

import SwiftUI

struct PhoAssView: View {
    @State var photo: PhotoAsset
    @State var location: Location
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            photo.image
                .resizable()
                .scaledToFit()
        }
        .navigationTitle(photo.url.path())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar, content: {
                Button(action: {
                    location.remove(photo: photo)
                    dismiss()
                }, label: {
                    Image(systemName: "trash")
                })
            })
        }
    }
}

#Preview {
    @State var location = Location.tempe()
    return PhoAssView(photo: PhotoAsset(url: URL(string: "_missing")!, contentType: .jpeg), location: location)
}
