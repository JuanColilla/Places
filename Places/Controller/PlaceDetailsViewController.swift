//
//  PlaceDetailsViewController.swift
//  PlacesIB
//
//  Created by Juan Colilla on 30/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

class PlaceDetailsViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UITextField!
    @IBOutlet weak var placeDescriptionText: UITextView!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    @IBOutlet weak var placeCategoryTextField: UITextField!
    
    let picker = UIPickerView()
    var place: Place!
    let coreDataBridge: CoreDataBridge = CoreDataBridge()
    let locationManager: LocationManager = LocationManager()
    let notificationManager: NotificationManager = NotificationManager()
    var mode: String = "Details"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameLabel.delegate = self
        placeDescriptionText.delegate = self
        
        if mode == "New" {
            locationManager.checkUserPermissions()
            PHPhotoLibrary.requestAuthorization({ status in})
        } else {
            placeImageView.image = coreDataBridge.data2Image(data: (place.imagen!))
            placeNameLabel.text = place.nombre ?? NSLocalizedString("NoNameString", comment: "")
            placeDescriptionText.text = place.descripcion ?? NSLocalizedString("NoDescriptionString", comment: "")
            placeCategoryTextField.insertText(place.categoria ?? NSLocalizedString("NoCategoryString", comment: ""))
            centerPlaceLocationOnMap()
        }
        picker.dataSource = self
        picker.delegate = self
        locationManager.setDelegate(delegate: self)
        locationManager.updateLastLocation()
        placeCategoryTextField.inputView = picker
    }
    
    @IBAction func getDirectionsButton(_ sender: UIButton) {
        
        var coordinate: CLLocationCoordinate2D
        
        if (placeLocationMapView.annotations.count > 0) {
            coordinate = placeLocationMapView.annotations[0].coordinate
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            destination.name = placeNameLabel.text ?? "Place"
            
            
            let alert = UIAlertController(title: NSLocalizedString("MapRoutingAlertTitle", comment: ""), message: NSLocalizedString("MapRoutingAlertText", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:  NSLocalizedString("AlertOKButton", comment: ""), style: .default, handler: { (action: UIAlertAction) in
                MKMapItem.openMaps(with: [destination], launchOptions: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("AlertKOButton", comment: ""), style: .default, handler: { (action: UIAlertAction) in}))
            self.present(alert, animated: true)
            
        } else {
            let alert = UIAlertController(title: NSLocalizedString("MapRoutingAlertTitle", comment: ""), message: NSLocalizedString("MapRoutingNoLocationAlertContent", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("AlertOKButton", comment: ""), style: .default, handler: { (action: UIAlertAction) in}))
            self.present(alert, animated: true)
        }
    }
    
    
    func centerPlaceLocationOnMap() {
        let locationPin = MKPointAnnotation()
        let coordenadas = CLLocationCoordinate2DMake(place.latitud, place.longitud)
        locationPin.coordinate = coordenadas
        if placeNameLabel.text != NSLocalizedString("PlacePlaceholderText", comment: "") {
            locationPin.title = placeNameLabel.text
        } else {
            locationPin.title = "Place"
        }
        
        let region = MKCoordinateRegion(center: coordenadas, latitudinalMeters: 400, longitudinalMeters: 400)
        
        placeLocationMapView.setCenter(coordenadas, animated: true)
        placeLocationMapView.setRegion(region, animated: true)
        placeLocationMapView.addAnnotation(locationPin)
        placeLocationMapView.selectAnnotation(locationPin, animated: true)
    }
    
    @IBAction func centerMapPosition(_ sender: UIButton) {
        if placeLocationMapView.annotations.count > 0 {
            placeLocationMapView.setCenter (placeLocationMapView.annotations[0].coordinate , animated: true)
            placeLocationMapView.selectAnnotation(placeLocationMapView.annotations[0], animated: true)
        } else {
            // HAY UN PROBLEMA A LA HORA DE PEDIR LA UBICACIÓN, NECESITAMOS ACCEDER A ELLA CON MÁS RAPIDEZ.
            let locationPin = MKPointAnnotation()
            let location = locationManager.getLastLocation()
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            
            locationPin.coordinate = location.coordinate
            if placeNameLabel.text != NSLocalizedString("PlacePlaceholderText", comment: "") {
                locationPin.title = placeNameLabel.text
            } else {
                locationPin.title = "Place"
            }
            
            placeLocationMapView.setCenter(location.coordinate, animated: true)
            placeLocationMapView.setRegion(region, animated: true)
            placeLocationMapView.addAnnotation(locationPin)
            placeLocationMapView.selectAnnotation(locationPin, animated : true)
        }
    }
    
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        let screenPoint = sender.location(in: placeLocationMapView)
        let coordinate: CLLocationCoordinate2D = placeLocationMapView.convert(screenPoint, toCoordinateFrom: placeLocationMapView)
        let locationPin = MKPointAnnotation()
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        
        locationPin.coordinate = coordinate
        if placeNameLabel.text != NSLocalizedString("PlacePlaceholderText", comment: "") {
            locationPin.title = placeNameLabel.text
        } else {
            locationPin.title = "Place"
        }
        
        let placeMapAnnotations = placeLocationMapView.annotations
        if !placeMapAnnotations.isEmpty {
            placeLocationMapView.removeAnnotations(placeMapAnnotations)
        }
        
        placeLocationMapView.setRegion(region, animated: true)
        placeLocationMapView.addAnnotation(locationPin)
        placeLocationMapView.selectAnnotation(locationPin, animated: true)
        
        if sender.state == .ended {
            placeLocationMapView.setCenter(coordinate, animated: true)
        }
    }
    
    @IBAction func chooseImage(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: NSLocalizedString("PhotoSourceAlertTitle", comment: ""), message: NSLocalizedString("PhotoSourceAlertMessage", comment: ""), preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PhotoSourceAlertCameraOption", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: .none)
            } else {
                let warning = UIAlertController(title: NSLocalizedString("CameraNotAvailableAlertTitle", comment: ""), message: NSLocalizedString("CameraNotAvailableAlertSubtitle", comment: ""), preferredStyle: .alert)
                
                warning.addAction(UIAlertAction(title: NSLocalizedString("AlertOKButton", comment: ""), style: .default, handler: { (action: UIAlertAction) in}))
                self.present(warning, animated: true)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PhotoSourceAlertLibraryOption", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: .none)
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("AlertKOButton", comment: ""), style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func createPlace() {
        let place = Place.init(context: coreDataBridge.getContext())
        place.id = UUID()
        place.imagen = coreDataBridge.image2Data(image: placeImageView.image!)
        place.nombre = placeNameLabel.text ?? "Place"
        place.descripcion = placeDescriptionText.text ?? NSLocalizedString("NoDescriptionString", comment: "")
        place.latitud = placeLocationMapView.centerCoordinate.latitude
        place.longitud = placeLocationMapView.centerCoordinate.longitude
        place.categoria = placeCategoryTextField.text ?? NSLocalizedString("NoCategoryString", comment: "")
        
        setNewPlaceNotification(place: place)
        
        coreDataBridge.saveContext()
    }
    
    func setNewPlaceNotification(place: Place) {
        locationManager.setNewRegion(latitude: place.latitud, longitude: place.longitud, name: place.nombre!)
        let content = notificationManager.createNotification(place: place)
        let trigger = notificationManager.setTriggerNotification(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: place.latitud, longitude: place.longitud), radius: 200, identifier: place.nombre!))
        notificationManager.addNotificationRequest(identifier: place.nombre!, content: content, trigger: trigger)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Save" {
            createPlace()
        } else if segue.identifier == "Update" {
            let placeToUpdate: Place = coreDataBridge.fetchPlaceByID(id: place.id!)
            
            placeToUpdate.imagen = coreDataBridge.image2Data(image: placeImageView.image!)
            placeToUpdate.nombre = placeNameLabel.text ??  NSLocalizedString("NoNameString", comment: "")
            placeToUpdate.descripcion = placeDescriptionText.text ?? NSLocalizedString("NoDescriptionString", comment: "")
            placeToUpdate.latitud = placeLocationMapView.annotations[0].coordinate.latitude
            placeToUpdate.longitud = placeLocationMapView.annotations[0].coordinate.longitude
            placeToUpdate.categoria = placeCategoryTextField.text ??  NSLocalizedString("NoCategoryString", comment: "")
            
            coreDataBridge.saveContext()
        }
    }
}

extension PlaceDetailsViewController: UIImagePickerControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let placeMapAnnotations = placeLocationMapView.annotations
        if !placeMapAnnotations.isEmpty {
            placeLocationMapView.removeAnnotations(placeMapAnnotations)
        }
        
        if picker.sourceType == .photoLibrary {
            let metadata = info[UIImagePickerController.InfoKey.phAsset] as! PHAsset
            
            if let location = metadata.location {
                let locationPin = MKPointAnnotation()
                locationPin.coordinate = location.coordinate
                if placeNameLabel.text != NSLocalizedString("PlacePlaceholderText", comment: "") {
                    locationPin.title = placeNameLabel.text
                } else {
                    locationPin.title = "Place"
                }
                let region = MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
                
                placeLocationMapView.setRegion(region, animated: true)
                placeLocationMapView.setCenter(location.coordinate, animated: true)
                placeLocationMapView.addAnnotation(locationPin)
                placeLocationMapView.selectAnnotation(locationPin, animated: true)
            } else {
                
                let warning = UIAlertController(title: NSLocalizedString("GPSNoDataAlertTitle", comment: ""), message: NSLocalizedString("GPSNoDataAlertMessage", comment: ""), preferredStyle: .alert)
                
                warning.addAction(UIAlertAction(title: NSLocalizedString("AlertOKButton", comment: ""), style: .default, handler: { (action: UIAlertAction) in}))
                picker.dismiss(animated: true, completion: {self.present(warning, animated: true)})
            }
            
        } else {
            let location = locationManager.getLastLocation()
            let locationPin = MKPointAnnotation()
            locationPin.coordinate = location.coordinate
            locationPin.title = placeNameLabel.text
            let region = MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            
            placeLocationMapView.setRegion(region, animated: true)
            placeLocationMapView.setCenter(location.coordinate, animated: true)
            placeLocationMapView.addAnnotation(locationPin)
            placeLocationMapView.selectAnnotation(locationPin, animated: true)
        }
        
        placeImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension PlaceDetailsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.searchForCloseRegions()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicación \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.checkUserPermissions()
    }
    
}


extension PlaceDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coreDataBridge.getCategories().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coreDataBridge.getCategories()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        placeCategoryTextField.text = coreDataBridge.getCategories()[row]
        placeCategoryTextField.resignFirstResponder()
    }

}


extension PlaceDetailsViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
