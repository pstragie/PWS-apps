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
	
	
    // MARK: - Properties   
    let segueShowDetail = "SegueShowDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
	let coreData = CoreDataStack()
    // MARK: -
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
	
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: -
	
    //public var persistentContainer = NSPersistentContainer(name: "Medicijnkast")
	var sortDescriptorIndex: Int?=nil
	//var selectedScopeIndex: Int?=nil
	var searchActive: Bool = false
	
	
    // MARK: -
    
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		self.appDelegate.saveContext()

		print("View will appear.")
		//tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
		
		do {
			print("fetching...")
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
	/*
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		print("View did appear")
		do {
			print("fetching...")
			try self.fetchedResultsController.performFetch()

		} catch {
			let fetchError = error as NSError
			print("Unable to Perform Fetch Request")
			print("\(fetchError), \(fetchError.localizedDescription)")
		}
		self.tableView.reloadData()
		self.updateView()
	}
	*/
    override func viewDidLoad() {
        super.viewDidLoad()
		print("View did load!")
		setUpSearchBar()
		setupView()
		
		
		//tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
		//monthly update of data!
		
		//appDelegate.cleanCoreDataMedicijn()
		// Execute next line on every new install!
		//appDelegate.preloadData("Medicijn")
		
		//Check for first launch and preload data if true
		//coreData.seedCoreDataContainerIfFirstLaunch()
		
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
		let vc = UIActivityViewController(activityItems: [navigationItem.rightBarButtonItem?.action as Any], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true)
	}
	
	// MARK: - search bar related
    fileprivate func setUpSearchBar() {
		let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
		searchBar.isHidden = false
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
				let subpredicate4 = NSPredicate(format: "nirnm contains[c] %@", searchBar.text!)
				let subpredicate5 = NSPredicate(format: "kast == true")
				let predicateOne = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate4])
				let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, subpredicate5])
				self.fetchedResultsController.fetchRequest.predicate = predicate
				sortKeyword = "mpnm"
			} else {
				let subpredicate1 = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
				let subpredicate2 = NSPredicate(format: "kast == true")
				let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate1, subpredicate2])
				self.fetchedResultsController.fetchRequest.predicate = predicate
				sortKeyword = "\(filterKeyword)"
			}
		} else {
			print("no text in searchBar")
			self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "kast == true")
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
		
		/*
		guard !searchText.isEmpty else {
			tableView.reloadData()
			return
		}
		*/
		
		searchActive = true
		// Configure Fetch Request
		/* SORT */
		var sortKeyword = "mpnm"
		
		if self.searchBar.selectedScopeButtonIndex == 3 || searchBar.selectedScopeButtonIndex == -1 {
			if searchBar.text!.isEmpty == true {
				print("scope -1 or 4 and no text in searchBar")
				sortKeyword = "mpnm"
				self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "kast == true")
			} else {
				let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchText)
				let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchText)
				let subpredicate4 = NSPredicate(format: "nirnm contains[c] %@", searchText)
				let subpredicate5 = NSPredicate(format: "kast == true")
				
				let predicateOne = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate4])
				let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, subpredicate5])
				self.fetchedResultsController.fetchRequest.predicate = predicate
				sortKeyword = filterKeyword
			}
			
		} else {
			if searchBar.text!.isEmpty == true {
				print("scope = 0, 1 or 2 and no text in searchBar")
				self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "kast == true")

			} else {
				if filterKeyword == "alles" {
					let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchText)
					let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchText)
					let subpredicate4 = NSPredicate(format: "nirnm contains[c] %@", searchText)
					let subpredicate5 = NSPredicate(format: "kast == true")
					let predicateOne = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate4])
					let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, subpredicate5])
					self.fetchedResultsController.fetchRequest.predicate = predicate
					
				} else {
					let subpredicate1 = NSPredicate(format: "mpnm contains[c] %@", searchText)
					let subpredicate2 = NSPredicate(format: "vosnm contains[c] %@", searchText)
					let subpredicate4 = NSPredicate(format: "nirnm contains[c] %@", searchText)
					let subpredicate5 = NSPredicate(format: "kast == true")
					let predicateOne = NSCompoundPredicate(orPredicateWithSubpredicates: [subpredicate1, subpredicate2, subpredicate4])
					let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, subpredicate5])
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
		searchBar.sizeToFit()
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.resignFirstResponder()
		//tableView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0)
		self.tableView.reloadData()
		updateView()
	}
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		print("should end editing")
		
		if searchBar.text!.isEmpty == false {
			let subpredicate1 = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
			let subpredicate2 = NSPredicate(format: "kast == true")
			let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate1, subpredicate2])
			print("predicate in should end: \(predicate)")
			self.fetchedResultsController.fetchRequest.predicate = predicate
		} else {
			print("should end and no text in searchBar")
			self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "kast == true")
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
	let CellDetailIdentifier = "SegueFromKastToDetail"
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier! {
		case CellDetailIdentifier:
			let destination = segue.destination as! MedicijnDetailViewController
			let indexPath = tableView.indexPathForSelectedRow!
			let selectedObject = fetchedResultsController.object(at: indexPath) 
			destination.medicijn = selectedObject
			
			navigationController?.pushViewController(destination, animated: true)
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
		
		if let medicijnen = fetchedResultsController.fetchedObjects {
			hasMedicijnen = medicijnen.count > 0
			print("medicijnen aantal: \(medicijnen.count)")
			
		}
		if searchActive {
		tableView.isHidden = false
		messageLabel.isHidden = true
		self.tableView.reloadData()
		tableView.reloadData()
		} else {
			tableView.isHidden = !hasMedicijnen
			messageLabel.isHidden = hasMedicijnen
			tableView.reloadData()

		}
		print("_____________________")
	}
	
    // MARK: -
	
    private func setupMessageLabel() {
        messageLabel.text = "Je medicijnkast is leeg."
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
		cell.Merknaam.text = medicijn.mpnm
		cell.Stofnaam.text = medicijn.vosnm
		cell.Prijs.text = medicijn.rema
		cell.Kast.text = medicijn.kast.description
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let deleteFromMedicijnkast = UITableViewRowAction(style: .normal, title: "Verwijder uit lijst") { (action, indexPath) in
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
		
		let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar Aankooplijst") { (action, indexPath) in
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
