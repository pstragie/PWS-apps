//
//  AddMedicijnViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class AddMedicijnViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromAddToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //let coreDataManager = CoreDataManager(modelName: "Medicijnkast")
    var infoView = UIView()
    var upArrow = UIView()
    // MARK: - Properties Variables
    var sortDescriptorIndex: Int? = nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    weak var receivedData: MPP?
    var zoekwoord: String? = nil
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    
    // MARK: - Referencing Outlets
    
    @IBOutlet weak var gevondenItemsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    @IBOutlet weak var menuView: UIView!
    
    // MARK: - Referencing Actions
    @IBAction func geavanceerdZoeken(_ sender: UIButton) {
        print(self.infoView.center.y)
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)

            } else {
                self.infoView.center.y += self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)
            }
        }, completion: nil
        )
        
    }
    
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
        print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.menuView.center.x -= self.view.bounds.width
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
    }
    
    @IBAction func showMenuView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            //print("menuView center x: \(self.menuView.center.x)")
            //print("bounds: \(self.view.bounds.width)")
            if self.menuView.center.x >= 0 {
                self.menuView.center.x -= self.view.bounds.width
            } else {
                self.menuView.center.x += self.view.bounds.width
            }
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        menuView.tintColor = UIColor.white
        btnCloseMenuView.isHidden = false
        btnCloseMenuView.isEnabled = true
    }
    
    // MARK: - close menu view
    @IBAction func swipeToCloseMenuView(recognizer: UISwipeGestureRecognizer) {
        print("swipe action")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.menuView.center.x -= self.view.bounds.width
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
    }

    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? MedicijnDetailViewController {
            receivedData = sourceViewController.dataPassed
            print("received data: \(receivedData)")
        }
        print("button pressed")
        var selectedScope: Int = -1
        
        switch segue.identifier {
        case "vosnmToSearch"?:
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
            zoekwoord = (receivedData?.vosnm_)!
            selectedScope = 2
            print("vosnm_: \(zoekwoord!)")
        case "stofnmToSearch"?:
            filterKeyword = "ANY sam.stof.ninnm" /* temp change stofnm */
            sortKeyword = "vosnm_"
            selectedScope = 2
            //let dbSet = receivedData?.sam
            //print(dbSet)
            print("stofnm")
        case "irnmToSearch"?:
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = (receivedData?.mp?.ir?.nirnm)!
            selectedScope = 3
            print("irnm")
        case "galnmToSearch"?:
            filterKeyword = "gal.galnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = (receivedData?.gal?.ngalnm)!
            selectedScope = -1
            print("galnm")
        case "tiToSearch"?:
            filterKeyword = "mp.hyr.ti"
            sortKeyword = "mp.mpnm"
            zoekwoord = (receivedData?.mp?.hyr?.ti)!
            selectedScope = -1
            print("ti")
            
        default:
            filterKeyword = "mppnm"
        }
        self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: selectedScope)
    }
    
    // MARK: - View Life Cycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("View did disappear!")
        self.appDelegate.saveContext()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Addmedicijn View did load!")
        setupLayout()
        setUpSearchBar(selectedScope: -1)
        navigationItem.title = "Zoeken"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        self.updateView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupMenuView()
        setupInfoView()
        setupUpArrow()
        print("view Did Layout subviews")
    }

    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<MPP> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mppnm", ascending: true)]
        var format: String = "mppnm BEGINSWITH[c] %@"
        let predicate = NSPredicate(format: format, "AlotofMumboJumboblablabla")
        fetchRequest.predicate = predicate
        // Create Fetched Results Controller
        
        let context = self.appDelegate.persistentContainer.viewContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func setupMenuView() {
        self.menuView.center.x -= view.bounds.width
        menuView.layer.cornerRadius = 8
        menuView.layer.borderWidth = 1
        menuView.layer.borderColor = UIColor.black.cgColor
        self.btnCloseMenuView.isEnabled = false
    }
    
    func setupInfoView() {
        self.infoView=UIView(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        self.infoView.center.y -= view.bounds.height-120
        infoView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        infoView.layer.cornerRadius = 8
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(infoView)
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar(selectedScope: Int) {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        searchBar.isHidden = false
        searchBar.showsScopeBar = true
        // cope button titles: mpnm, mppnm, vosnm_, nirnnm, alles(mpnm,vosnm,nirnm)
        searchBar.scopeButtonTitles = ["merknaam", "verpakking", "stofnaam", "firmanaam", "alles"]
        searchBar.selectedScopeButtonIndex = selectedScope
        print("Current zoekwoord: \(zoekwoord)")
        searchBar.text = zoekwoord
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }
    
    func setupUpArrow() {
        self.upArrow=UIView(frame:CGRect(x: self.view.bounds.width-52, y: self.view.bounds.height-200, width: 50, height: 50))
        upArrow.isHidden = true
        upArrow.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        upArrow.layer.cornerRadius = 25
        //upArrow.layer.borderWidth = 1
        //upArrow.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(upArrow)
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.setTitle("Top", for: .normal)
        button.layer.cornerRadius = 20
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(scrollToTop), for: UIControlEvents.touchUpInside)
        self.upArrow.addSubview(button)
    }
    
    func scrollToTop() {
        print("Scroll to top button clicked")
        let topOffset = CGPoint(x: 0, y: 0)
        tableView.setContentOffset(topOffset, animated: true)
    }
    // MARK: Layout
    func setupLayout() {
        segmentedButton.setTitle("B....", forSegmentAt: 0)
        segmentedButton.setTitle("..c..", forSegmentAt: 1)
        segmentedButton.setTitle("....e", forSegmentAt: 2)
    }
    
    // MARK: Set Scope
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        /* FILTER SCOPE */

        switch selectedScope {
        case 0:
            print("scope: merknaam")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
        case 1:
            print("scope: verpakking")
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
        case 2:
            print("scope: vosnaam")
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
        case 3:
            print("scope: firmanaam")
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.ir.nirnm"
        case 4:
            print("scope: alles")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
        default:
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
        }
        
        print("scope changed: \(selectedScope)")
        print("filterKeyword: \(filterKeyword)")
        print("searchbar text: \(searchBar.text!)")
        zoekwoord = searchBar.text!
        self.filterContentForSearchText(searchText: searchBar.text!, scopeIndex: selectedScope)
        
        }
    
    // MARK: Set search operator
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedButton.selectedSegmentIndex {
        case 0:
            zoekoperator = "BEGINSWITH"
        case 1:
            zoekoperator = "CONTAINS"
        case 2:
            zoekoperator = "ENDSWITH"
        default:
            zoekoperator = "BEGINSWITH"
            break
        }
        
        print("Segment changed: \(segmentedButton.selectedSegmentIndex)")
        // Focus searchBar (om onmiddellijk typen mogelijk te maken)
        searchBar.updateFocusIfNeeded()
        searchBar.becomeFirstResponder()
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        // Tell the searchBar that the searchBarSearchButton was clicked
        self.tableView.reloadData()
        updateView()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Search should begin editing")
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true
        searchBar.text = zoekwoord
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text did change")
        zoekwoord = searchText
        searchActive = true
        print("Zoekterm: \(searchBar.text)")
        
        self.filterContentForSearchText(searchText: searchText, scopeIndex: self.selectedScope)
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar) {
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterKeyword = "mppnm"
        sortKeyword = "mppnm"
        print("Cancel clicked")
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        zoekwoord = searchBar.text!
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: -1)
        self.tableView.reloadData()
        updateView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("should end editing")
        self.tableView.reloadData()
        return true
    }

    // MARK: Zoekfilter
    func filterContentForSearchText(searchText: String, scopeIndex: Int) {
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate?
        if scopeIndex == 4 || scopeIndex == -1 {
            if searchText.isEmpty == true {
                //print("scope -1 or 3 and no text in searchBar")
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                let predicate1 = NSPredicate(format: "mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@", argumentArray: [searchText, searchText])
                let predicate2 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        } else {
            if searchText.isEmpty == true {
                //print("scope = 0, 1, 2 or 3 and no text in searchBar")
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                predicate = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        }
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
            print("fetching from mpp...")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
        print("filterKeyword: \(filterKeyword)")
        print("sortkeyword \(sortKeyword)")
        print("searchText: \(searchText)")
        self.updateView()
    }
    
    // MARK: - Navigation
    let CellDetailIdentifier = "SegueFromAddToDetail"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
        default:
            print("Unknown segue: \(segue.identifier)")
        }
    }

    // MARK: - View Methods
    private func setupView() {
        updateView()
    }
    
    fileprivate func updateView() {
        print("Updating view...")
        tableView.isHidden = false
        var x:Int
        if let medicijnen = fetchedResultsController.fetchedObjects {
            x = medicijnen.count
            if x == 0 {
                gevondenItemsLabel.isHidden = false
            } else {
            gevondenItemsLabel.isHidden = false
            }
        } else {
            x = 0
            gevondenItemsLabel.isHidden = false
        }
        self.tableView.reloadData()
        gevondenItemsLabel.text = "\(x)"
        activityIndicatorView.isHidden = true
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
    
}
extension AddMedicijnViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("view did end decelerating")
        //print("offset: \(scrollView.contentOffset)")
        if (scrollView.contentOffset.y == 0.0) {  // TOP
            upArrow.isHidden = true
        } else {
            upArrow.isHidden = false
        }
    }
    
    // MARK: table data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let medicijnen = fetchedResultsController.fetchedObjects else { return 0 }
        tableView.layer.cornerRadius = 3
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1
        return medicijnen.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let addToMedicijnkast = UITableViewRowAction(style: .normal, title: "Naar\nMedicijnkast") { (action, indexPath) in
            print("naar medicijnkast")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkast", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedKast"), object: nil)
                print("med saved in medicijnkast")
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )
        }
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        
        let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar\nAankooplijst") { (action, indexPath) in
            print("naar aankooplijst")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.userdata?.setValue(true, forKey: "aankooplijst")
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedAankoop"), object: nil)
                print("med saved in aankooplijst")
            } catch {
                print("med not saved in aankooplijst!")
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )
        }
        addToShoppingList.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:1)
        self.tableView.setEditing(false, animated: true)
        return [addToMedicijnkast, addToShoppingList]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        //cell.backgroundColor = UIColor.blue
        //cell.contentView.backgroundColor = UIColor.purple
        cell.selectionStyle = .none
        
        // Fetch Medicijn
        let medicijn = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1

        if (medicijn.law == "R") {
            cell.boxImage?.image = #imageLiteral(resourceName: "Rx")
        } else {
            cell.boxImage?.image = #imageLiteral(resourceName: "noRx")
        }
        cell.mpnm.text = medicijn.mp?.mpnm
        cell.mppnm.text = medicijn.mppnm
        cell.vosnm.text = medicijn.vosnm_
        cell.nirnm.text = medicijn.mp?.ir?.nirnm
        
        cell.pupr.text = "Prijs: \((medicijn.pupr?.floatValue)!) €"
        cell.rema.text = "remA: \((medicijn.rema?.floatValue)!) €"
        cell.remw.text = "remW: \((medicijn.remw?.floatValue)!) €"
        cell.cheapest.text = "gdkp: \(medicijn.cheapest.description)"
        
        return cell
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
