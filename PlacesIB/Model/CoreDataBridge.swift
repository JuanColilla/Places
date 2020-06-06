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
    var placesSaved: [Place] = [Place()]
     
     init() {}
    
    
    func saveContext(){
        do {
            try managedObjectViewContext.save()
            print("Guardado con exito.")
        } catch {
            print("Fallo al guardar..")
        }
    }
    
    
    
     // Guardar un nuevo Place.
    func saveNewPlace(place: Place) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Place", into: managedObjectViewContext) as! Place
        
        entity.id = place.id
        entity.imagen = place.imagen
        entity.nombre = place.nombre
        entity.descripcion = place.descripcion
        entity.latitud = place.latitud
        entity.longitud = place.longitud
        
        saveContext()
        
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
     
    
    
    func updatePlace(place: Place, nombre: String, descripcion: String, location: Double, category: String) {
        if place.nombre != nombre {
            place.nombre = nombre
        }
        if place.descripcion != descripcion {
            place.descripcion = descripcion
        }
//        if place.location != location {
//            place.location = location
//        }
        if place.nombre != nombre {
            place.nombre = nombre
        }
        
         
     }
    
    
    
    func image2Data(image: UIImage) -> Data {
        return image.jpegData(compressionQuality: 1)!
    }
    
    
    
    func data2Image(data: Data) -> UIImage{
        return UIImage(data: data)!
    }
    
    
}
