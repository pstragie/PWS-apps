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
    
    // MARK: - Properties
        
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // MARK: -
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: -
    
    private let persistentContainer = NSPersistentContainer(name: "Medicijnkast")
    var sortDescriptorIndex: Int?=nil
    var selectedScopeIndex: Int?=nil
    var searchActive: Bool = false
    // MARK: -
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Medicijn> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let predicate = NSPredicate(format: "merknaam contains[c] %@ OR stofnaam contains[c] %@", self.searchBar.text!, self.searchBar.text!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "merknaam", ascending: true)]        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Addmedicijn View did load!")
        setUpSearchBar()
        //monthly update of data!
        //appDelegate.preloadData()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                self.setupView()
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - search bar related
    // MARK: - search bar related
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        
        searchBar.showsScopeBar = false
        searchBar.scopeButtonTitles = ["merknaam", "stofnaam", "all"]
        searchBar.selectedScopeButtonIndex = -1
        print("Scope: \(searchBar.selectedScopeButtonIndex)")
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
    }
    var filterKeyword = "merknaam"
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Scope changed")
        /* FILTER SCOPE */
        
        
        switch selectedScope {
        case 0:
            print("scope: merknaam")
            filterKeyword = "merknaam"
        case 1:
            print("scope: stofnaam")
            filterKeyword = "stofnaam"
        case 2:
            print("scope: alles")
            filterKeyword = "alles"
        default:
            filterKeyword = "merknaam"
        }
        
        print("filterKeyword: \(filterKeyword)")
        print("searchbar text: \(searchBar.text!)")
        if searchBar.text!.characters.count > 0 {
            let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
            print("predicate: \(predicate)")
            self.fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            print("no text in searchBar")
            //let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
            self.fetchedResultsController.fetchRequest.predicate = nil
        }
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
        var sortKeyword = "merknaam"
        switch sortDescriptorIndex {
        case 0?:
            sortKeyword = "firmanaam"
        case 1?:
            sortKeyword = "stofnaam"
        default:
            sortKeyword = "merknaam"
        }
        if self.searchBar.selectedScopeButtonIndex == 2 || searchBar.selectedScopeButtonIndex == -1 {
            if searchBar.text!.isEmpty == true {
                print("no text in searchBar")
                
                //let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
                self.fetchedResultsController.fetchRequest.predicate = nil
            } else {
                let predicate = NSCompoundPredicate(format: "merknaam contains[c] ‰@ || stofnaam contains[c] %@", searchText, searchText)
                self.fetchedResultsController.fetchRequest.predicate = predicate
            }
        } else {
            let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
            print("predicate: \(predicate)")
            self.fetchedResultsController.fetchRequest.predicate = predicate
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
        self.tableView.reloadData()
        updateView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("no text in searchBar")
        
        if searchBar.text!.isEmpty == false {
            let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", searchBar.text!)
            print("predicate: \(predicate)")
            self.fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            print("no text in searchBar")
            
            let predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", "Alotofmumbojumboblablabla")
            self.fetchedResultsController.fetchRequest.predicate = predicate
        }
        do {
            try self.fetchedResultsController.performFetch()
            print("fetching after should end editing...")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        print("Should end editing")
        self.tableView.reloadData()
        return true
    }

    // MARK: - Navigation



    // MARK: - View Methods
    private func setupView() {
        updateView()
    }
    
    fileprivate func updateView() {
        print("Updating view...")
            

        tableView.isHidden = false
        
        self.tableView.reloadData()
        activityIndicatorView.isHidden = true
        tableView.reloadData()
    }
    
    // MARK: - Notification Handling
    
    func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
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
        print("aantal rijen: \(medicijnen.count)")
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
        cell.Merknaam.text = medicijn.merknaam
        cell.Stofnaam.text = medicijn.stofnaam
        cell.Firmanaam.text = medicijn.firmanaam
        // TODO: Not working code!
        //let image = UIImage(data: medicijn.boximage as! Data)
        //cell.BoxImage.image = image
        cell.BoxImage.image = UIImage(named: "Pill-box-sample")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Fetch Medicijn
            let medicijn = fetchedResultsController.object(at: indexPath)
            
            // Delete Medicijn
            medicijn.managedObjectContext?.delete(medicijn)
        }
    }
    
}
