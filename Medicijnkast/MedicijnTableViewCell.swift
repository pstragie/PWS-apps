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

    // MARK: - Outlets
    @IBOutlet weak var H_label: UILabel!
    @IBOutlet weak var Rx_label: UILabel!
    @IBOutlet weak var Wada_label: UILabel!
    @IBOutlet weak var Cheap_label: UILabel!
    @IBOutlet weak var mpnm: UILabel!
    @IBOutlet weak var mppnm: UILabel!
    @IBOutlet weak var vosnm: UILabel!
    @IBOutlet weak var nirnm: UILabel!
    @IBOutlet weak var hyr: UILabel!

    @IBOutlet weak var pupr: UILabel!
    @IBOutlet weak var rema: UILabel!
    @IBOutlet weak var remw: UILabel!
    @IBOutlet weak var cheapest: UILabel!
    @IBOutlet weak var iconKast: UIImageView!
    @IBOutlet weak var iconLijst: UIImageView!
    
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
