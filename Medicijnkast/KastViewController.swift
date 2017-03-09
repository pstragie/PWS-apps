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
	let coreData = CoreDataStack()
	// MARK: - Properties Variables
	var sortDescriptorIndex:Int?=nil
	var selectedScope:Int = -1
	var selectedSegmentIndex:Int = 0
	var searchActive:Bool = false
	// MARK: - Progress Bar
	var progressie:Float = 0.0
	var totalLines:Float = 0.0
	var readLines:Float = 0.0
	// MARK: - filter and sort
	var zoekwoord:String = ""
	var filterKeyword:String = "mpnm"
	var zoekoperator:String = "BEGINSWITH"
	var format:String = "mpnm BEGINSWITH[c] %@"
	var sortKeyword:String = "mpnm"
	var myPeopleList = [Person]()
	// MARK: - Referencing Outlets
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
	@IBOutlet weak var progressView: UIView!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var totaalAantal: UILabel!
	@IBOutlet weak var segmentedButton: UISegmentedControl!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var menuView: UIView!
	@IBOutlet weak var btnCloseMenuView: UIButton!
	@IBOutlet weak var loadProgress: UILabel!
	
	// MARK: - Referencing Actions
	@IBAction func geavanceerdZoeken(_ sender: UIButton) {
	}
		
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

    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Medicijn> = {

		// Create Fetch Request
		let fetchRequest: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mpnm", ascending: true)]
		//let predicate = NSPredicate(format: "cheapest contains %@", NSNumber(booleanLiteral: true))
		let predicate = NSPredicate(format: "kast == true")
		fetchRequest.predicate = predicate
		print("Predicate = \(predicate)")
		// Create Fetched Results Controller
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

		return fetchedResultsController
	}()
	
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		print("KastView did load!")
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		self.appDelegate.saveContext()
		
		print("View will appear, fetching...")
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
	
	override func viewDidLayoutSubviews() {
		setupMenuView()
		progressView.isHidden = false
		btnCloseMenuView.isHidden = true
		btnCloseMenuView.isEnabled = false
		print("view Did Layout subviews")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		print("View did appear")
		if coreData.seedCoreDataContainerIfFirstLaunch() {
			progressView.isHidden = false
			progressBar.setProgress(0, animated: true)
			print("first installation!")
			//appDelegate.cleanCoreDataMedicijn()
			// Prepped with python to remove empty fields (replaced by "_")
			let Entities = ["MP", "MPP", "Sam", "Gal", "Hyr", "Stof", "Ggr_Link", "Ir"]
			// MP = OK
			// MPP = OK (prepped with python to remove end of lines in the middle, and some manual fixing!
			// Sam = OK
			// Gal = OK
			// Hyr = OK (prepped with python to remove end of lines in the middle, and some manual fixing!		
			// Stof = OK
			// Ggr_Link = OK
			// Ir = OK
			
			//let Entities = ["Hyr"]
			for entitynaam in Entities {
				progressBar.setProgress(0, animated: true)

				appDelegate.cleanCoreData(entitynaam: entitynaam)
				print(entitynaam)
				loadProgress.text = entitynaam
				progressView.isHidden = false
				progressBar.setProgress(0, animated: true)
				DispatchQueue.global().async {
					self.loadAllAttributes(entitynaam: entitynaam)
					print("did load progressie: \(self.progressie)")
					if self.progressie >= 0.95 {
						
					}
				}
			}
			self.progressView.isHidden = true
		} else {
			// Check for data updates
			print("Not the first installation!")
		}
		
	}
	
	func loadAllAttributes(entitynaam: String) {
		print("loading attributes...")
		let items = self.appDelegate.preloadData(entitynaam: entitynaam)
		self.totalLines = Float(items.count)
		for item in items {
			self.readLines += 1
			self.progressie = self.readLines/self.totalLines
			print("progressie in did appear: \(self.progressie)")
			//print("saveAttributes: \(entitynaam), /(dict)")
			self.saveAttributes(entitynaam: entitynaam, dict: item)
			DispatchQueue.main.sync() {
				self.updateProgressBar()
			}
		}
	}
	
	func updateProgressBar() {
		// To set a label with digital follow-up
		self.progressBar.progress = self.progressie
		let procentGeladen = Int(self.progressie*100)
		loadProgress.text = "\(procentGeladen) %"
		//print("progressBar: \(self.progressBar.progress)")
		// To set progressBar
		self.progressBar.setProgress(self.progressie, animated: true)
	}
	
	// MARK: - Save attributes
	func saveAttributes(entitynaam: String, dict: [String:String]) {
		//print("Saving attributes...")
		print("saving attributes...")
		let context = CoreDataStack.shared.persistentContainer.viewContext
		let entityMedicijn = NSEntityDescription.entity(forEntityName: entitynaam, in: context)
		let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		privateMOC.parent = context
		
		privateMOC.perform {
			let newMedicijn = NSManagedObject(entity: entityMedicijn!, insertInto: privateMOC)
			
			for (key, value) in dict {
				let key = key.replacingOccurrences(of: "\"", with: "")
				//print("key: \(key) and value: \(value)")
				if value == "true" {
					//print("value is true")
					newMedicijn.setValue(1, forKey: key)
				} else if value == "false" {
					//print("value is false")
					newMedicijn.setValue(0, forKey: key)
				} else if value == "" {
					//print("value is empty")
					newMedicijn.setValue("empty", forKey: key)
				}else {
					//print("value is not boolean")
					
					newMedicijn.setValue(value, forKey: key)
				}
			}
			
			newMedicijn.setValue(Date(), forKey: "lastupdate")
			do {
				try privateMOC.save()
				//print("context saved")
			} catch let error as NSError {
				print("Could not save \(error), \(error.userInfo)")
			}
		}
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
		
	}
	
	// MARK: - search bar related
    fileprivate func setUpSearchBar() {
		let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
		
		searchBar.isHidden = false
		searchBar.showsScopeBar = false
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
				let predicate = NSPredicate(format: "kast == true")
				self.fetchedResultsController.fetchRequest.predicate = predicate
				
			} else {
				format = ("mpnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@ || nirnm \(zoekoperator)[c] %@")
				let predicate1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
				let predicate2 = NSPredicate(format: "kast == true")
				let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
				self.fetchedResultsController.fetchRequest.predicate = predicate
			}
			
		} else {
			if searchText.isEmpty == true {
				print("scope = 0, 1 or 2 and no text in searchBar")
				let predicate = NSPredicate(format: "kast == true")
				self.fetchedResultsController.fetchRequest.predicate = predicate
			} else {
				if filterKeyword == "alles" {
					format = ("mpnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@ || vosnm \(zoekoperator)[c] %@")
					let predicate1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
					let predicate2 = NSPredicate(format: "kast == true")
					let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
					self.fetchedResultsController.fetchRequest.predicate = predicate
				} else {
					let predicate1 = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
					let predicate2 = NSPredicate(format: "kast == true")
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
	let CellDetailIdentifier = "SegueFromKastToDetail"
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier! {
		case CellDetailIdentifier:
			let destination = segue.destination as! MedicijnDetailViewController
			let indexPath = tableView.indexPathForSelectedRow!
			let selectedObject = fetchedResultsController.object(at: indexPath)
			destination.medicijn = selectedObject
			
			//navigationController?.pushViewController(destination, animated: true)
		default:
			print("Unknown segue: \(segue.identifier)")
		}
		
	}
	
    // MARK: - View Methods
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
			
			let totaalKast = countKast(managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext)
			if searchActive || hasMedicijnen {
				totaalAantal.text = "\(x)/\(totaalKast)"
				tableView.isHidden = false
				messageLabel.isHidden = true
				self.tableView.reloadData()
			} else {
				totaalAantal.text = "\(totaalKast)"
			}
			
		} else {
			tableView.isHidden = !hasMedicijnen
			messageLabel.isHidden = hasMedicijnen
			tableView.reloadData()
		}
	}
	
	private func countKast(managedObjectContext: NSManagedObjectContext) -> Int {
		let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
		let pred = NSPredicate(format: "kast == true")
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
        do {
            try coreData.persistentContainer.viewContext.save()
			self.tableView.reloadData()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
	
	

}

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
            print("...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
	
	// MARK: table data
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let medicijnen = fetchedResultsController.fetchedObjects else { return 0 }
		print("aantal rijen in tabel: \(medicijnen.count)")
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
		
		let deleteFromMedicijnkast = UITableViewRowAction(style: .normal, title: "Verwijder\nuit lijst") { (action, indexPath) in
			print("naar medicijnkast")
			// Fetch Medicijn
			let medicijn = self.fetchedResultsController.object(at: indexPath)
			medicijn.setValue(false, forKey: "kast")
			medicijn.setValue(true, forKey: "kastarchief")
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
		deleteFromMedicijnkast.backgroundColor = UIColor.red
		
		let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar\nAankooplijst") { (action, indexPath) in
			// Fetch Medicijn
			let medicijn = self.fetchedResultsController.object(at: indexPath)
			medicijn.setValue(true, forKey: "aankoop")
			let context = self.coreData.persistentContainer.viewContext
			do {
				try context.save()
				print("med saved in aankooplijst")
			} catch {
				print(error.localizedDescription)
			}
			self.tableView.reloadData()
		}
		addToShoppingList.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:0.5)
		self.tableView.setEditing(false, animated: true)
		return [deleteFromMedicijnkast, addToShoppingList]
	}

	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
