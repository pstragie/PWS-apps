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
    
    
    @IBAction func moreButton(_ sender: UIButton) {
    }
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //@IBOutlet weak var mpnm: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load!")
        navigationItem.title = "Info: \(medicijn?.mpnm)"
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
        cell.mpnm.text = medicijn?.mpnm
        cell.mppnm.text = medicijn?.mppnm
        cell.vosnm.text = medicijn?.vosnm
        cell.irnm.text = medicijn?.nirnm
        
        cell.kast.text = "In medicijnkast"
        cell.kastswitch.setOn((medicijn?.kast)!, animated: true)
        cell.aankoop.text = "In aankooplijst"
        cell.aankoopswitch.setOn((medicijn?.aankoop)!, animated: true)
        
        cell.moreButton()
        
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
    let CellDetailIdentifier = "SegueFromDetailToWebView"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! BCFIWebViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
            navigationController?.pushViewController(destination, animated: true)
        default:
            print("Unknown segue: \(segue.identifier)")
        }
        
    }
    
    
}
