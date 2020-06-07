//
//  PlacesViewController.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit

class PlacesViewController: UICollectionViewController, PlaceCellDelegate {
    
    @IBOutlet weak var addPlaceBarButton: UIBarButtonItem!
    
    private let reuseIdentifier = "customCell"
    let manager: CoreDataBridge = CoreDataBridge()
    var placesSaved: [Place] = [Place]() // Problema con el init de la clase Place, no corresponde con el adecuado de NSManagerObject, revisar curso de CoreData.
    
    // DAR VALOR A TRAVÉS DE LA CONSULTA AL COREDATA
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadPlaces()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
        
    func delete(cell: PlaceCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            manager.deletePlace(id: placesSaved[indexPath.row].id!)
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseIn,
                animations: { cell.alpha = 0 },
                completion: {
                    if $0 == .end{
                        self.collectionView?.deleteItems(at: [indexPath])
                        self.reloadPlaces()
                    }})
            
        }
    }
    
    func reloadPlaces(){
        placesSaved = manager.fetchSavedPlaces()
    }
    
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addPlaceBarButton.isEnabled = !editing
        
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? PlaceCell {
                    cell.editing = editing
                    
                }
            }
        }
    }
    
    // LA LLAMADA A LA PROPIA CELDA
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell
        let item: Place = placesSaved[indexPath.row]
        
        cell.cellImage.image = manager.data2Image(data: item.imagen!)
        cell.cellLabel.text = item.nombre ?? "Place"
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        
        cell.delegate = self
        
        cell.deleteButton.isHidden = true
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isEditing {
            return false
        } else {
            return true
        }
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

