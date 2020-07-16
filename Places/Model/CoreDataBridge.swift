//
//  Place.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import CoreData
import UIKit

class CoreDataBridge {
    
    let managedObjectViewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var placesSaved: [Place] = [Place]()
    let categories: [String] = [NSLocalizedString("Category1", comment: ""),NSLocalizedString("Category2", comment: ""), NSLocalizedString("Category3", comment: ""), NSLocalizedString("Category4", comment: ""), NSLocalizedString("Category5", comment: ""), NSLocalizedString("Category6", comment: ""), NSLocalizedString("Category7", comment: "")]
     
    init() {}
    
    func saveContext(){
        do {
            try managedObjectViewContext.save()
        } catch {
            print("Error al guardar contexto: \(error.localizedDescription)")
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        return managedObjectViewContext
    }
    
    func getCategories() -> [String] {
        return categories
    }
    
     // Borrar todos los Places guardados.
     func deleteAllPlaces(){
         for result in fetchSavedPlaces() {
             managedObjectViewContext.delete(result)
         }
         saveContext()
     }
     
     // Borrar un Place en concreto.
     func deletePlace(id: UUID){
         for object in fetchSavedPlaces() {
             if object.id == id {
                 managedObjectViewContext.delete(object)
             }
         }
         saveContext()
     }
    
     // Recuperar un Place específico.
     func fetchPlaceByID(id: UUID) -> Place {
         for object in fetchSavedPlaces() {
             if object.id == id {
                 return object
             }
         }
         
         let emptyPlace: Place = Place()
         return emptyPlace
     }
    
    func fetchPlaceByName(name: String) -> [Place]? {
        var placesToReturn: [Place] = [Place]()
        for object in fetchSavedPlaces() {
            if object.nombre?.lowercased() == name.lowercased() {
                placesToReturn.append(object)
            }
        }
        return placesToReturn
    }
    
    // TESTING FUNCTION
    func fetchPlaceByLocation(latitud: Double, longitud: Double) -> [Place] {
        var placesToReturn: [Place] = [Place]()
        for object in fetchSavedPlaces() {
            if object.latitud == latitud && object.longitud == longitud {
                placesToReturn.append(object)
            }
        }
        return placesToReturn
    }
    
     // Recuperar la lista de Places guardados.
      func fetchSavedPlaces() -> [Place] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
         
         do {
             placesSaved = try managedObjectViewContext.fetch(request) as! [Place]
         } catch let error {
            print("Error recuperando los Places guardados...\(error.localizedDescription)")
         }
        return placesSaved
     }
    
    
    func image2Data(image: UIImage) -> Data {
        return image.jpegData(compressionQuality: 1)!
    }
    
    func data2Image(data: Data) -> UIImage{
        return UIImage(data: data)!
    }
    
}
