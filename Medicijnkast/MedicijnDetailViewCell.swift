//
//  MedicijnDetailViewCell.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 18/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit

class MedicijnDetailViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "MedicijnDetailViewCell"
    
    // MARK: -
    
    @IBOutlet var mpnm: UILabel!
    @IBOutlet var mppnm: UILabel!
    @IBOutlet var vosnm: UILabel!
    @IBOutlet var irnm: UILabel!
    @IBOutlet var kast: UILabel!
    @IBOutlet var aankoop: UILabel!
    
    @IBOutlet weak var kastswitch: UISwitch!
    @IBOutlet weak var aankoopswitch: UISwitch!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
