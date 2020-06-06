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
     
     init() {}
    
    
    func saveContext(){
        do {
            try managedObjectViewContext.save()
            print("Guardado con exito.")
        } catch {
            print("Fallo al guardar..")
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        return managedObjectViewContext
    }
    
     // Borrar todos los Places guardados.
     func deleteAllPlaces(){
         for result in fetchSavedPlaces() {
             managedObjectViewContext.delete(result)
         }
         saveContext()
     }
     
     // Borrar un Place en concreto.
     func deletePlace(nombre: String){
         for object in fetchSavedPlaces() {
             if object.nombre == nombre {
                 managedObjectViewContext.delete(object)
                 print("Se ha borrado con éxito")
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
