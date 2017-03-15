//
//  CompareAankoopLijstViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 23/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class CompareAankoopLijstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var receivedData:Array<String>? = []
    
    @IBOutlet weak var tableViewLeft: UITableView!
    @IBOutlet weak var tableViewRight: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Compare view did load!")
        // Do any additional setup after loading the view.
        navigationItem.title = "Vergelijk"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        self.tableViewLeft.reloadData()
        self.tableViewRight.reloadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
   
    
    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    // MARK: - Table setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        
        
        if tableView == self.tableViewLeft {
            tableViewLeft.layer.cornerRadius = 3
            tableViewLeft.layer.masksToBounds = true
            tableViewLeft.layer.borderWidth = 1
    
            count = receivedData?.count
        }
        
        if tableView == self.tableViewRight {
            tableViewRight.layer.cornerRadius = 3
            tableViewRight.layer.masksToBounds = true
            tableViewRight.layer.borderWidth = 1
            
            count = receivedData?.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:Float = 110.0
        if tableView == self.tableViewLeft {
            height = 110.0
        }
        
        if tableView == self.tableViewRight {
            height = 110.0
        }
        return CGFloat(height)
    }
    
    var prijsremaRight:Float? = 0.00
    var prijsremaLeft:Float? = 0.00
    var prijzenRight:Dictionary<IndexPath, Dictionary<String,Float>> = [:]
    var prijzenLeft:Dictionary<IndexPath, Dictionary<String,Float>> = [:]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MedicijnTableViewCell?
        
        
        if tableView == self.tableViewLeft {
            tableViewRight.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
            cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell
            
            // Filter medicijnen
            let predicate = NSPredicate(format: "userdata.aankoop == true")
            self.fetchedResultsController.fetchRequest.predicate = predicate
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }

      
            cell?.selectionStyle = .none
            // Fetch Medicijn
            let medicijn = fetchedResultsController.object(at: indexPath)
            
            // Color cells!!!
            prijsremaLeft = medicijn.rema?.floatValue
            for (ip, dict) in prijzenRight {
                if ip == indexPath {
                    for (_, r) in dict {
                        if prijsremaLeft! > r {
                            tableViewRight.cellForRow(at: indexPath)?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.2).cgColor
                        }
                    }
                }
            }
            // Layout cell
            cell?.layer.cornerRadius = 3
            cell?.layer.masksToBounds = true
            cell?.layer.borderWidth = 1
            
            cell?.mpnm.text = medicijn.mp?.mpnm
            
            cell?.mppnm.text = medicijn.mppnm
            cell?.vosnm.text = medicijn.vosnm_
            cell?.nirnm.text = medicijn.mp?.ir?.nirnm
            
            cell?.pupr.text = "Prijs: \((medicijn.pupr?.floatValue)!) €"
            cell?.rema.text = "remA: \((medicijn.rema?.floatValue)!) €"
            cell?.remw.text = "remW: \((medicijn.remw?.floatValue)!) €"
            cell?.cheapest.text = "gdkp: \(medicijn.cheapest.description)"
            
        }
        
        if tableView == self.tableViewRight {
            tableViewLeft.scrollToRow(at: indexPath, at: .top, animated: true)
            
            cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell

            // Filter medicijnen
            let predicate = NSPredicate(format: "mpp?.mppcv IN %@", receivedData!)
            self.fetchedResultsController.fetchRequest.predicate = predicate

            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }

            
            
            cell?.selectionStyle = .none
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            
            var prijzendict:Dictionary<String,Float> = [:]
            prijsremaRight = medicijn.rema?.floatValue
            prijzendict[medicijn.mppcv!] = prijsremaRight
            prijzenRight[indexPath] = prijzendict

            // Layout cell
            cell?.layer.cornerRadius = 3
            cell?.layer.masksToBounds = true
            cell?.layer.borderWidth = 1
            
            cell?.mpnm.text = medicijn.mp?.mpnm
            
            cell?.mppnm.text = medicijn.mppnm
            cell?.vosnm.text = medicijn.vosnm_
            cell?.nirnm.text = medicijn.mp?.ir?.nirnm
            
            cell?.pupr.text = "Prijs: \((medicijn.pupr?.floatValue)!) €"
            cell?.rema.text = "remA: \((medicijn.rema?.floatValue)!) €"
            cell?.remw.text = "remW: \((medicijn.remw?.floatValue)!) €"
            cell?.cheapest.text = "gdkp: \(medicijn.cheapest.description)"
            
        }
    
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
    }
    
    
    // MARK: - Navigation
    let CellLeftDetailIdentifier = "SegueFromCompareLeftToDetail"
    let CellRightDetailIdentifier = "SegueFromCompareRightToDetail"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellLeftDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableViewLeft.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
            
        case CellRightDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableViewRight.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
        default:
            print("Unknown segue: \(segue.identifier)")
        }
        
    }
    
    // MARK: - Notification Handling
    
    // MARK: -
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "vosnm_", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
}

extension CompareAankoopLijstViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewLeft.beginUpdates()
        tableViewRight.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewLeft.endUpdates()
        tableViewRight.endUpdates()

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableViewLeft.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableViewLeft.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}
