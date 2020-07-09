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
    private var regions: [CLCircularRegion] = [CLCircularRegion]()
    private var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    init() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startMonitoringSignificantLocationChanges()
        setLocationAccuracy(accuracy: "low")
    }
    
    init(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestLocation()
        if let currentLocation = locationManager.location {
            lastLocation = currentLocation
        }
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
    
    func updateLastLocation() {
        //locationManager.requestLocation()
        if lastLocation != locationManager.location && locationManager.location != nil {
            lastLocation = locationManager.location!
        }
    }
    
    func getLastLocation() -> CLLocation {
        return lastLocation
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
    
    func setNewRegion(latitude: Double, longitude: Double, name: String) {
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: locationManager.desiredAccuracy, identifier: name)
        regions.append(region)
    }
    
    func searchForCloseRegions() {
        for region in regions {
            locationManager.startMonitoring(for: region)
            // Sirven para gestionar desde el CLLocationManagerDelegate la entrada y salida en regiones con la app abierta.
            region.notifyOnEntry = true
            region.notifyOnExit = true
        }
    }
    
    func getRegions() -> [CLCircularRegion] {
        return regions
    }
    
    /// Si borramos un Place, se debe llamar a esta función para que la localización de dicho Place deje de monitorizarse.
    func deleteRegion(latitude: Double?, longitude: Double?, name: String?) {
        if latitude != nil && longitude != nil && name != nil {
            let location = CLLocation(latitude: latitude!, longitude: longitude!)
            let regionToDelete = CLCircularRegion(center: location.coordinate, radius: locationManager.desiredAccuracy, identifier: name!)
            for region in regions {
                if region == regionToDelete {
                    if let index = regions.firstIndex(of: region) {
                        regions.remove(at: index)
                    }
                }
            }
        }
    }
    
    func deleteAllRegions() {
        regions.removeAll()
    }
    
}
