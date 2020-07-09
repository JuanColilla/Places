//
//  SettingsTableViewController.swift
//  Places
//
//  Created by Juan Colilla on 07/06/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let options: [String] = ["Borrar todos los datos", "Donar al desarrollador"]
    let coreDataBridge : CoreDataBridge = CoreDataBridge()
    let locationManager: LocationManager = LocationManager()
    let notificationManager: NotificationManager = NotificationManager()
    private let reusableCell = "SettingsCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! SettingsTableViewCell
        cell.settingsButtonLabel.text = options[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = self.tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        
        selectedCell.isSelected = false
        
        if (selectedCell.settingsButtonLabel.text == options[0]) {
            let alertSheet = UIAlertController(title: "Borrado", message: "Estás a punto de borrar todos los datos guardados.", preferredStyle: .alert)
            
            alertSheet.addAction(UIAlertAction(title: "Borrar", style: .default, handler: { (action: UIAlertAction) in
                
                let placesToDelete = self.coreDataBridge.fetchSavedPlaces()
                var identifiers: [String] = []
                
                for place in placesToDelete {
                    identifiers.append(place.nombre!)
                }
                
                self.coreDataBridge.deleteAllPlaces()
                self.locationManager.deleteAllRegions()
                self.notificationManager.deleteNotificationRequest(identifiers: identifiers)
                
            }))
            
            alertSheet.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction) in }))
            
            self.present(alertSheet, animated: true, completion: nil)
            
        } else {
            if let url = URL(string:"https://paypal.me/JuanColilla") {
               UIApplication.shared.open(url)
            }
        }
    }
}
