//
//  KastMenuCell.swift
//  MedCabinet.be Nederlands
//
//  Created by Pieter Stragier on 05/03/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit

class KastMenuCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "KastMenuCell"
    
    // MARK: -
    
    @IBOutlet weak var persoon: UILabel!
    
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
