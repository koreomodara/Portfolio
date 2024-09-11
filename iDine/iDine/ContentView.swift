//
//  ContentView.swift
//  iDine
//
//  Created by kore omodara on 1/18/24.
//

import SwiftUI

struct ContentView: View {
    let menu = Bundle.main.decode([MenuSection].self, from: "menu.json")
    
    var body: some View {
            NavigationStack{
                List {
                    ForEach(menu) { section in
                        Section(section.name) {
                            ForEach(section.items) { item in
                                NavigationLink(value: item) {
                                    //Text(item.name)
                               // } label: {
                                    ItemRow(item: item)
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: MenuItem.self) { item in
                    ItemDetail(item: item)
                }
                .navigationTitle("Menu")
                .listStyle(.grouped)
            }
            
            .padding()
        }
    }
    
    #Preview {
        ContentView()
    }

