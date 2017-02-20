//
//  Updates.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 20/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol UpdateDelegate {
    func didUpdate(sender: Updates)
}

class Updates: UpdateDelegate {
    internal func didUpdate(sender: Updates) {
        self.delegate?.didUpdate(sender: self)
    }

    

    var delegate: UpdateDelegate?
    
    //self.delegate.didUpdate(self)
}
