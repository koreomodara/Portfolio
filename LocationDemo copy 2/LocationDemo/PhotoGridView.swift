//
//  PhotoGridView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/19/24.
//

import SwiftUI

struct PhotoGridView: View {
    @State var location: Location
    @State private var gridSize: CGFloat = 80
    
    var columns: [GridItem] {
        return [GridItem(.adaptive(minimum: gridSize), spacing: 2)]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(location.photos) { asset in
                    NavigationLink(value: asset) {
                        asset.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .padding()
        }
        .listStyle(.grouped)
    }
}

#Preview {
    @State var photos = [
        PhotoAsset(url: URL(fileURLWithPath: "hello1.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello2.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello3.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello4.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello5.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello6.png"), contentType: .png),
        PhotoAsset(url: URL(fileURLWithPath: "hello7.png"), contentType: .png)
    ]
    
    return PhotoGridView(location: Location.tempe())

}
