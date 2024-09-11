//
//  LoView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import SwiftUI
import MapKit
import PhotosUI

struct LoView: View {
    
    @Bindable var location: Location
    @Environment(LoStore.self) private var store
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Map(position: $location.position)
                    .frame(minHeight: 300)
                    .onMapCameraChange { context in
                        location.position = MapCameraPosition.region(context.region)
                    }
                TextField("name", text: $location.name)
                TextField("notes", text: $location.notes)
                
              
                Section("Photos") {
                    VStack(alignment: .leading) {
                        HStack{
                            PhotosPicker(selection: $selectedItems, matching: .images) {
                                Label("Add Photo", systemImage: "photo.fill.on.rectangle.fill")
                                    .padding(.all, 8)
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 6,
                                            style: .continuous
                                        )
                                        .fill(.gray)
                                    )
                            }
                        }
                        PhotoGridView(location: location)// once i add in the LazyGrid code
//                        VStack {
//                            ForEach(location.photos){ asset in
//                                asset.image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                            }
//                        }
                    }
                }
            }
            
            
        }
        .navigationDestination(for: PhotoAsset.self) { asset in
            PhoAssView(photo: asset, location: location)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            //only save it when there has been an update
            do {
                try LoStore.save(filename: "Locations", store: store)
            } 
            catch {
                print(error)
            }
        }
        
        .onChange(of: selectedItems) {
            importSelectedPhotosFromLib()
        }
    }
    func importSelectedPhotosFromLib() {
        guard selectedItems.count > 0 else {return}
        
        Task {
            for item in selectedItems {
                if let asset = try? await item.loadTransferable(type: PhotoAsset.self) {
                    location.add(photo: asset)
                }
            }
            try LoStore.save(filename: "Locations", store: store)
            selectedItems.removeAll()
        }
    }
}

#Preview {
    NavigationStack{
        LoView(location: Location.tempe())
    }
   
}
