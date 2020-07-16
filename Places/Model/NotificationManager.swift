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
        content.title = NSLocalizedString("NotificationTitle", comment: "")
        switch(place.categoria) {
        case NSLocalizedString("Category1", comment: ""):
            content.body = String(format: NSLocalizedString("NotificationContent1", comment: ""), place.nombre!)
            break;
        case NSLocalizedString("Category2", comment: ""):
            content.body = String(format: NSLocalizedString("NotificationContent2", comment: ""), place.nombre!)
            break;
        case NSLocalizedString("Category3", comment: ""):
            content.body =  String(format: NSLocalizedString("NotificationContent3", comment: ""), place.nombre!)
            break;
        case NSLocalizedString("Category4", comment: ""):
            content.body =  String(format: NSLocalizedString("NotificationContent4", comment: ""), place.nombre!)
            break;
        case NSLocalizedString("Category5", comment: ""):
            content.body =  String(format: NSLocalizedString("NotificationContent5", comment: ""), place.nombre!)
            break;
        case NSLocalizedString("Category6", comment: ""):
            content.body =  String(format: NSLocalizedString("NotificationContent6", comment: ""), place.nombre!)
            break;
        default:
            content.body =  String(format: NSLocalizedString("NotificationContent7", comment: ""), place.nombre!)
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
