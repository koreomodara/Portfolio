//
//  LoStore.swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import Foundation

@Observable
class LoStore: Codable {
    
    var locations: [Location]
    
    init(locations: [Location]) {
        self.locations = locations
    }
    
    func add(location: Location) {
        locations.append(location)
        do {
            try LoStore.save(filename: "Locations", store: self)
            print("save success")
        }
        catch {
            print("failed")
        }
    }
}

extension LoStore {
    
    static func example() -> LoStore {
        let store = LoStore(locations: [Location.tempe()])
        return store 
    }
}

extension LoStore {
    
    enum LoStoreError: Error {
        case readArchiveError
    }
    static func load(filename: String ) throws -> LoStore {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let url = documentsDirectoryURL!.appendingPathComponent(filename).appendingPathExtension("plist")
        guard let codedStore = try? Data(contentsOf: url) else {
            throw LoStoreError.readArchiveError
        }
        let decoder = PropertyListDecoder()
        let store = try decoder.decode(LoStore.self, from: codedStore)
        return store
    }
    
    static func save(filename: String , store: LoStore) throws {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let url = documentsDirectoryURL!.appendingPathComponent(filename).appendingPathExtension("plist")
        let encoder = PropertyListEncoder()
        let codedStore: Data = try encoder.encode(store)
        try codedStore.write(to: url)
    }
    
}
