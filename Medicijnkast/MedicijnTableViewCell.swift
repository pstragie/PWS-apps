//
//  MedicijnTableViewCell.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit

class MedicijnTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "MedicijnCell"

    // MARK: -

    @IBOutlet var Merknaam: UILabel!
    @IBOutlet var Stofnaam: UILabel!
    @IBOutlet var Prijs: UILabel!
    @IBOutlet var BoxImage: UIImageView!
    
    @IBOutlet weak var Aankoop: UILabel!
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
