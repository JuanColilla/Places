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

class PlaceDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UITextField!
    @IBOutlet weak var placeDescriptionText: UITextView!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    @IBOutlet weak var placeCategoryTextField: UITextField!
    
    let picker = UIPickerView()
    var place: Place!
    let coreDataBridge: CoreDataBridge = CoreDataBridge()
    let locationManager: LocationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        
        placeImageView.image = coreDataBridge.data2Image(data: (place.imagen!))
        placeNameLabel.text = place.nombre ?? "Sin nombre"
        placeDescriptionText.text = place.descripcion ?? "Sin descripción"
        placeCategoryTextField.insertText(place.categoria ?? "Sin Categoría")
        
        placeCategoryTextField.inputView = picker
        
        centerPlaceLocationOnMap()
    }
    
    @IBAction func getDirectionsButton(_ sender: UIButton) {
        
        var coordinate: CLLocationCoordinate2D
        
        if (placeLocationMapView.annotations.count > 0) {
            coordinate = placeLocationMapView.annotations[0].coordinate
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            destination.name = placeNameLabel.text ?? "Place"
            
            
            let alert = UIAlertController(title: "Abrir en mapas", message: "Si decide continuar se trazará una ruta hacia la ubicación del lugar guardado.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Entendido", style: .default, handler: { (action: UIAlertAction) in
                MKMapItem.openMaps(with: [destination], launchOptions: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction) in}))
            self.present(alert, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Abrir en mapas", message: "No existe ubicación a la que poder trazar indicaciones.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: .default, handler: { (action: UIAlertAction) in}))
            self.present(alert, animated: true)
        }
        
        
        
    }
    
    
    @IBAction func centerMapCoordinates(_ sender: UIButton) {
    
        if placeLocationMapView.annotations.count > 0 {
            let annotation: MKAnnotation = placeLocationMapView.annotations[0]
            placeLocationMapView.setCenter(annotation.coordinate, animated: true)
            placeLocationMapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    func centerPlaceLocationOnMap() {
        let locationPin = MKPointAnnotation()
        let coordenadas = CLLocationCoordinate2DMake(place.latitud, place.longitud)
        locationPin.coordinate = coordenadas
        locationPin.title = place.nombre
        
        let region = MKCoordinateRegion(center: coordenadas, latitudinalMeters: 400, longitudinalMeters: 400)
        
        placeLocationMapView.setCenter(coordenadas, animated: true)
        placeLocationMapView.setRegion(region, animated: true)
        placeLocationMapView.addAnnotation(locationPin)
        placeLocationMapView.selectAnnotation(locationPin, animated: true)
    }
    
    @IBAction func centerMapPosition(_ sender: UIButton) {
        placeLocationMapView.setCenter(placeLocationMapView.annotations[0].coordinate, animated: true)
        placeLocationMapView.selectAnnotation(placeLocationMapView.annotations[0], animated: true)
    }
    
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        let screenPoint = sender.location(in: placeLocationMapView)
        let coordinate: CLLocationCoordinate2D = placeLocationMapView.convert(screenPoint, toCoordinateFrom: placeLocationMapView)
        let locationPin = MKPointAnnotation()
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        
        locationPin.coordinate = coordinate
        locationPin.title = placeNameLabel.text
        
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
        
        // Permitir la selección manual de una ubicación así como la apertura de la ubicación actual en Apple Maps.
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Fotografía", message: "Escoge una fuente:", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: .none)
            } else {
                let warning = UIAlertController(title: "Aviso", message: "La fotografía seleccionada no dispone de datos GPS, deberás marcar la ubicación manualmente.", preferredStyle: .alert)
                
                warning.addAction(UIAlertAction(title: "Entendido", style: .default, handler: { (action: UIAlertAction) in}))
                self.present(warning, animated: true)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Fototeca", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: .none)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        // Preguntar antes de extraer los metadatos u obtener la ubicación si se desea establecer esta como ubicación del sitio, dado que puede cambiar la imagen pero puede no querer cambiar la localización. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO IMPROVE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        let placeMapAnnotations = placeLocationMapView.annotations
        if !placeMapAnnotations.isEmpty {
            placeLocationMapView.removeAnnotations(placeMapAnnotations)
        }
        
        if picker.sourceType == .photoLibrary {
            let metadata = info[UIImagePickerController.InfoKey.phAsset] as! PHAsset
            
            if let location = metadata.location {
                let locationPin = MKPointAnnotation()
                locationPin.coordinate = location.coordinate
                locationPin.title = placeNameLabel.text
                let region = MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
                
                placeLocationMapView.setCenter(location.coordinate, animated: true)
                placeLocationMapView.setRegion(region, animated: true)
                placeLocationMapView.addAnnotation(locationPin)
                placeLocationMapView.selectAnnotation(locationPin, animated: true)
                }
            
        } else {
            
            if let location = locationManager.getUserCurrentLocation(){
                let locationPin = MKPointAnnotation()
                locationPin.coordinate = location.coordinate
                locationPin.title = placeNameLabel.text
                let region = MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
                
                placeLocationMapView.setCenter(location.coordinate, animated: true)
                placeLocationMapView.setRegion(region, animated: true)
                placeLocationMapView.addAnnotation(locationPin)
                placeLocationMapView.selectAnnotation(locationPin, animated: true)
                
            }
        }
        
        placeImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Do nothing
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicación \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.checkUserPermissions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updatePlace" {
            let placeToUpdate: Place = coreDataBridge.fetchPlaceByID(id: place.id!)
            
            placeToUpdate.imagen = coreDataBridge.image2Data(image: placeImageView.image!)
            placeToUpdate.nombre = placeNameLabel.text ?? "Sin nombre"
            placeToUpdate.descripcion = placeDescriptionText.text ?? "Sin descripción."
            placeToUpdate.latitud = placeLocationMapView.annotations[0].coordinate.latitude
            placeToUpdate.longitud = placeLocationMapView.annotations[0].coordinate.longitude
            placeToUpdate.categoria = placeCategoryTextField.text ?? "Sin Categoría"
            
            coreDataBridge.saveContext()
        }
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
