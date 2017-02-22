//
//  MedicijnDetailViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 18/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import os.log

class MedicijnDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Fetch Medicijn
    weak var medicijn: Medicijn?
    
    
    //@IBOutlet weak var mpnm: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load!")
        navigationItem.title = "Info: \((medicijn?.mpnm)!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }

    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    // This variable will hold the data being passed from the Source View Controller
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnDetailViewCell.reuseIdentifier, for: indexPath) as? MedicijnDetailViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        // Configure Cell
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        
        // Stack top
        cell.mpnm.text = medicijn?.mpnm
        cell.mppnm.text = medicijn?.mppnm
        
        // Stack middle Center
        cell.vosnm.text = medicijn?.vosnm
        cell.irnm.text = medicijn?.nirnm
        cell.stofnm.text = medicijn?.stofnm
        cell.galnm.text = medicijn?.galnm
        cell.ppgal.text = medicijn?.ppgal
        cell.ti.text = medicijn?.ti
        
        // Stack middle left
        cell.stofcv.text = medicijn?.stofcv
        cell.leeg1.text = " "
        cell.ircv.text = medicijn?.galcv
        cell.galcv.text = medicijn?.galcv
        cell.leeg2.text = " "
        cell.leeg3.text = " "
        
        // Stack Bottom left
        cell.pupr.text = medicijn?.pupr
        cell.rema.text = medicijn?.rema
        cell.remw.text = medicijn?.remw
        cell.index.text = medicijn?.index
        cell.ogc.text = medicijn?.ogc
        cell.law.text = medicijn?.law
        cell.ssecr.text = medicijn?.ssecr
        cell.wadan.text = medicijn?.wadan
        
        // Stack Bottom right
        
        // Stack End Left
        cell.kast.text = "In medicijnkast"
        cell.aankoop.text = "In aankooplijst"
        if medicijn?.kast.hashValue == 0 {
            cell.kastimage.image = #imageLiteral(resourceName: "kruisje")
        } else {
            cell.kastimage.image = #imageLiteral(resourceName: "vinkje")
        }
        if medicijn?.aankoop.hashValue == 0 {
            cell.aankoopimage.image = #imageLiteral(resourceName: "kruisje")
        } else {
            cell.aankoopimage.image = #imageLiteral(resourceName: "vinkje")
        }
        
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.layer.cornerRadius = 3
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    // MARK: - Navigation
    let pvt = "pvtToWeb"
    let mpg = "mpgToWeb"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case pvt:
            let destination = segue.destination as! BCFIWebViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
            
            let selectedLink = medicijn?.link2pvt
            destination.link = selectedLink
        case mpg:
            let destination = segue.destination as! BCFIWebViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
            
            let selectedLink = medicijn?.link2mpg
            destination.link = selectedLink
            
        default:
            print("Unknown segue: \(segue.identifier)")
        }
        
    }
    
    
}
