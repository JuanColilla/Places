//
//  PlaceCellController.swift
//  PlacesIB
//
//  Created by Juan Colilla on 29/05/2020.
//  Copyright © 2020 Juan Colilla. All rights reserved.
//

import UIKit

protocol PlaceCellDelegate: class {
    func delete(cell: PlaceCell)
}

class PlaceCell: UICollectionViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: PlaceCellDelegate?
    
    var editing: Bool = false {
        didSet {
            deleteButton.isHidden = !editing
            deleteButton.isUserInteractionEnabled = editing
        }
    }
    
    @IBAction func deletePlaceButton(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    
}
