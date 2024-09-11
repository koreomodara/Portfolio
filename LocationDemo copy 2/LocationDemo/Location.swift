//
//  Lo.Swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import Foundation
import SwiftUI
import MapKit

@Observable //swift macro that adds code for us to conform to the observable protocol 
class Location: Hashable, Codable { //protocol conformation
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID
    var name: String
    var notes: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var latDelta: CLLocationDegrees
    var longDelta: CLLocationDegrees
    var photos : [PhotoAsset]
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var region: MKCoordinateRegion {
        get {
            MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
        }
        set {
            latitude = newValue.center.latitude
            longitude = newValue.center.longitude
            latDelta = newValue.span.latitudeDelta
            longDelta = newValue.span.longitudeDelta
        }
    }
    var position : MapCameraPosition {
        get {
            return MapCameraPosition.region(region)
        }
        set {
            guard let region = newValue.region else { return }
            latitude = region.center.latitude
            longitude = region.center.longitude
            latDelta = region.span.latitudeDelta
            longDelta = region.span.longitudeDelta
        }
    }
    
    init(id: UUID, name: String, note: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, latDelta: CLLocationDegrees, longDelta: CLLocationDegrees, photos: [PhotoAsset]) {
        self.id = id
        self.name = name
        self.notes = note
        self.latitude = latitude
        self.longitude = longitude
        self.latDelta = latDelta
        self.longDelta = longDelta
        self.photos = photos
    }
    
    convenience init(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(id: UUID(), name: name, note: "", latitude: latitude, longitude: longitude, latDelta: 0.01, longDelta: 0.01, photos: [])
    }
    
    func add(photo: PhotoAsset) {
        photos.append(photo)
    }
    
    func remove(photo: PhotoAsset) {
        if let index = photos.firstIndex(of: photo) {
            photo.deleteFile()
            photos.remove(at: index)
        }
    }
}

extension Location {
    static func tempe() -> Location {
        let coordinate = CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400)
        let tempe = Location(name: "Tempe", latitude: coordinate.latitude, longitude: coordinate.longitude)
        return tempe
    }
}
