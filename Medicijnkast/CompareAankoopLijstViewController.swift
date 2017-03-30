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

    // MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var receivedData:Array<Array<String>>? = []
    var slideUpInfoView = UIView()
    var prijsremaRight:Float? = 0.00
    var prijsremaLeft:Float? = 0.00
    var prijzenRight:Dictionary<IndexPath, Dictionary<String,Float>> = [:]
    var prijzenLeft:Dictionary<IndexPath, Dictionary<String,Float>> = [:]
    let CellLeftDetailIdentifier = "SegueFromCompareLeftToDetail"
    let CellRightDetailIdentifier = "SegueFromCompareRightToDetail"
    @IBOutlet weak var tableViewLeft: UITableView!
    @IBOutlet weak var tableViewRight: UITableView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Compare view did load!")
        // Do any additional setup after loading the view.
        navigationItem.title = "Vergelijk"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        do {
            try self.fetchedResultsControllerLeft.performFetch()
            try self.fetchedResultsControllerRight.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        self.tableViewLeft.bounces = true
        self.tableViewRight.bounces = true
        self.tableViewLeft.reloadData()
        self.tableViewRight.reloadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupSlideUpInfoView()
        checkForDoubles()
    }
    
    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    // MARK: - Check for doubles (vosnm_) in aankooplijst en verwittig de gebruiker
    func checkForDoubles() {
        // Fetch en count aankooplijst
        var inAankooplijst: Int = 0
        let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
        let predicate = NSPredicate(format: "userdata.aankooplijst == true")
        fetchReq.predicate = predicate
        do {
            let resultaat = try self.appDelegate.persistentContainer.viewContext.fetch(fetchReq)
            inAankooplijst = resultaat.count
        } catch {
            print("fetching error in calculateCheapestPrice")
        }

        let inCompare = receivedData?[0].count
        if inCompare! < inAankooplijst {
            // Show message
            slideUpAlert()
        }
    }
    // MARK: - Setup slide info view
    func setupSlideUpInfoView() {
        self.slideUpInfoView=UIView(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 160))
        //self.slideUpInfoView.addGestureRecognizer(.init(target: slideUpInfoView, action: #selector(slideUpAlert())))
        self.slideUpInfoView.center.y += view.bounds.height
        print("setup: \(self.slideUpInfoView.center.y)")
        slideUpInfoView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        slideUpInfoView.layer.cornerRadius = 8
        slideUpInfoView.layer.borderWidth = 1
        slideUpInfoView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(slideUpInfoView)
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: self.view.bounds.width-60, height: 160)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "U heeft meerdere medicijnen in uw aankooplijst met dezelde voorschriftnaam. Enkel unieke medicijnen worden hier getoond."
        label.layer.cornerRadius = 20
        label.textColor = UIColor.white
        self.slideUpInfoView.addSubview(label)
    }
    
    // MARK: - Show Alert
    func slideUpAlert() {
        UIView.animate(withDuration: 0.1, delay: 0.5, options: [.curveEaseIn], animations: {
            print(self.slideUpInfoView.center.y)
            if self.slideUpInfoView.center.y >= self.view.bounds.height {
                self.slideUpInfoView.center.y -= 200
            } else {
                self.slideUpInfoView.center.y += 200
            }
            print(self.slideUpInfoView.center.y)
        }, completion: {_ in UIView.animate(withDuration: 0.1, delay: 1.0, animations: {
            print(self.slideUpInfoView.center.y)
            if self.slideUpInfoView.center.y >= self.view.bounds.height {
                self.slideUpInfoView.center.y -= 200
            } else {
                self.slideUpInfoView.center.y += 200
            }
            print(self.slideUpInfoView.center.y)
        })}
        )
    }
    
    // MARK: - Text alert
    func openTextAlert() {
        // Create Alert Controller
        let alertCompare = UIAlertController(title: "Dubbele medicijnen", message: "U heeft meerdere medicijnen met dezelfde voorschriftnaam (maar in andere dosis) in uw aankooplijst. Deze vergelijking toont enkele unieke voorschriften.", preferredStyle: UIAlertControllerStyle.alert)
        // Create cancel action
        //let cancelAlert = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        //alertCompare.addAction(cancel9)
        // Create OK Action
        let okCompare = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in print("OK")
        }
        alertCompare.addAction(okCompare)
        // Present Alert Controller
        self.present(alertCompare, animated:true, completion:nil)
    }

    // MARK: - Table setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        let objectsLeft = receivedData?[0]
        let objectsRight = receivedData?[1]
        
        if tableView == self.tableViewLeft {
            tableViewLeft.layer.cornerRadius = 3
            tableViewLeft.layer.masksToBounds = true
            tableViewLeft.layer.borderWidth = 1
            count = objectsLeft?.count
        }
        
        if tableView == self.tableViewRight {
            tableViewRight.layer.cornerRadius = 3
            tableViewRight.layer.masksToBounds = true
            tableViewRight.layer.borderWidth = 1
            count = objectsRight?.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MedicijnTableViewCell?
        let objectsLeft = receivedData?[0]
        let objectsRight = receivedData?[1]
        
        if tableView == self.tableViewLeft {
            //tableViewRight.scrollToRow(at: indexPath, at: .top, animated: true)
            cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell
            
            // Filter medicijnen
            let predicate = NSPredicate(format: "mppcv IN %@", objectsLeft!)
            self.fetchedResultsControllerLeft.fetchRequest.predicate = predicate
            
            do {
                try self.fetchedResultsControllerLeft.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }

            cell?.selectionStyle = .none
            // Fetch Medicijn
            let medicijn = fetchedResultsControllerLeft.object(at: indexPath)
            
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
            //tableViewLeft.scrollToRow(at: indexPath, at: .top, animated: true)
            cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell

            // Filter medicijnen
            let predicate = NSPredicate(format: "mppcv IN %@", objectsRight!)
            self.fetchedResultsControllerRight.fetchRequest.predicate = predicate

            do {
                try self.fetchedResultsControllerRight.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }

            cell?.selectionStyle = .none
            // Fetch Medicijn
            let medicijn = self.fetchedResultsControllerRight.object(at: indexPath)
            
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView == tableViewLeft {
            let origineelMedicijn = self.fetchedResultsControllerLeft.object(at: indexPath)
            if origineelMedicijn.userdata?.aankooplijst == true {
                return .none
            }
        }
        return .delete
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var btnArray = [UITableViewRowAction()]
        if tableView == self.tableViewLeft {
            let undoReplace = UITableViewRowAction(style: .normal, title: "Annuleer") { (action, indexPath) in
                // Fetch Origineel Medicijn
                let origineelMedicijn = self.fetchedResultsControllerLeft.object(at: indexPath)
                if origineelMedicijn.userdata?.aankooplijst == false {
                    let context = self.appDelegate.persistentContainer.viewContext
                    self.addUserData(mppcvValue: origineelMedicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
                    
                    // Fetch alternative medicijn in aankooplijst
                    let altmedicijn = self.fetchedResultsControllerRight.object(at: indexPath)
                    self.addUserData(mppcvValue: altmedicijn.mppcv!, userkey: "aankooplijst", uservalue: false, managedObjectContext: context)
                    let cell = self.tableViewLeft.cellForRow(at: indexPath)
                    cell?.layer.backgroundColor = UIColor.white.cgColor
                    
                    do {
                        try self.fetchedResultsControllerLeft.performFetch()
                        try self.fetchedResultsControllerRight.performFetch()
                    } catch {
                        let fetchError = error as NSError
                        print("Unable to Perform Fetch Request")
                        print("\(fetchError), \(fetchError.localizedDescription)")
                    }
                    self.tableViewLeft.reloadData()
                    self.tableViewRight.reloadData()
                }
            }
            undoReplace.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:0.5)
            self.tableViewLeft.setEditing(false, animated: true)
            btnArray.append(undoReplace)
        }
        
        if tableView == self.tableViewRight {
            let replaceInShoppingList = UITableViewRowAction(style: .normal, title: "Naar\nAankooplijst") { (action, indexPath) in
                // Fetch Medicijn
                let altmedicijn = self.fetchedResultsControllerRight.object(at: indexPath)
                let context = self.appDelegate.persistentContainer.viewContext
                self.addUserData(mppcvValue: altmedicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
                
                // Fetch the original medicine in aankooplijst
                let aankoopmedicijn = self.fetchedResultsControllerLeft.object(at: indexPath)
                self.addUserData(mppcvValue: aankoopmedicijn.mppcv!, userkey: "aankooplijst", uservalue: false, managedObjectContext: context)
                let cell = self.tableViewLeft.cellForRow(at: indexPath)
                cell?.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                
                do {
                    try self.fetchedResultsControllerLeft.performFetch()
                    try self.fetchedResultsControllerRight.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                self.tableViewLeft.reloadData()
                self.tableViewRight.reloadData()
                
            }
            replaceInShoppingList.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:0.5)
            self.tableViewRight.setEditing(false, animated: true)
            btnArray.append(replaceInShoppingList)
        }
        return btnArray
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellLeftDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableViewLeft.indexPathForSelectedRow!
            let selectedObject = fetchedResultsControllerLeft.object(at: indexPath)
            destination.medicijn = selectedObject
        case CellRightDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableViewRight.indexPathForSelectedRow!
            let selectedObject = fetchedResultsControllerRight.object(at: indexPath)
            destination.medicijn = selectedObject
        default:
            print("Unknown segue: \(segue.identifier)")
        }
    }
    
    // MARK: - Notification Handling
    
    // MARK: - Fetch Results
    fileprivate lazy var fetchedResultsControllerLeft: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "vosnm_", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsControllerLeft = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsControllerLeft.delegate = self
        
        return fetchedResultsControllerLeft
    }()
    
    fileprivate lazy var fetchedResultsControllerRight: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "vosnm_", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsControllerRight = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsControllerRight.delegate = self
        
        return fetchedResultsControllerRight
    }()
    
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
    
    // MARK: - Synchronous scrolling behaviour
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(tableViewLeft), scrollView.isDragging {
            var offset = tableViewRight.contentOffset
            offset.y = tableViewLeft.contentOffset.y
            print("offset left: \(offset.y)")
            tableViewRight.setContentOffset(offset, animated: true)
        } else if scrollView.isEqual(tableViewRight), scrollView.isDragging {
            var offset = tableViewLeft.contentOffset
            offset.y = tableViewRight.contentOffset.y
            print("offset right: \(offset.y)")
            tableViewLeft.setContentOffset(offset, animated: true)
        }
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
    
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        return result
    }
    
    private func fetchRecordsForEntity(_ entity: String, key: String, arg: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let predicate = NSPredicate(format: "%K == %@", key, arg)
        fetchRequest.predicate = predicate
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                result = records
            }
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        return result
    }
    
    func addUserData(mppcvValue: String, userkey: String, uservalue: Bool, managedObjectContext: NSManagedObjectContext) {
        // one-to-one relationship
        // Check if record exists
        let userdata = fetchRecordsForEntity("Userdata", key: "mppcv", arg: mppcvValue, inManagedObjectContext: managedObjectContext)
        if userdata.count == 0 {
            print("data line does not exist")
            if let newUserData = createRecordForEntity("Userdata", inManagedObjectContext: managedObjectContext) {
                newUserData.setValue(uservalue, forKey: userkey)
                newUserData.setValue(mppcvValue, forKey: "mppcv")
                let mpps = fetchRecordsForEntity("MPP", key: "mppcv", arg: mppcvValue, inManagedObjectContext: managedObjectContext)
                newUserData.setValue(Date(), forKey: "lastupdate")
                for mpp in mpps {
                    mpp.setValue(newUserData, forKeyPath: "userdata")
                }
            }
        } else {
            print("data line exists")
            for userData in userdata {
                userData.setValue(uservalue, forKey: userkey)
                userData.setValue(mppcvValue, forKey: "mppcv")
                userData.setValue(Date(), forKey: "lastupdate")
            }
        }
    }
}
