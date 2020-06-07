//
//  LocationManager.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.showsBackgroundLocationIndicator = true
        //locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func checkUserPermissions() {
        
        switch (CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            break;
        case .denied, .restricted:
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break;
        default:
            break;
        }
    }
    
    func setDelegate(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
    }
    
    func getUserCurrentLocation() -> CLLocation? {
        locationManager.requestLocation()
        return locationManager.location
    }
}
