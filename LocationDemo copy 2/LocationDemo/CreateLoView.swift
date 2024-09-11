//
//  CreateLoView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import SwiftUI
import SwiftUI
import MapKit

struct CreateLoView: View {
        
    @State var coordinator = LocationCoordinator()
        //change lat and long for a zoomed in/out look
    @State private var searchText: String = ""
    @Environment(LoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button("Create New Location", action: {
                        store.add(location: coordinator.location)
                        dismiss()
                    })
                        .buttonStyle(.borderedProminent)
                        .padding()
                        Spacer()
                }
                Form {
                    Map(position: $coordinator.position)
                        .frame(minHeight: 300)
                    TextField("name", text: $coordinator.location.name)
                }
                
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                Task {
                    await self.runSearch(text: self.searchText)
                }
            }
            .toolbar {
                Button("Device", systemImage: "location.fill", action: {
                    coordinator.start()
                })
                .buttonStyle(.bordered)
            }
            .navigationTitle("Create Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    
    
        func runSearch(text: String) async {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = text
            let search = MKLocalSearch(request: searchRequest)
            do{
                let response = try await search.start()
                print("mapItems count = \(response.mapItems.count)")
                
                for item in response.mapItems {
                    let name = item.name ?? "-- no name--"
                    print(name)
                }
                
                guard let item = response.mapItems.first else { return }
                
                coordinator.position = MapCameraPosition.region(MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                coordinator.location.name = item.placemark.name ?? "Untitled"
            }
            catch {
                print(error)
            }
        }
    }

#Preview {
    NavigationStack{
        CreateLoView()
    }
}
