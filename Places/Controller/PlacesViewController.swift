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
    var placesSaved: [Place] = [Place]() // Problema con el init de la clase Place, no corresponde con el adecuado de NSManagerObject, revisar curso de CoreData.
    
    // DAR VALOR A TRAVÉS DE LA CONSULTA AL COREDATA
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        placesSaved = manager.fetchSavedPlaces()
        collectionView.reloadData()
        print(placesSaved.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
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
        
        cell.cellImage.image = manager.data2Image(data: item.imagen!)
        cell.cellLabel.text = item.nombre ?? "Place"
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    //    @IBAction func deleteAll(_ sender: Any) {
    //        manager.deleteAllPlaces()
    //        placesSaved.removeAll()
    //        collectionView.reloadData()
    //    }
        
        
        @IBAction func goBack (segue : UIStoryboardSegue) {
            placesSaved = manager.fetchSavedPlaces()
            collectionView.reloadData()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeInfo" {
            if let cell = sender as? PlaceCell {
                if let destinationViewController = segue.destination as? PlaceDetailsViewController {
                    if let indexPath = collectionView.indexPath(for: cell) {
                        destinationViewController.place = placesSaved[indexPath.row]
                    }
                }
            }
        }
    }
}

