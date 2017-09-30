//
//  ArchiefViewController.swift
//  MedCabinetFree
//
//  Created by Pieter Stragier on 30/03/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class ArchiefViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromArchiefToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Properties Variables
    var infoView = UIView()
    var upArrow = UIView()
    
    var sortDescriptorIndex: Int?=nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    
    var zoekwoord:String = ""
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    lazy var archiefOperator:String = "medicijnkastarchief"
    
    // MARK: - Referencing Outlets
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var segmentedButton2: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    @IBOutlet weak var totaalAantal: UILabel!
    // MARK: - Referencing Actions
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
//        print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)
            }
        }, completion: nil
        )
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
    }
    
    @IBAction func info(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.btnCloseMenuView.isHidden = true
                self.btnCloseMenuView.isEnabled = false
                //self.view.bringSubview(toFront: self.infoView)
                
            } else {
                self.infoView.center.y += self.view.bounds.height
                self.btnCloseMenuView.isHidden = false
                self.btnCloseMenuView.isEnabled = true
                //self.view.bringSubview(toFront: self.view)
            }
        }, completion: nil
        )
        
    }
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.appDelegate.saveContext()
//        print("Archief view will appear, fetching...")
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        tableView.reloadData()
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Archief view did load!")
        setupLayout()
        setUpSearchBar()
        
        navigationItem.title = "Archief"
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bestellen, target: self, action: #selector(bestellingDoorsturen))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        tableView.reloadData()
        updateView()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.reloadData()
        setupUpArrow()
        setupInfoView()
        setupView()
        //self.updateView()
//        print("view Did Layout subviews")
    }
    
    // MARK: Detect device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil)
        { _ in
            /*
            self.setupInfoView()
            print("Device rotated")
            //self.view.sendSubview(toBack: self.infoView)
            self.infoView.center.y -= self.view.bounds.height-104
            */
        }
    }
    
    // MARK: Setup views
    func setupInfoView() {
        self.infoView.isHidden = true
        self.infoView=UIView(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 178))
        self.infoView.center.y -= view.bounds.height-104
        infoView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        infoView.layer.cornerRadius = 8
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(infoView)
        self.infoView.isHidden = false
        let labelmp = UILabel()
        labelmp.text = "Productnaam"
        labelmp.font = UIFont.boldSystemFont(ofSize: 22)
        labelmp.textColor = UIColor.white
        let labelmpp = UILabel()
        labelmpp.text = "Verpakking"
        labelmpp.font = UIFont.systemFont(ofSize: 17)
        labelmpp.textColor = UIColor.white
        let labelvos = UILabel()
        labelvos.text = "Voorschrift op stofnaam (VOS)"
        labelvos.font = UIFont.systemFont(ofSize: 13)
        labelvos.textColor = UIColor.white
        let labelfirma = UILabel()
        labelfirma.text = "Firmanaam (of distributeur)"
        labelfirma.font = UIFont.systemFont(ofSize: 17)
        labelfirma.textColor = UIColor.white
        let toepassingsgebied = UILabel()
        toepassingsgebied.text = "Toepassingsgebied"
        toepassingsgebied.font = UIFont.systemFont(ofSize: 17)
        toepassingsgebied.textColor = UIColor.white
        let labelpupr = UILabel()
        labelpupr.text = "Prijs voor het publiek"
        labelpupr.textColor = UIColor.white
        let labelrema = UILabel()
        labelrema.text = "Remgeld A:"
        labelrema.textColor = UIColor.white
        let labelremadescription = UILabel()
        labelremadescription.text = "Bedrag voor patiënten zonder OMNIO statuut."
        labelremadescription.textColor = UIColor.white
        labelremadescription.font = UIFont.systemFont(ofSize: 10)
        let labelremw = UILabel()
        labelremw.text = "Remgeld W:"
        labelremw.textColor = UIColor.white
        let labelremwdescription = UILabel()
        labelremwdescription.text = "Bedrag voor patiënten met OMNIO/WIGW statuut."
        labelremwdescription.textColor = UIColor.white
        labelremwdescription.font = UIFont.systemFont(ofSize: 10)
        let labelIndex = UILabel()
        labelIndex.text = "Prijs per unit in cent"
        labelIndex.textColor = UIColor.white
        labelIndex.font = UIFont.systemFont(ofSize: 13)
        let leftStack = UIStackView(arrangedSubviews: [labelmp, labelmpp, labelvos, labelfirma, toepassingsgebied])
        leftStack.axis = .vertical
        leftStack.distribution = .fillEqually
        leftStack.alignment = .fill
        leftStack.spacing = 5
        leftStack.translatesAutoresizingMaskIntoConstraints = true
        let rightStack = UIStackView(arrangedSubviews: [labelpupr, labelrema, labelremadescription, labelremw, labelremwdescription, labelIndex])
        rightStack.axis = .vertical
        rightStack.distribution = .fillEqually
        rightStack.alignment = .fill
        rightStack.spacing = 5
        rightStack.translatesAutoresizingMaskIntoConstraints = true
        let horstack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        horstack.axis = .horizontal
        horstack.distribution = .fillProportionally
        horstack.alignment = .fill
        horstack.spacing = 5
        horstack.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(horstack)
        //Stackview Layout
        let viewsDictionary = ["stackView": horstack]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-115-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stackView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        infoView.addConstraints(stackView_H)
        infoView.addConstraints(stackView_V)
    }
    
    func setupLayout() {
        segmentedButton.setTitle("•....", forSegmentAt: 0)
        segmentedButton.setTitle("..•..", forSegmentAt: 1)
        segmentedButton.setTitle("....•", forSegmentAt: 2)
        segmentedButton2.setTitle("Medicijnkast", forSegmentAt: 0)
        segmentedButton2.setTitle("Aankooplijst", forSegmentAt: 1)
    }
    
    func setupUpArrow() {
        self.upArrow=UIView(frame:CGRect(x: self.view.bounds.width-52, y: self.view.bounds.height-200, width: 50, height: 50))
        upArrow.isHidden = true
        upArrow.backgroundColor = UIColor.black.withAlphaComponent(0.50)
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
    
    private func setupView() {
        setupMessageLabel()
    }
    
    func scrollToTop() {
        //print("Scroll to top button clicked")
        let topOffset = CGPoint(x: 0, y: 0)
        tableView.setContentOffset(topOffset, animated: true)
    }
    
    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mp.mpnm", ascending: true)]
        let format = ("userdata.\(self.archiefOperator) == true")
        let predicate = NSPredicate(format: format)
        fetchRequest.predicate = predicate
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - share button
    func shareTapped() {
        // text to share
        var text = ""
        // fetch medicijnen op pagina
        let medicijnen = fetchedResultsController.fetchedObjects
        for med in medicijnen! {
            let toepassing = Dictionaries().hierarchy(hyr: (med.mp?.hyr?.hyr)!)
            text += "Product: \(med.mp!.mpnm!) \nVerpakking: \(med.mppnm!) \nVOS: \(med.vosnm_!) \nFirma: \(med.mp!.ir!.nirnm!) \nToepassing: \(toepassing) \nPrijs: \(med.pupr!) €\nRemgeld A: \(med.rema!) €\nRemgeld W: \(med.remw!) €\nIndex \(String(describing: med.index)) c€\n"
            // draw dashed line
            text += "___________________________________________\n"
            
        }
        
        // set up activity view controller
        let textToShare = [ text ]
        let vc = UIActivityViewController(activityItems: textToShare, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        vc.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.postToFlickr, UIActivityType.postToTencentWeibo ]
        present(vc, animated: false, completion: nil)
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        
        searchBar.showsScopeBar = false
        searchBar.tintColor = UIColor.gray
        searchBar.scopeButtonTitles = ["merknaam", "verpakking", "stofnaam", "firmanaam", "alles"]
        searchBar.selectedScopeButtonIndex = -1
        //print("Scope: \(searchBar.selectedScopeButtonIndex)")
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
    }
    
    // MARK: Set Scope
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        /* FILTER SCOPE */
        searchActive = true
        switch selectedScope {
        case 0:
            //print("scope: merknaam")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
        case 1:
            //print("scope: verpakking")
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
            zoekwoord = searchBar.text!
        case 2:
//            print("scope: vosnaam")
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
            zoekwoord = searchBar.text!
        case 3:
//            print("scope: firmanaam")
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.ir.nirnm"
            zoekwoord = searchBar.text!
        case 4:
//            print("scope: alles")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
        default:
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
        }
//        print("scope changed: \(selectedScope)")
//        print("filterKeyword: \(filterKeyword)")
//        print("searchbar text: \(searchBar.text!)")
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
            
        }
        // Focus searchBar (om onmiddellijk typen mogelijk te maken)
        searchBar.updateFocusIfNeeded()
        searchBar.becomeFirstResponder()
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
        self.tableView.reloadData()
        updateView()
    }
    
    // MARK: Set archief operator
    @IBAction func archiefChanged(_sender: UISegmentedControl) {
        switch segmentedButton2.selectedSegmentIndex {
        case 0:
//            print("0")
            archiefOperator = "medicijnkastarchief"
        case 1:
//            print("1")
            archiefOperator = "aankooparchief"
        default:
            archiefOperator = "medicijnkastarchief"
            
        }
        // Focus searchBar (om onmiddellijk typen mogelijk te maken)
        searchBar.updateFocusIfNeeded()
        searchBar.becomeFirstResponder()
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
        self.tableView.reloadData()
        self.updateView()
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        print("Search should begin editing")
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true
        zoekwoord = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("text did change")
        zoekwoord = searchText
        searchActive = true
//        print("Zoekterm: \(String(describing: searchBar.text))")
        
        self.filterContentForSearchText(searchText: searchText, scopeIndex: self.selectedScope)
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar) {
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterKeyword = "mp.mpnm"
        sortKeyword = "mp.mpnm"
//        print("Cancel clicked")
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
//        print("should end editing")
        self.tableView.reloadData()
        return true
    }
    
    // MARK: Zoekfilter
    func filterContentForSearchText(searchText: String, scopeIndex: Int) {
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate?
        if scopeIndex == 4 || scopeIndex == -1 {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.\(archiefOperator) == true")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
                let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText)
                let sub3 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2, sub3])
                let predicate2 = NSPredicate(format: "userdata.\(archiefOperator) == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]

            }
        } else {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.\(archiefOperator) == true")
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            } else {
                let predicate1 = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                let predicate2 = NSPredicate(format: "userdata.\(archiefOperator) == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        }
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try self.fetchedResultsController.performFetch()
//            print("fetching...")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
//        print("filterKeyword: \(filterKeyword)")
//        print("sortkeyword \(sortKeyword)")
//        print("searchText: \(searchText)")
        self.updateView()
    }
    
    // MARK: - Navigation
    let CellDetailIdentifier = "SegueFromArchiefToDetail"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
            
        default:
//            print("Unknown segue: \(String(describing: segue.identifier))")
            break
        }
    }
    
    // MARK: - View Methods
    fileprivate func updateView() {
//        print("Updating view...")
        var hasMedicijnen = false
        
        var x:Int
        
        if let medicijnen = fetchedResultsController.fetchedObjects {
            hasMedicijnen = medicijnen.count > 0
//            print("medicijnen aantal: \(medicijnen.count)")
            
            x = medicijnen.count
//            print("count: \(x)")
//            print("search active? \(searchActive)")
            let totaalAankoop = countAankoop(managedObjectContext: self.appDelegate.persistentContainer.viewContext)
            if searchActive || hasMedicijnen {
                totaalAantal.text = "\(x)/\(totaalAankoop)"
                tableView.isHidden = false
                messageLabel.isHidden = true
                self.tableView.reloadData()
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                totaalAantal.text = "\(totaalAankoop)"
                setupMessageLabel()
                messageLabel.isHidden = false
                tableView.isHidden = true
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
        } else {
            tableView.isHidden = !hasMedicijnen
            messageLabel.isHidden = hasMedicijnen
            navigationItem.rightBarButtonItem?.isEnabled = false
            self.tableView.reloadData()
        }
    }
    
    private func countAankoop(managedObjectContext: NSManagedObjectContext) -> Int {
        let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
        let pred = NSPredicate(format: "userdata.\(self.archiefOperator) == true")
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
        if archiefOperator == "medicijnkastarchief" {
            messageLabel.text = "Hier verschijnen alle medicijnen die ooit in je medicijnkast zaten."
        } else {
            messageLabel.text = "Hier verschijnen alle medicijnen die ooit in je aankooplijst zaten."
        }
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
    
}

extension ArchiefViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
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
            break
//            print("...ShoppingList didChange anObject")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    // MARK: - Scrolling behaviour
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.upArrow.isHidden = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0.0) {  // TOP
            upArrow.isHidden = true
        } else {
            upArrow.isHidden = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("view did end decelerating")
//        print("offset: \(scrollView.contentOffset)")
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
        return 135.0
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
        if (medicijn.use == "H") {
            cell.H_label.text = "H"
        } else {
            cell.H_label.text = ""
        }
        if (medicijn.law == "R") {
            cell.Rx_label.text = "Rx"
        } else {
            cell.Rx_label.text = ""
        }
        if (medicijn.mp?.wadan != "_") {
            cell.Wada_label.text = "W"
        } else {
            cell.Wada_label.text = ""
        }
        if (medicijn.cheapest == true) {
            cell.Cheap_label.text = "€"
        } else {
            cell.Cheap_label.text = ""
        }
        cell.mpnm.text = medicijn.mp?.mpnm
        cell.mppnm.text = medicijn.mppnm
        cell.vosnm.text = medicijn.vosnm_
        cell.nirnm.text = medicijn.mp?.ir?.nirnm
        let toepassing = Dictionaries().hierarchy(hyr: (medicijn.mp?.hyr?.hyr)!)
        cell.hyr.text = toepassing
        cell.pupr.text = "Prijs: \((medicijn.pupr?.floatValue)!) €"
        cell.rema.text = "remA: \((medicijn.rema?.floatValue)!) €"
        cell.remw.text = "remW: \((medicijn.remw?.floatValue)!) €"
        if medicijn.cheapest == false {
            cell.cheapest.text = "gdkp: Nee"
        } else {
            cell.cheapest.text = "gdkp: Ja"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteFromArchiefLijst = UITableViewRowAction(style: .normal, title: "Verwijderen\n uit archief") { (action, indexPath) in
//            print("naar medicijnkast")
            // Fetch Medicijn
//            print(self.archiefOperator)
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.userdata?.setValue(false, forKey: "\(self.archiefOperator)")
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "\(self.archiefOperator)", uservalue: false, managedObjectContext: context)
            do {
                try context.save()
//                print("medicijn verwijderd uit de lijst!")
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
            self.tableView.reloadData()
            self.updateView()
            
            
        }
        deleteFromArchiefLijst.backgroundColor = UIColor.red
        
        let addToMedicijnkast = UITableViewRowAction(style: .normal, title: "Naar\nmedicijnkast") { (action, indexPath) in
//            print("Uit lijst verwijderd")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkast", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
//                print("med saved in medicijnkast")
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )
            self.tableView.reloadData()
        }
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        
        let addToAankoopLijst = UITableViewRowAction(style: .normal, title: "Naar\naankooplijst") { (action, indexPath) in
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )
            self.tableView.reloadData()
        }
        addToAankoopLijst.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:1)
        self.tableView.setEditing(false, animated: true)
        return [deleteFromArchiefLijst, addToAankoopLijst, addToMedicijnkast]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
//            print("data line does not exist")
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
//            print("data line exists")
            for userData in userdata {
                userData.setValue(uservalue, forKey: userkey)
                userData.setValue(mppcvValue, forKey: "mppcv")
                userData.setValue(Date(), forKey: "lastupdate")
            }
        }
    }
}

