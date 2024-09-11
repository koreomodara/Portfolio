//
//  LocRowView.swift
//  LocationDemo
//
//  Created by kore omodara on 3/20/24.
//

import SwiftUI

struct LocRowView: View {
    var name: String = "Tempe"
    var image = Image(systemName: "Location")
    
    var body: some View {
    HStack {
        image
            .resizable()
            .frame(width: 60, height: 60)
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        Text(name)
        
        }
    }
}

#Preview {
    LocRowView()
}
