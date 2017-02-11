//
//  SearchMedicijnTableViewCell.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit

class SearchMedicijnTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "NieuwMedicijnCell"
    
    @IBOutlet weak var Merknaam: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
