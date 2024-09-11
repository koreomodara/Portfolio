//
//  ContentView.swift
//  LocationDemo
//
//  Created by kore omodara on 2/26/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    //
    
    
    var body: some View {
        NavigationStack {
            LoStoreView()
        }
    }
}

#Preview {
        NavigationStack {
            ContentView()
        }
    }

//@Observable
//class LocationCoordinator: NSObject, CLLocationManagerDelegate {
//    
//    var locationManager: CLLocationManager
//    var latitude: CLLocationDegrees
//    var longitude: CLLocationDegrees
//    var latitudeDelta: CLLocationDegrees
//    var longitudeDelta: CLLocationDegrees
//    
//    var position: MapCameraPosition {
//        get {
//            return MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)))
//        }
//        set {
//            guard let region = newValue.region else { return }
//            latitude = region.center.latitude
//            longitude = region.center.longitude
//            latitudeDelta = region.span.latitudeDelta
//            longitude = region.span.longitudeDelta
//        }
//    }
//    
//    override init() { //to override the initializer built into the NSObject
//        locationManager = CLLocationManager()
//        latitude = 33.41
//        longitude = -111.09
//        latitudeDelta = 0.01
//        longitudeDelta = 0.01
//        
//        super.init()
//        
//        locationManager.delegate = self //
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//    }
//    
//    func start() {
//        locationManager.startUpdatingLocation()
//    }
//    
//    func stop() {
//        locationManager.stopUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let newLocation = locations.last {
//            let region = MKCoordinateRegion(center: newLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            position = MapCameraPosition.region(region)
//        }
//    }
//}
