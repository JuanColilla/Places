//
//  NewPlaceViewController.swift
//  PlacesIB
//
//  Created by Juan Colilla on 04/06/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

class NewPlaceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UITextField!
    @IBOutlet weak var placeDescriptionTextFlield: UITextView!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    @IBOutlet weak var placeCategoryTextField: UITextField!
    
    let picker = UIPickerView()
    let coreDataBridge: CoreDataBridge = CoreDataBridge()
    let locationManager: LocationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeLocationMapView.delegate = self
        locationManager.setDelegate(delegate: self)
        locationManager.checkUserPermissions()
        PHPhotoLibrary.requestAuthorization({ status in})
        
        picker.dataSource = self
        picker.delegate = self
        
        placeCategoryTextField.inputView = picker
        // Do any additional setup after loading the view.
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
    
    @IBAction func centerMapCoordinates(_ sender: UIButton) {
    
        if placeLocationMapView.annotations.count > 0 {
            let annotation: MKAnnotation = placeLocationMapView.annotations[0]
            placeLocationMapView.setCenter(annotation.coordinate, animated: true)
            placeLocationMapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    @IBAction func chooseImage(_ sender: UITapGestureRecognizer) {
        
        // Permitir la selección manual de una ubicación así como la apertura de la ubicación actual en Apple Maps.
    
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Fotografía", message: "Escoge una fuente:", preferredStyle: .actionSheet)
        
        if UIDevice.current.model.hasPrefix("iPad") {
            actionSheet.popoverPresentationController?.sourceView = self.placeImageView
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: .none)
            } else {
                print("Cámara no disponible.")
            }
           
        }))
        actionSheet.addAction(UIAlertAction(title: "Fototeca", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            
            self.present(imagePickerController, animated: true, completion: .none)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    
        
    
    func createPlace() {
        let place = Place.init(context: coreDataBridge.getContext())
        place.id = UUID()
        place.imagen = coreDataBridge.image2Data(image: placeImageView.image!)
        place.nombre = placeNameLabel.text!
        place.descripcion = placeDescriptionTextFlield.text!
        place.latitud = placeLocationMapView.centerCoordinate.latitude
        place.longitud = placeLocationMapView.centerCoordinate.longitude
        place.categoria = placeCategoryTextField.text!
        
        coreDataBridge.saveContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Save" {
            createPlace()
        }
    }
    
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        // Preguntar antes de extraer los metadatos u obtener la ubicación si se desea establecer esta como ubicación del sitio, dado que puede cambiar la imagen pero puede no querer cambiar la localización.
        
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
                
                print("Coordenadas adquiridas.")
            } else {
                print("Sin coordenadas")
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

}

extension NewPlaceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
