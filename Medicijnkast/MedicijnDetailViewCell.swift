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
    
    
    @IBOutlet var stofnm: UILabel!
    @IBOutlet var vosnm: UILabel!
    @IBOutlet var irnm: UILabel!
    @IBOutlet weak var galnm: UILabel!
    @IBOutlet weak var ppgal: UILabel!
    @IBOutlet weak var ti: UILabel!
    
    @IBOutlet weak var stofcv: UILabel!
    @IBOutlet weak var leeg1: UILabel!
    @IBOutlet weak var ircv: UILabel!
    @IBOutlet weak var galcv: UILabel!
    @IBOutlet weak var leeg2: UILabel!
    @IBOutlet weak var leeg3: UILabel!
    
    @IBOutlet weak var pupr: UILabel!
    @IBOutlet weak var rema: UILabel!
    @IBOutlet weak var remw: UILabel!
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var ogc: UILabel!
    @IBOutlet weak var law: UILabel!
    @IBOutlet weak var ssecr: UILabel!
    @IBOutlet weak var wadan: UILabel!
    
    @IBOutlet weak var cheapest: UILabel!
    @IBOutlet weak var narcotic: UILabel!
    @IBOutlet weak var orphan: UILabel!
    @IBOutlet weak var amb: UILabel!
    @IBOutlet weak var hosp: UILabel!
    @IBOutlet weak var specrules: UILabel!
    @IBOutlet weak var bt: UILabel!
    @IBOutlet weak var pip: UILabel!
    
    
    @IBOutlet var kast: UILabel!
    @IBOutlet weak var kastimage: UIImageView!
    @IBOutlet var aankoop: UILabel!
    @IBOutlet weak var aankoopimage: UIImageView!
    
    @IBAction func morePVT(_ sender: UIButton) {
        moreButton.layer.cornerRadius = 3
        moreButton.layer.borderWidth = 2
        moreButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBOutlet weak var moreButton: UIButton!
    @IBAction func moreMPG(_ sender: UIButton) {
        moreButton.layer.cornerRadius = 3
        moreButton.layer.borderWidth = 2
        moreButton.layer.borderColor = UIColor.black.cgColor
    }

    @IBOutlet weak var noteButton: UIButton!
    @IBAction func showNotes(_sender: UIButton) {
        noteButton.layer.cornerRadius = 3
        noteButton.layer.borderWidth = 2
        noteButton.layer.borderColor = UIColor.white.cgColor
        // show popover
    }
    
    
    
    
    
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
