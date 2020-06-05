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
import ImageIO

class NewPlaceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UITextField!
    @IBOutlet weak var placeDescriptionTextFlield: UITextView!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    let coreDataBridge: CoreDataBridge = CoreDataBridge()
    var place: Place = Place()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeLocationMapView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func chooseImage(_ sender: UITapGestureRecognizer) {
    
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
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let metadata = info[UIImagePickerController.InfoKey.phAsset] as! PHAsset
        
        if metadata.creationDate != nil {
            print(metadata.creationDate!)
        }
        
        placeImageView.image = image
        
        let placeMapAnnotations = placeLocationMapView.annotations
        if !placeMapAnnotations.isEmpty {
            placeLocationMapView.removeAnnotations(placeMapAnnotations)
        }
        
        if let location = metadata.location {
            let locationPin = MKPointAnnotation()
            locationPin.coordinate = location.coordinate
            locationPin.title = placeNameLabel.text
            let region = MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            
            placeLocationMapView.addAnnotation(locationPin)
            placeLocationMapView.setCenter(location.coordinate, animated: true)
            placeLocationMapView.setRegion(region, animated: true)
            placeLocationMapView.selectAnnotation(locationPin, animated: true)
            
            print("Coordenadas adquiridas.")
        } else {
            print("Sin coordenadas")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
