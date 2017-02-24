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
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreData = CoreDataStack()
    var totalePrijs:Dictionary<String,Double> = [:]
    var gdkp:Dictionary<String,Dictionary<String,Double>> = [:] /* [vosnm: [mpnm, 8.70] */
    var gdkpprijs:Double = 0.0
    var gdkpnaam:Dictionary<String,String> = [:] /* [vosnm: mpnm */
    var verschil:Double = 0.0

    // MARK: -
    @IBOutlet weak var showGraphButton: UIButton!
    
    @IBOutlet var popButton: UIButton!
    @IBAction func popButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.graphView.center.x += 1000
        }, completion: nil
        )
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        popButton.isHidden = true
        popButton.isEnabled = false
    }
    @IBOutlet weak var totalePupr: UILabel!
    @IBOutlet weak var totaalRemA: UILabel!
    @IBOutlet weak var totaalRemW: UILabel!
    
    @IBOutlet weak var altPupr: UILabel!
    @IBOutlet weak var altRema: UILabel!
    @IBOutlet weak var altRemw: UILabel!
    
    @IBOutlet weak var verschilPupr: UILabel!
    @IBOutlet weak var verschilRema: UILabel!
    @IBOutlet weak var verschilRemw: UILabel!
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet weak var showAlternativeButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func showAlternativeButton(_ sender: UIButton) {
    }
    @IBAction func closeGraphView(_ sender: UIButton) {
        //view.willRemoveSubview(blurEffectView)
        UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
            self.graphView.center.x += self.view.bounds.width
        }, completion: nil
        )
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        popButton.isHidden = true
        popButton.isEnabled = false
    }
    @IBOutlet var graphView: UIView!
    
    @IBAction func showGraphView(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.graphView.center.x >= self.view.bounds.width {
                self.graphView.center.x -= self.view.bounds.width
            } else {
                self.graphView.center.x += self.view.bounds.width
            }
        }, completion: nil
        )
        
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        graphView.tintColor = UIColor.white
        popButton.isHidden = false
        popButton.isEnabled = true
        
    }
    
    @IBAction func geavanceerdZoeken(_ sender: UIButton) {
    }
    @IBOutlet weak var totaalAantal: UILabel!
    @IBAction func bestellingPlaatsen(_ sender: UIButton) {
    }
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: -
    
    var sortDescriptorIndex: Int?=nil
    var searchActive: Bool = false
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupGraphView()
        print("Aankooplijst view will appear")
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        print("bounds width : \(self.view.bounds.width)")
        rekenen()
        print("berekenen...")
        self.updateView()
    }
    override func viewDidLayoutSubviews() {
        setupGraphView()
        print("view Did Layout subviews")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Aankooplijst view did load!")
        showGraphButton.layer.cornerRadius = 8
        setUpSearchBar()
        navigationItem.title = "Aankooplijst"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        setupView()
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

    
    // MARK: -
    
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

    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    func setupGraphView() {
        print("bounds width : \(self.view.bounds.width)")
        print("current x: \(self.graphView.center.x)")
        self.graphView.center.x -= view.bounds.width
        print("new x: \(graphView.center.x)")
        graphView.layer.cornerRadius = 8
        graphView.layer.borderWidth = 1
        graphView.layer.borderColor = UIColor.black.cgColor
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
    
    // MARK: Set Scope
    var filterKeyword = "mpnm"
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Scope changed: \(selectedScope)")
        /* FILTER SCOPE */
        searchActive = true
        switch selectedScope {
        case 0:
            print("scope: merknaam")
            filterKeyword = "mpnm"
        case 1:
            print("scope: stofnaam")
            filterKeyword = "vosnm"
        case 2:
            print("scope: firmanaam")
            filterKeyword = "nirnm"
        case 3:
            print("scope: alles")
            filterKeyword = "alles"
        default:
            filterKeyword = "mpnm"
        }
        var sortKeyword = "mpnm"
        print("filterKeyword: \(filterKeyword)")
        print("searchbar text: \(searchBar.text!)")
        if searchBar.text!.isEmpty == false {
            if filterKeyword == "alles" {
                let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchBar.text!)
                let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchBar.text!)
                let subpredicate3 = NSPredicate(format: "nirnm contains[c] %@", searchBar.text!)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate3])
                let predicate2 = NSPredicate(format: "aankoop == true")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                self.fetchedResultsController.fetchRequest.predicate = predicate
                sortKeyword = "mpnm"
            } else {
                let predicate1 = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
                let predicate2 = NSPredicate(format: "aankoop == true")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                self.fetchedResultsController.fetchRequest.predicate = predicate
                sortKeyword = "\(filterKeyword)"
            }
        } else {
            print("no text in searchBar")
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "aankoop == true")
            if filterKeyword == "alles" {
                sortKeyword = "mpnm"
            } else {
                sortKeyword = filterKeyword
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
        updateView()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Search should begin editing")
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text did change")
        
        guard !searchText.isEmpty else {
            tableView.reloadData()
            return
        }
        
        searchActive = true
        // Configure Fetch Request
        /* SORT */
        var sortKeyword = ""
        
        if self.searchBar.selectedScopeButtonIndex == 3 || searchBar.selectedScopeButtonIndex == -1 {
            if searchBar.text!.isEmpty == true {
                print("scope -1 or 4 and no text in searchBar")
                sortKeyword = "mpnm"
            } else {
                let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchText)
                let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchText)
                let subpredicate3 = NSPredicate(format: "nirnm contains[c] %@", searchText)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate3])
                let predicate2 = NSPredicate(format: "aankoop == true")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                self.fetchedResultsController.fetchRequest.predicate = predicate
                sortKeyword = filterKeyword
            }
            
        } else {
            if searchBar.text!.isEmpty == true {
                print("scope = 0, 1 or 2 and no text in searchBar")
                self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "aankoop == true")
            } else {
                if filterKeyword == "alles" {
                    let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchText)
                    let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchText)
                    let subpredicate3 = NSPredicate(format: "nirnm contains[c] %@", searchText)
                    let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate3])
                    let predicate2 = NSPredicate(format: "aankoop == true")
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                    self.fetchedResultsController.fetchRequest.predicate = predicate
                    sortKeyword = "mpnm"
                } else {
                    let predicate1 = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchText)
                    let predicate2 = NSPredicate(format: "aankoop == true")
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                    print("predicate: \(predicate)")
                    self.fetchedResultsController.fetchRequest.predicate = predicate
                    sortKeyword = filterKeyword
                }
            }
        }
        print("filterKeyword: \(filterKeyword)")
        print("searchbar text: \(searchBar.text!)")
        
        
        let sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        print("\(sortKeyword)")
        
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
        updateView()
        print(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel clicked")
        searchBar.showsScopeBar = false
        searchActive = false
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
        updateView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("should end editing")
        
        if searchBar.text!.isEmpty == false {
            let predicate1 = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
            let predicate2 = NSPredicate(format: "aankoop == true")
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            print("predicate in should end: \(predicate)")
            self.fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            print("should end and no text in searchBar")
            self.fetchedResultsController.fetchRequest.predicate = nil
        }
        do {
            try self.fetchedResultsController.performFetch()
            print("fetching after should end editing...")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
        return true
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
    private func TotalePrijs(managedObjectContext: NSManagedObjectContext) -> Dictionary<String,Double> {
        let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let pred = NSPredicate(format: "aankoop == true")
        fetchReq.predicate = pred
        
        var totaleprijs:Dictionary<String,Double> = [:]
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        var totpupr: Double = 0.0
        var totrema: Double = 0.0
        var totremw: Double = 0.0
        do {
            let medicijnen = try managedObjectContext.fetch(fetchReq)
            for med in medicijnen {
                totpupr += (med.pupr?.doubleValue)!
                totrema += (med.rema?.doubleValue)!
                totremw += (med.remw?.doubleValue)!
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
        /*
        print("totale prijs: \(totalePrijs)")
        for c in ["pupr", "rema", "remw"] {
            gdkp = fetchCheapest(categorie: c)
            gdkpprijs = berekenGoedkoopsteAlternatief(vosdict: gdkp, categorie: c)
            gdkpnaam = alternatieven(vosdict: gdkp, categorie: c)
            verschil = berekenVerschil(categorie: c, huidig: totalePrijs, altern: gdkpprijs)
            print("totale prijs: \(totalePrijs)")
            print("categorie: \(c)")
            print("gdkp: \(gdkp)")
            print("gdkp prijs: \(gdkpprijs)")
            print("gdkp naam: \(gdkpnaam)")
            print("verschil: \(verschil)")
        }
        */
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
            if x != 0 && searchActive {
                totaalAantal.text = "\(x)/\(totaalAankoop)"
            } else {
                totaalAantal.text = "\(totaalAankoop)"
            }
            
        }
        if searchActive {
            tableView.isHidden = false
            messageLabel.isHidden = true
            
            activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
            activityIndicatorView.isHidden = true
        } else {
            tableView.isHidden = !hasMedicijnen
            messageLabel.isHidden = hasMedicijnen
            activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
            activityIndicatorView.isHidden = hasMedicijnen
            tableView.reloadData()
            
        }

    }
    
    private func countAankoop(managedObjectContext: NSManagedObjectContext) -> Int {
        let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let pred = NSPredicate(format: "aankoop == true")
        fetchReq.predicate = pred
        
        do {
            let aantal = try managedObjectContext.fetch(fetchReq).count
            print("\(type(of: aantal))")
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
        
        cell.pupr.text = "Prijs: \((medicijn.pupr)!) €"
        cell.rema.text = "remA: \((medicijn.rema)!) €"
        cell.remw.text = "remW: \((medicijn.remw)!) €"
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
    
    func fetchCheapest(categorie: String) -> Dictionary<String, Dictionary<String,Double>> {
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        guard let medicijnen = self.fetchedResultsController.fetchedObjects else { return ["vosnaam":["mpnm":0.0]] as Dictionary<String, Dictionary<String,Double>> }
        var vosarray:Array<String> = []
        for med in medicijnen {
            // vosnaam opvragen
            vosarray.append(med.vosnm!)
        }
        
        // alle medicijnen opvragen
        // voor elke stofnaam het goedkoopste alternatief zoeken (cheapest true of zelf berekenen?)
        var resultaat:Array<Medicijn> = []
        var vosdict: Dictionary<String,Dictionary<String,Double>> = [:]
        
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
            var prijsdict:Dictionary<Double, String> = [:]
            for med in resultaat {
                if categorie == "pupr" {
                    prijsdict[med.pupr!.doubleValue!] = med.mppcv!
                }
                if categorie == "rema" {
                    prijsdict[med.rema!.doubleValue!] = med.mppcv!
                }
                if categorie == "remw" {
                    prijsdict[med.remw!.doubleValue!] = med.mppcv!
                }
            }
            print("prijsdict: \(prijsdict)")
            // Pik er het medicijn met de laagste prijs uit
            let minprijs = prijsdict.keys.min()
            let minprijsMppcv = prijsdict[minprijs!]
            print("minprijs: \(minprijs!)")
            print("minprijsMppcv: \(minprijsMppcv!)")
            
            vosdict[vos] = [minprijsMppcv!:minprijs!]
        }
        return vosdict
    }
    
    func berekenGoedkoopsteAlternatief(vosdict: Dictionary<String, Dictionary<String,Double>>, categorie: String) -> Double {
        // Bereken totaal
        var totaalprijs:Double = 0.0
        for (_, value) in vosdict {  /* key = vosnm, value = dict(merknaam, prijs) */
            for (_, v) in value {
                totaalprijs += v
            }
        }
        return totaalprijs
    }
    
    func alternatieven(vosdict: Dictionary<String, Dictionary<String,Double>>, categorie: String) -> Dictionary<String,String> {
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
    func berekenVerschil(categorie: String, huidig:Dictionary<String,Double>, altern: Double) -> Double {
        let prijsverschil = huidig[categorie]! - altern
        
        return prijsverschil
    }
}

