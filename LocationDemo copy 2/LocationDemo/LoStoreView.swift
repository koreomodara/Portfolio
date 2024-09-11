//
//  LoStoreView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import SwiftUI

struct LoStoreView: View {
    
    @Environment(LoStore.self) private var store: LoStore
    @State private var showCreateLo = false
    
    var body: some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 4) {
            HStack{
                Button() {
                    showCreateLo = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            List {
                ForEach($store.locations, id: \.self) { $location in
                    NavigationLink(value: location) {
                        LocRowView(name: location.name, image: location.photos.first?.image ??
                                Image(systemName: "location")) //location.photos.first?.image ??
                        //Text(location.name)
                        
                    }
                }
                .onDelete(perform: delete)
            }
            
        }
        .navigationDestination(for: Location.self) { location in
            LoView(location: location)
        }
        .navigationTitle("Locations")
        .sheet(isPresented: $showCreateLo, content: {
            NavigationStack {
                CreateLoView()
            }
        })
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            for asset in store.locations[index].photos {
                asset.deleteFile()
            }
        }
        store.locations.remove(atOffsets: offsets)
        do {
            try LoStore.save(filename: "Locations", store: store)
            print("saved it")
        }
        catch {
            print(error)
        }
    }
}

#Preview {
    LoStoreView()
}
