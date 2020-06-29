//
//  LocationManager.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import CoreLocation

class LocationManager {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var regions: [CLRegion] = [CLRegion]()
    
    init() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startMonitoringSignificantLocationChanges()
        setLocationAccuracy(accuracy: "low")
    }
    
    func checkUserPermissions() {
        
        switch (CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            break;
        case .denied, .restricted:
            break;
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break;
        default:
            break;
        }
    }
    
    func setDelegate(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
    }
    
    func setLocationAccuracy(accuracy: String) {
        switch(accuracy) {
        case "high":
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break;
        case "mid":
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            break;
        case "low":
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            break;
        default:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            break;
        }
    }
    
    func getUserCurrentLocation() -> CLLocation? {
        locationManager.requestLocation()
        return locationManager.location
    }
    
    func setNewRegion(region: CLRegion) {
        regions.append(region)
    }
    
    func searchForCloseRegions() {
        for region in regions {
            locationManager.startMonitoring(for: region)
            region.notifyOnEntry = true
        }
    }
    
    func getRegions() -> [CLRegion] {
        return regions
    }
    
    /// Si borramos un Place, se debe llamar a esta función para que la localización de dicho Place deje de monitorizarse.
    func deleteRegion(regionToDelete: CLRegion) {
        for region in regions {
            if region == regionToDelete {
                if let index = regions.firstIndex(of: region) {
                    regions.remove(at: index)
                }
            }
        }
    }
}
