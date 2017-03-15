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
    
    var context: NSManagedObjectContext?
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromAddToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreDataManager = CoreDataManager(modelName: "Medicijnkast")
    
    // MARK: - Properties Variables
    var sortDescriptorIndex: Int?=nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    weak var receivedData: MPP?
    
    var zoekwoord:String = ""
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    @IBOutlet weak var menuView: UIView!
    
    // MARK: - Referencing Outlets
    
    @IBOutlet weak var gevondenItemsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    
    // MARK: - Referencing Actions
    @IBAction func geavanceerdZoeken(_ sender: UIButton) {
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
            print("menuView center x: \(self.menuView.center.x)")
            print("bounds: \(self.view.bounds.width)")
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
        var zoekwoord: String = ""
        switch segue.identifier {
        case "vosnmToSearch"?:
            filterKeyword = "vosnm_"
            selectedScope = 1
            zoekwoord = (receivedData?.vosnm_)!
            print("vosnm_")
        case "stofnmToSearch"?:
            filterKeyword = "stofnm" /* temp change stofnm */
            selectedScope = -1
            let set = receivedData?.sam
            let set2 = receivedData?.mutableSetValue(forKey: "sam")
            print("set: \(set!)")
            print("set2: \(set2!)")
            //receivedData?.sam?.anyObject()
            //zoekwoord = (receivedData?.sam?.stof?.ninnm)!
            print("stofnm")
        case "irnmToSearch"?:
            filterKeyword = "mp?.ir?.nirnm"
            selectedScope = 2
            zoekwoord = (receivedData?.mp?.ir?.nirnm)!
            print("irnm")
        case "galnmToSearch"?:
            filterKeyword = "gal?.galnm"
            selectedScope = -1
            zoekwoord = (receivedData?.gal?.ngalnm)!
            print("galnm")
        case "tiToSearch"?:
            filterKeyword = "mp?.hyr?.ti"
            selectedScope = -1
            zoekwoord = (receivedData?.mp?.hyr?.ti)!
            print("ti")
            
        default:
            filterKeyword = "mppnm"
        }

        
        self.filterContentForSearchText(searchText: zoekwoord, scopeIndex: selectedScope)
        
    }
    
    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mppnm", ascending: true)]
        var format: String = "mppnm BEGINSWITH[c] %@"
        let predicate = NSPredicate(format: format, "A")
        fetchRequest.predicate = predicate
        print("Predicate = \(predicate)")
        // Create Fetched Results Controller
        let moc1 = self.appDelegate.viewContext
        let moc2 = self.coreDataManager.managedObjectContext
        let moc3 = self.context
        print(moc1)
        print(moc2)
        print(moc3)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        print(fetchedResultsController)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("View did disappear!")
        self.appDelegate.saveContext()

    }
    override func viewDidLayoutSubviews() {
        setupMenuView()
        print("view Did Layout subviews")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Addmedicijn View did load!")
        setupLayout()
        setUpSearchBar()
        navigationItem.title = "Zoeken"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if #available(iOS 10.0, *) {
            context = self.appDelegate.viewContext
        } else {
            context = self.coreDataManager.managedObjectContext
        }

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
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        
        searchBar.isHidden = false
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["merknaam", "stofnaam", "firmanaam", "alles"]
        searchBar.selectedScopeButtonIndex = -1
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
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
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
        case 1:
            print("scope: vosnaam")
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
        case 2:
            print("scope: firmanaam")
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
        case 3:
            print("scope: alles")
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
        default:
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
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
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
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
        zoekwoord = ""
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
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
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
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: -1)
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
        
        if scopeIndex == 3 || scopeIndex == -1 {
            if searchText.isEmpty == true {
                print("scope -1 or 3 and no text in searchBar")
                //let predicate = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
                //self.fetchedResultsController.fetchRequest.predicate = predicate
                
            } else {
                format = "mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@"
                let predicate = NSPredicate(format: format, argumentArray: [searchText, searchText])
                self.fetchedResultsController.fetchRequest.predicate = predicate
            }
            
        } else {
            if searchText.isEmpty == true {
                print("scope = 0, 1 or 2 and no text in searchBar")
                //let predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
                //self.fetchedResultsController.fetchRequest.predicate = predicate
            } else {
                if filterKeyword == "alles" {
                    print("strange?")
                    format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                    let predicate = NSPredicate(format: format, argumentArray: [searchText, searchText])
                    self.fetchedResultsController.fetchRequest.predicate = predicate
                } else {
                    let predicate = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                    print("predicate: \(predicate)")
                    self.fetchedResultsController.fetchRequest.predicate = predicate
                }
            }
        }
        
        let sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            try self.fetchedResultsController.performFetch()
            print("fetching...")
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
            medicijn.setValue(true, forKey: "kast")
            //let context = self.appDelegate.viewContext
            self.context?.perform {
                do {
                    try self.context?.save()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedKast"), object: nil)
                    print("saved!")
                } catch {
                    print(error.localizedDescription)
                }
                self.appDelegate.saveContext()
            }
        }
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar\nAankooplijst") { (action, indexPath) in
            print("naar aankooplijst")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.setValue(true, forKey: "aankoop")
            //let context = self.appDelegate.viewContext
            do {
                try self.context?.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedAankoop"), object: nil)
                print("med saved in aankooplijst")
            } catch {
                print("med not saved in aankooplijst!")
            }
            
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
    
}
