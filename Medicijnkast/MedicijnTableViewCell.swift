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

    @IBOutlet weak var boxImage: UIImage?
    @IBOutlet weak var mpnm: UILabel!
    @IBOutlet weak var mppnm: UILabel!
    @IBOutlet weak var vosnm: UILabel!
    @IBOutlet weak var nirnm: UILabel!

    @IBOutlet weak var pupr: UILabel!
    @IBOutlet weak var rema: UILabel!
    @IBOutlet weak var remw: UILabel!
    @IBOutlet weak var cheapest: UILabel!
    
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
