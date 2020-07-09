//
//  NotificationManager.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager {
    
    let center = UNUserNotificationCenter.current()
    var permission: Bool = false
    
    init() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if (granted) {
                self.permission = true
            } else {
                self.permission = false
            }
        }
    }
    
    func createNotification(place: Place) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Próximo a ti"
        switch(place.categoria) {
        case "Restauración":
            content.body = "Estás cerca de " + place.nombre! + ", quizás hoy podría ser el día."
            break;
        case "Recuerdo":
            content.body = "En " + place.nombre! + " guardas un recuerdo especial para ti, ¿te apetecería revivirlo?"
            break;
        case "Edificio emblemático":
            content.body = place.nombre! + " está cerca, ¿qué te parece pasarte a admirar un poco las vistas?"
            break;
        case "Paisaje natural":
            content.body = "Estás cerca de " + place.nombre! + ", puede ser buen momento para desconectar y respirar hondo."
            break;
        case "Ruta":
            content.body = "Vas por buen camino, ¿qué te parece si tomas la ruta " + place.nombre! + " que tienes guardada?"
            break;
        case "Punto de interés":
            content.body = "Recuerda que " + place.nombre! + " está cerca, quizás te interesa pasarte un rato."
            break;
        default:
            content.body = "Guardaste " + place.nombre! + " en su día, ¿te aptece acercarte?"
            break;
        }
        content.sound = UNNotificationSound.default
        return content
    }
    
    func setTriggerNotification(region: CLRegion) -> UNLocationNotificationTrigger {
        return UNLocationNotificationTrigger(region: region, repeats: false)
    }
    
    func addNotificationRequest(identifier: String, content: UNMutableNotificationContent, trigger: UNLocationNotificationTrigger) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    func deleteNotificationRequest(identifiers: [String?]) {
        if identifiers.count > 0 {
            for index in 0..<identifiers.count {
                if identifiers[index] != nil {
                    center.removePendingNotificationRequests(withIdentifiers: [identifiers[index]!])
                }
            }
        }
    }
}
