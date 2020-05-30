//
//  PlacesViewController.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit

class PlacesViewController: UICollectionViewController {
    
    private let reuseIdentifier = "customCell"
    let manager: CoreDataBridge = CoreDataBridge()
    var placesSaved: [Place]!
    var nombre: String = ""
    var descripcion: String = ""
    var location: String = ""
    
    // DAR VALOR A TRAVÉS DE LA CONSULTA AL COREDATA
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        placesSaved = manager.fetchSavedPlaces()
        collectionView.reloadData()
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        manager.deleteAllPlaces()
        placesSaved.removeAll()
        collectionView.reloadData()
    }
    
    
    @IBAction func goBack (segue : UIStoryboardSegue) {
        if segue.identifier == "Save" {
            manager.saveNewPlace(nombre: nombre, description: descripcion, location: location)
        } else if segue.identifier == "Update" {
            manager.updatePlace(nombre: nombre, description: descripcion, location: location)
        }
        placesSaved = manager.fetchSavedPlaces()
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            if let cell = sender as? PlaceCell {
                if let indexPath = collectionView.indexPath(for: cell) {
                    if let navigationController = segue.destination as?  UINavigationController, let segueDestinationEPVC = navigationController.visibleViewController as? PlaceDetailsViewController {
                        segueDestinationEPVC.placeSelected = manager.placesSaved[indexPath.row]
                    }
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    // FINALIZADA
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // CANTIDAD DE CELDAS EN LA COLLECTION VIEW
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return placesSaved.count
    }
    
    // LA LLAMADA A LA PROPIA CELDA
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell
        let item: Place = placesSaved[indexPath.row]
        
        cell.cellImageView.image = UIImage(named: "wendys")
        
        return cell
    }
    
}

