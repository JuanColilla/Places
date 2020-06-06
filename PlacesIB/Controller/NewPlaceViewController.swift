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
    @IBOutlet weak var categoryLabel: UILabel!
    
    let coreDataBridge: CoreDataBridge = CoreDataBridge()
    let place: Place = Place()
    let locationManager: LocationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeLocationMapView.delegate = self
        locationManager.setDelegate(delegate: self)
        locationManager.checkUserPermissions()
        PHPhotoLibrary.requestAuthorization({ status in})
        // Do any additional setup after loading the view.
    }
    
    // Boton de Aceptar que permita guardar el nuevo Place dentro de CoreData con los datos de la view como atributos.
    
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
    
    @IBAction func saveNewPlace(_ sender: UIBarButtonItem) {
        place.imagen = coreDataBridge.image2Data(image: placeImageView.image!)
        place.nombre = placeNameLabel.text!
        place.descripcion = placeDescriptionTextFlield.text!
        place.latitud = placeLocationMapView.centerCoordinate.latitude
        place.longitud = placeLocationMapView.centerCoordinate.longitude
        
        coreDataBridge.saveNewPlace(place: place)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
