//
//  KastViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class KastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromKastToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let localdata = UserDefaults.standard
	
	// MARK: - Properties Variables
    var infoView = UIView()
    var menuView = UIView()
    var upArrow = UIView()
    var zoekwoord: String? = nil
    var sortDescriptorIndex:Int?=nil
    var selectedScope:Int = -1
    var selectedSegmentIndex:Int = 0
    var searchActive:Bool = false
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    var myPeopleList = [Person]()
    // Progress bar (update)
    var progressie:Float = 0.0
    var totalLines:Float = 0.0
    var readLines:Float = 0.0
    
    // MARK: - Referencing Outlets
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var totaalAantal: UILabel!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    
    // MARK: - Referencing Actions
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
        //print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.menuView.center.x >= 0 {
                self.menuView.center.x -= self.view.bounds.width
            }
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                //self.view.bringSubview(toFront: self.infoView)
            }
        }, completion: nil
        )
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
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
        
        //print("View will appear, fetching...")
        //tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
        
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
        //print("KastView did load!")
        setupLayout()
        setUpSearchBar()
        setupView()
        
        navigationItem.title = "Medicijnkast"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        //tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
        // monthly update of data!
        
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
        setupInfoView()
        setupUpArrow()
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
        //print("view Did Layout subviews")
        tableView.reloadData()
        //self.updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //print("View did appear")
        //tableView.reloadData()
        //self.updateView()
        /* update if new bcfi files */
    }
    
    
    
    // MARK: - Setup views
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
    }

    private func setupView() {
        setupMessageLabel()
    }
    
    // MARK: - Up Arrow
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
		//print("view did end decelerating")
		//print("offset: \(scrollView.contentOffset)")
		if (scrollView.contentOffset.y == 0.0) {  // TOP
			upArrow.isHidden = true
		} else {
			upArrow.isHidden = false
		}
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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mppnm", ascending: true)]
        //let predicate = NSPredicate(format: "cheapest contains %@", NSNumber(booleanLiteral: true))
        let predicate = NSPredicate(format: "userdata.medicijnkast == true")
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
        
        searchBar.isHidden = false
        searchBar.showsScopeBar = false
		searchBar.tintColor = UIColor.gray
        searchBar.scopeButtonTitles = ["merknaam", "verpakking", "stofnaam", "firmanaam", "alles"]
        searchBar.selectedScopeButtonIndex = -1
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
    }
    /*
    // MARK: - Unwind
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let _ = storyBoard.instantiateViewController(withIdentifier: "AddMedicijn") as! AddMedicijnViewController
        
        //self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    */
    // MARK: - Set Scope
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        /* FILTER SCOPE */
        
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
            //print("scope: vosnaam")
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
            zoekwoord = searchBar.text!
        case 3:
            //print("scope: firmanaam")
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.ir.nirnm"
            zoekwoord = searchBar.text!
        case 4:
            //print("scope: alles")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
        default:
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
        }

        //print("scope changed: \(selectedScope)")
        //print("filterKeyword: \(filterKeyword)")
        //print("searchbar text: \(searchBar.text!)")
        zoekwoord = searchBar.text!
        self.filterContentForSearchText(searchText: searchBar.text!, scopeIndex: selectedScope)
    }
    
    // MARK: - Set search operator
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
        
        //print("Segment changed: \(segmentedButton.selectedSegmentIndex)")
        // Focus searchBar (om onmiddellijk typen mogelijk te maken)
        searchBar.updateFocusIfNeeded()
        searchBar.becomeFirstResponder()
        searchActive = true
        if self.zoekwoord != nil {
            self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        }
        // Tell the searchBar that the searchBarSearchButton was clicked
        self.tableView.reloadData()
        updateView()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //print("Search should begin editing")
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true
        zoekwoord = ""
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print("text did change")
        zoekwoord = searchText
        searchActive = true
        //print("Zoekterm: \(searchBar.text ?? "zoekterm")")
        
        self.filterContentForSearchText(searchText: searchText, scopeIndex: self.selectedScope)
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar) {
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterKeyword = "mp.mpnm"
        sortKeyword = "mp.mpnm"
        //print("Cancel clicked")
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        zoekwoord = searchBar.text!
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: -1)
        //tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
        self.tableView.reloadData()
        updateView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        //print("should end editing")
        self.tableView.reloadData()
        return true
    }

    // MARK: - Zoekfilter
    func filterContentForSearchText(searchText: String, scopeIndex: Int) {
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate?
        if scopeIndex == 4 || scopeIndex == -1 {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.medicijnkast == true")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
                let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText)
                let sub3 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2, sub3])
                let predicate2 = NSPredicate(format: "userdata.medicijnkast == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
                
            }
        } else {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.medicijnkast == true")
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            } else {
                let predicate1 = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                let predicate2 = NSPredicate(format: "userdata.medicijnkast == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        }
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try self.fetchedResultsController.performFetch()
            //print("fetching...")
        } catch {
            let fetchError = error as NSError
            fatalError("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
        //print("filterKeyword: \(filterKeyword)")
        //print("sortkeyword \(sortKeyword)")
        //print("searchText: \(searchText)")
        self.updateView()
    }

    // MARK: - Navigation
    let CellDetailIdentifier = "SegueFromKastToDetail"
    let CellDetailToSearch = "SegueFromDetailToSearch"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
            
            //navigationController?.pushViewController(destination, animated: true)
        default:
//            print("Unknown segue: \(String(describing: segue.identifier))")
			break
        }
        
    }
    
    // MARK: - View Methods
    fileprivate func updateView() {
        //print("Updating view...")
        var hasMedicijnen = false
        
        var x:Int

        if let medicijnen = fetchedResultsController.fetchedObjects {
            hasMedicijnen = medicijnen.count > 0
            //print("medicijnen aantal: \(medicijnen.count)")
            /*print("medicijnen: \(medicijnen.description)")*/
            x = medicijnen.count
            
            let totaalKast = countKast(managedObjectContext: self.appDelegate.persistentContainer.viewContext)
            if searchActive || hasMedicijnen {
                totaalAantal.text = "\(x)/\(totaalKast)"
                tableView.isHidden = false
                messageLabel.isHidden = true
                self.tableView.reloadData()
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                totaalAantal.text = "\(totaalKast)"
                navigationItem.rightBarButtonItem?.isEnabled = false

            }
            
        } else {
            tableView.isHidden = !hasMedicijnen
            messageLabel.isHidden = hasMedicijnen
            navigationItem.rightBarButtonItem?.isEnabled = false
            tableView.reloadData()
        }
    }
    
    private func countKast(managedObjectContext: NSManagedObjectContext) -> Int {
        let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
        let pred = NSPredicate(format: "userdata.medicijnkast == true")
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
        messageLabel.text = "Je medicijnkast is leeg.\nDruk op het vergrootglas om te zoeken\nin alle medicijnen."
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
    
    // MARK: - Obsolete: open text alert window
    func openTextAlert() {
        // Create Alert Controller
        let alert9 = UIAlertController(title: "Persoon toevoegen", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        // Create cancel action
        let cancel9 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert9.addAction(cancel9)
        
        // Create OK Action
        let ok9 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in print("OK")
            let textfield = alert9.textFields?[0]
            
            let newPerson = Person(name: (textfield?.text!)!)
            self.myPeopleList.append(newPerson)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.myPeopleList)
            UserDefaults.standard.set(encodedData, forKey: "people")
        }
        
        alert9.addAction(ok9)
        
        // Add text field
        alert9.addTextField { (textfield: UITextField) in
            textfield.placeholder = "Nieuwe persoon"
        }
        
        // Present Alert Controller
        self.present(alert9, animated:true, completion:nil)
    }


}
// MARK: - Extension
extension KastViewController: NSFetchedResultsControllerDelegate {
    
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
        case .update:
            tableView.reloadData()
            break;
        default:
            break
            //print("...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    // MARK: - table data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let medicijnen = fetchedResultsController.fetchedObjects else { return 0 }
        //print("aantal rijen in tabel: \(medicijnen.count)")
        tableView.layer.cornerRadius = 3
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1
        return medicijnen.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135.0
    }
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let _:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddMedicijn") as! AddMedicijnViewController
		return true
	}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
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
        /*
        if medicijn.cheapest == false {
            cell.cheapest.text = "gdkp: Nee"
        } else {
            cell.cheapest.text = "gdkp: Ja"
        }
        */
        cell.cheapest.text = "index: \(String(describing: (medicijn.index))) c€"

        return cell
    }
	
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // MARK: delete from medicijnkast
        let deleteFromMedicijnkast = UITableViewRowAction(style: .normal, title: "Verwijder uit\nmedicijnkast") { (action, indexPath) in
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkast", uservalue: false, managedObjectContext: context)
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkastarchief", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
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
        deleteFromMedicijnkast.backgroundColor = UIColor.red
        
        // MARK: add to shoppinglist
        let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar\naankooplijst") { (action, indexPath) in
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
                //print("med saved in aankooplijst")
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )

            self.tableView.reloadData()
        }
        addToShoppingList.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:0.5)
        self.tableView.setEditing(false, animated: true)
        return [deleteFromMedicijnkast, addToShoppingList]
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
            //print("data line exists")
            for userData in userdata {
                userData.setValue(uservalue, forKey: userkey)
                userData.setValue(mppcvValue, forKey: "mppcv")
                userData.setValue(Date(), forKey: "lastupdate")
            }
        }
    }
    
    
}

class Person: NSObject, NSCoding {
    let name: String
    //let img: UIImage
    init(name: String) {
        self.name = name
        //self.img = img
    }
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        //self.img = decoder.decodeObject(forKey: "img") as? UIImage ??
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        //coder.encode(img, forKey: "img")
    }
}
