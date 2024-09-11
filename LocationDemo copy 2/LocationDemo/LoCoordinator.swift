//
//  LoCoordinator.swift
//  LocationDemo
//
//  Created by kore omodara on 3/11/24.
//

import Foundation
import SwiftUI
import MapKit

@Observable
class LocationCoordinator: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager
    var location: Location
    
//    var latitude: CLLocationDegrees
//    var longitude: CLLocationDegrees
//    var latitudeDelta: CLLocationDegrees
//    var longitudeDelta: CLLocationDegrees
//    
    var position: MapCameraPosition {
        get {
            return MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: location.latDelta, longitudeDelta: location.longDelta)))
        }
        set {
            guard let region = newValue.region else { return }
            location.latitude = region.center.latitude
            location.longitude = region.center.longitude
            location.latDelta = region.span.latitudeDelta
            location.longDelta = region.span.longitudeDelta
        }
    }
    
    override init() { //to override the initializer built into the NSObject
        locationManager = CLLocationManager()
        location = Location(name: "", latitude: 33.41, longitude: -111.09)
//        location.latitude = 33.41
//        location.longitude = -111.09
//        location.latitudeDelta = 0.01
//        location.longitudeDelta = 0.01
        
        super.init()
        
        locationManager.delegate = self //
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            let region = MKCoordinateRegion(center: newLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            position = MapCameraPosition.region(region)
        }
    }
}

