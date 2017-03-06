//
//  ShoppingListViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 09/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromShopToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreData = CoreDataStack()
    
    // MARK: - Properties Variables
    var totalePrijs:Dictionary<String,Float> = [:]
    var gdkp:Dictionary<String,Dictionary<String,Float>> = [:] /* [vosnm: [mpnm, 8.70] */
    var gdkpprijs:Float = 0.0
    var gdkpnaam:Dictionary<String,String> = [:] /* [vosnm: mpnm */
    var verschil:Float = 0.0

    var sortDescriptorIndex: Int?=nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    
    var zoekwoord:String = ""
    var filterKeyword:String = "mpnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mpnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mpnm"
    
    // MARK: - Referencing Outlets
    @IBOutlet weak var showGraphButton: UIButton!
    @IBOutlet weak var popButton: UIButton!
    @IBOutlet weak var totalePupr: UILabel!
    @IBOutlet weak var totaalRemA: UILabel!
    @IBOutlet weak var totaalRemW: UILabel!
    
    @IBOutlet weak var altPupr: UILabel!
    @IBOutlet weak var altRema: UILabel!
    @IBOutlet weak var altRemw: UILabel!
    
    @IBOutlet weak var verschilPupr: UILabel!
    @IBOutlet weak var verschilRema: UILabel!
    @IBOutlet weak var verschilRemw: UILabel!
    
    @IBOutlet weak var totaalAantal: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet weak var showAlternativeButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var graphView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bestellen: UIBarButtonItem!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    // MARK: - Referencing Actions
    @IBAction func popButton(_ sender: UIButton) {
        print("popButton pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.graphView.center.x -= self.view.bounds.width
        }, completion: nil
        )
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        popButton.isHidden = true
        popButton.isEnabled = false
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
                self.btnCloseMenuView.isHidden = true
                self.btnCloseMenuView.isEnabled = false
            } else {
                self.menuView.center.x += self.view.bounds.width
                if self.graphView.center.x >= 0 {
                    self.graphView.center.x -= self.view.bounds.width
                }
            }
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        menuView.tintColor = UIColor.white
        btnCloseMenuView.isHidden = false
        btnCloseMenuView.isEnabled = true
        popButton.isEnabled = false
        popButton.isHidden = true
        
    }

    @IBAction func swipeToCloseMenuView(recognizer: UISwipeGestureRecognizer) {
        print("swipe action")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.menuView.center.x -= self.view.bounds.width
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
        self.popButton.isEnabled = false
        self.menuView.center.x -= self.view.bounds.width
        
    }
    
    @IBAction func swipeToCloseGraphView(recognizer: UISwipeGestureRecognizer) {
        print("swipe action")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.menuView.center.x -= self.view.bounds.width
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        popButton.isHidden = true
        popButton.isEnabled = false
    }
    
    @IBAction func showAlternativeButton(_ sender: UIButton) {
    }
    @IBAction func closeGraphView(_ sender: UIButton) {
        //view.willRemoveSubview(blurEffectView)
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.graphView.center.x -= self.view.bounds.width
            self.popButton.isEnabled = false
        }, completion: nil
        )
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        popButton.isHidden = true
    }
    
    @IBAction func showGraphView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            print("graphView center x: \(self.graphView.center.x)")
            print("bounds: \(self.view.bounds.width)")
            if self.graphView.center.x >= 0 {
                print(">0: \(self.graphView.center.x)")
                self.graphView.center.x -= self.view.bounds.width
                self.popButton.isEnabled = false
            } else {
                print("<0: \(self.graphView.center.x)")
                self.graphView.center.x += self.view.bounds.width
                self.popButton.isEnabled = true
            }
        }, completion: nil
        )
        
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        graphView.tintColor = UIColor.white
        popButton.isHidden = false
        
        
    }
    
    func setupMenuView() {
        self.menuView.center.x -= view.bounds.width
        menuView.layer.cornerRadius = 8
        menuView.layer.borderWidth = 1
        menuView.layer.borderColor = UIColor.black.cgColor
        self.btnCloseMenuView.isHidden = true
        self.btnCloseMenuView.isEnabled = false
    }
    
    func setupGraphView() {
        print("original x: \(self.graphView.center.x)")
        self.graphView.center.x -= view.bounds.width
        print("new x: \(self.graphView.center.x)")
        graphView.layer.cornerRadius = 8
        graphView.layer.borderWidth = 1
        graphView.layer.borderColor = UIColor.black.cgColor
        showGraphButton.layer.cornerRadius = 8
        self.popButton.isEnabled = false
        self.popButton.isHidden = true
    }
    
    @IBAction func geavanceerdZoeken(_ sender: UIButton) {
    }
    
    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Medicijn> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mpnm", ascending: true)]
        let predicate = NSPredicate(format: "aankoop == true")
        fetchRequest.predicate = predicate
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.appDelegate.saveContext()
        print("Aankooplijst view will appear, fetching...")
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        rekenen()
        print("berekenen...")
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        tableView.reloadData()
        self.updateView()
    }
    
    override func viewDidLayoutSubviews() {
        setupGraphView()
        setupMenuView()
        print("view Did Layout subviews")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Aankooplijst view did load!")
        setupLayout()
        setUpSearchBar()
        setupView()
        
        navigationItem.title = "Aankooplijst"
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bestellen, target: self, action: #selector(bestellingDoorsturen))
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

    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // MARK: - Bestelling doorsturen
    func bestellingDoorsturen() {
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        
        searchBar.showsScopeBar = false
        searchBar.scopeButtonTitles = ["merknaam", "stofnaam", "firmanaam", "alles"]
        searchBar.selectedScopeButtonIndex = -1
        print("Scope: \(searchBar.selectedScopeButtonIndex)")
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
        searchActive = true
        switch selectedScope {
        case 0:
            print("scope: merknaam")
            filterKeyword = "mpnm"
            sortKeyword = "mpnm"
        case 1:
            print("scope: stofnaam")
            filterKeyword = "vosnm"
            sortKeyword = "vosnm"
        case 2:
            print("scope: firmanaam")
            filterKeyword = "nirnm"
            sortKeyword = "nirnm"
        case 3:
            print("scope: alles")
            filterKeyword = "alles"
            sortKeyword = "mpnm"
        default:
            filterKeyword = "mpnm"
            sortKeyword = "mpnm"
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
        filterKeyword = "mpnm"
        sortKeyword = "mpnm"
        print("Cancel clicked")
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        zoekwoord = searchBar.text!
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: -1)
        //tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
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
                let predicate = NSPredicate(format: "aankoop == true")
                self.fetchedResultsController.fetchRequest.predicate = predicate
                
            } else {
                format = ("mpnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@ || nirnm \(zoekoperator)[c] %@")
                let predicate1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
                let predicate2 = NSPredicate(format: "aankoop == true")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                self.fetchedResultsController.fetchRequest.predicate = predicate
            }
            
        } else {
            if searchText.isEmpty == true {
                print("scope = 0, 1 or 2 and no text in searchBar")
                let predicate = NSPredicate(format: "aankoop == true")
                self.fetchedResultsController.fetchRequest.predicate = predicate
            } else {
                if filterKeyword == "alles" {
                    format = ("mpnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@")
                    let predicate1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
                    let predicate2 = NSPredicate(format: "aankoop == true")
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                    self.fetchedResultsController.fetchRequest.predicate = predicate
                } else {
                    let predicate1 = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                    let predicate2 = NSPredicate(format: "aankoop == true")
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
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
    let CellDetailIdentifier = "SegueFromShopToDetail"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
            
        case "SegueFromShopToCompare":
            let destination = segue.destination as! CompareAankoopLijstViewController
            let gdkp = fetchCheapest(categorie: "rema")
            let gdkpnaam = alternatieven(vosdict: gdkp, categorie: "rema")
            var gdkpmppcv:Array<String> = []
            for (_, v) in gdkpnaam {
                gdkpmppcv.append(v)
            }
            let selectedObject:Array<String> = gdkpmppcv
            destination.receivedData = selectedObject
        default:
            print("Unknown segue: \(segue.identifier)")
        }
    }
    
    // MARK: - View Methods
    private func TotalePrijs(managedObjectContext: NSManagedObjectContext) -> Dictionary<String,Float> {
        let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let pred = NSPredicate(format: "aankoop == true")
        fetchReq.predicate = pred
        
        var totaleprijs:Dictionary<String,Float> = [:]
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        var totpupr: Float = 0.0
        var totrema: Float = 0.0
        var totremw: Float = 0.0
        do {
            let medicijnen = try managedObjectContext.fetch(fetchReq)
            for med in medicijnen {
                totpupr += (med.pupr?.floatValue)!
                totrema += (med.rema?.floatValue)!
                totremw += (med.remw?.floatValue)!
            }
            totaleprijs["pupr"] = totpupr
            totaleprijs["rema"] = totrema
            totaleprijs["remw"] = totremw
            

        } catch {
            return ["pupr":1.0, "rema":1.0, "remw":1.0]
        }
        return totaleprijs
    }

    private func rekenen() {
        // Rekenen
        
        totalePrijs = TotalePrijs(managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext)
        totalePupr.text = "\((totalePrijs["pupr"])!) €"
        totaalRemA.text = "\((totalePrijs["rema"])!) €"
        totaalRemW.text = "\((totalePrijs["remw"])!) €"
        
        let cheappupr = fetchCheapest(categorie: "pupr")
        let cheaprema = fetchCheapest(categorie: "rema")
        let cheapremw = fetchCheapest(categorie: "remw")
        let gdkpaltpupr = berekenGoedkoopsteAlternatief(vosdict: cheappupr, categorie: "pupr")
        let gdkpaltrema = berekenGoedkoopsteAlternatief(vosdict: cheaprema, categorie: "rema")
        let gdkpaltremw = berekenGoedkoopsteAlternatief(vosdict: cheapremw, categorie: "remw")
        altPupr.text = "\(gdkpaltpupr) €"
        altRema.text = "\(gdkpaltrema) €"
        altRemw.text = "\(gdkpaltremw) €"
        
        verschilPupr.text = "\(berekenVerschil(categorie: "pupr", huidig: totalePrijs, altern: gdkpaltpupr)) €"
        verschilRema.text = "\(berekenVerschil(categorie: "rema", huidig: totalePrijs, altern: gdkpaltrema)) €"
        verschilRemw.text = "\(berekenVerschil(categorie: "remw", huidig: totalePrijs, altern: gdkpaltremw)) € "
    }
    
    private func setupView() {
        setupMessageLabel()
    }
    
    fileprivate func updateView() {
        print("Updating view...")
        var hasMedicijnen = false
        
        var x:Int
        
        if let medicijnen = fetchedResultsController.fetchedObjects {
            hasMedicijnen = medicijnen.count > 0
            print("medicijnen aantal: \(medicijnen.count)")
            
            x = medicijnen.count
            
            let totaalAankoop = countAankoop(managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext)
            if searchActive || hasMedicijnen {
                totaalAantal.text = "\(x)/\(totaalAankoop)"
                tableView.isHidden = false
                messageLabel.isHidden = true
                self.tableView.reloadData()
            } else {
                totaalAantal.text = "\(totaalAankoop)"
            }
            
        } else {
            tableView.isHidden = !hasMedicijnen
            messageLabel.isHidden = hasMedicijnen
            tableView.reloadData()
        }
    }
    
    private func countAankoop(managedObjectContext: NSManagedObjectContext) -> Int {
        let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let pred = NSPredicate(format: "aankoop == true")
        fetchReq.predicate = pred
        
        do {
            let aantal = try managedObjectContext.fetch(fetchReq).count
            return aantal
        } catch {
            return 0
        }
    }
    
    // MARK: -
    private func setupMessageLabel() {
        messageLabel.text = "Je aankooplijst is leeg."
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try CoreDataStack.shared.persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
}

extension ShoppingListViewController: NSFetchedResultsControllerDelegate {
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        cell.selectionStyle = .none
        // Fetch Medicijn
        let medicijn = fetchedResultsController.object(at: indexPath)
        // Configure Cell
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1

        cell.mpnm.text = medicijn.mpnm
        cell.mppnm.text = medicijn.mppnm
        cell.vosnm.text = medicijn.vosnm
        cell.nirnm.text = medicijn.nirnm
        
        cell.pupr.text = "Prijs: \((medicijn.pupr?.floatValue)!) €"
        cell.rema.text = "remA: \((medicijn.rema?.floatValue)!) €"
        cell.remw.text = "remW: \((medicijn.remw?.floatValue)!) €"
        cell.cheapest.text = "gdkp: \(medicijn.cheapest.description)"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteFromAankoopLijst = UITableViewRowAction(style: .normal, title: "Verwijderen uit Aankooplijst") { (action, indexPath) in
            print("naar medicijnkast")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.setValue(false, forKey: "aankoop")
            medicijn.setValue(true, forKey: "aankooparchief")
            let context = self.coreData.persistentContainer.viewContext
            
            do {
                try context.save()
                print("medicijn verwijderd uit de lijst!")
            } catch {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
            self.updateView()
        }
        deleteFromAankoopLijst.backgroundColor = UIColor.red
        
        let addToMedicijnkast = UITableViewRowAction(style: .normal, title: "Naar medicijnkast") { (action, indexPath) in
            print("Uit lijst verwijderd")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.setValue(true, forKey: "kast")
            
            let context = self.coreData.persistentContainer.viewContext
            do {
                try context.save()
                print("med saved in medicijnkast")
            } catch {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
        }
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:0.5)
        self.tableView.setEditing(false, animated: true)
        return [deleteFromAankoopLijst, addToMedicijnkast]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    // Rekenen
    
    func fetchCheapest(categorie: String) -> Dictionary<String, Dictionary<String,Float>> {
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        guard let medicijnen = self.fetchedResultsController.fetchedObjects else { return ["vosnaam":["mpnm":0.0]] as Dictionary<String, Dictionary<String,Float>> }
        var vosarray:Array<String> = []
        for med in medicijnen {
            // vosnaam opvragen
            vosarray.append(med.vosnm!)
        }
        
        // alle medicijnen opvragen
        // voor elke stofnaam het goedkoopste alternatief zoeken (cheapest true of zelf berekenen?)
        var resultaat:Array<Medicijn> = []
        var vosdict: Dictionary<String,Dictionary<String,Float>> = [:]
        
        for vos in vosarray {
            let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
            let predicate = NSPredicate(format: "vosnm == %@", vos)
            fetchReq.predicate = predicate
            do {
                resultaat = try CoreDataStack.shared.persistentContainer.viewContext.fetch(fetchReq)
            } catch {
                print("fetching error in calculateCheapestPrice")
            }
            
            // Steek merknaam en prijscategorie (pupr, rema of remw) in dictionary
            var prijsdict:Dictionary<Float, String> = [:]
            for med in resultaat {
                if categorie == "pupr" {
                    prijsdict[med.pupr!.floatValue!] = med.mppcv!
                }
                if categorie == "rema" {
                    prijsdict[med.rema!.floatValue!] = med.mppcv!
                }
                if categorie == "remw" {
                    prijsdict[med.remw!.floatValue!] = med.mppcv!
                }
            }
            // Pik er het medicijn met de laagste prijs uit
            let minprijs = prijsdict.keys.min()
            let minprijsMppcv = prijsdict[minprijs!]
            
            vosdict[vos] = [minprijsMppcv!:minprijs!]
        }
        return vosdict
    }
    
    func berekenGoedkoopsteAlternatief(vosdict: Dictionary<String, Dictionary<String,Float>>, categorie: String) -> Float {
        // Bereken totaal
        var totaalprijs:Float = 0.0
        for (_, value) in vosdict {  /* key = vosnm, value = dict(merknaam, prijs) */
            for (_, v) in value {
                totaalprijs += v
            }
        }
        return totaalprijs
    }
    
    func alternatieven(vosdict: Dictionary<String, Dictionary<String,Float>>, categorie: String) -> Dictionary<String,String> {
        // Bereken totaal
        var lijstalternatieven:Dictionary<String,String> = [:]
        
        for (key, value) in vosdict {  /* key = vosnm, value = dict(mppcv, prijs) */
            var mppcv:String = ""
            for (k, _) in value {
                mppcv = k
                lijstalternatieven[key] = mppcv
            }
        }
        return lijstalternatieven
    }
    func berekenVerschil(categorie: String, huidig:Dictionary<String,Float>, altern: Float) -> Float {
        let prijsverschil = huidig[categorie]! - altern
        
        return prijsverschil
    }
}

