//
//  ShoppingListViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 09/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData
import SwiftCharts

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromShopToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Properties Variables
    var infoView = UIView()
    var menuView = UIView()
    var upArrow = UIView()
    var totalePrijs:Dictionary<String,Float> = [:]
    //var altPrijs:Dictionary<String,Float> = [:]
    var gdkpaltpupr:Float = 0.0
    var gdkpaltrema:Float = 0.0
    var gdkpaltremw:Float = 0.0
    var gdkp:Dictionary<String,Dictionary<String,Float>> = [:] /* [vosnm: [mppnm, 8.70] */
    var gdkpprijs:Float = 0.0
    var gdkpnaam:Dictionary<String,String> = [:] /* [vosnm: mppnm */
    var verschil:Float = 0.0

    var sortDescriptorIndex: Int?=nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    
    var zoekwoord:String = ""
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    
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
    @IBOutlet weak var btnCloseMenuView: UIButton!
    
    // MARK: - Referencing Actions
    @IBAction func popButton(_ sender: UIButton) {
        //print("popButton pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.graphView.center.x >= 0 {
                self.graphView.center.x -= self.view.bounds.width
            }
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
            }
        }, completion: nil
        )
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.99)
        popButton.isHidden = true
        popButton.isEnabled = false
    }
    
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
        //print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.menuView.center.x >= 0 {
                self.menuView.center.x -= self.view.bounds.width
            }
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)
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
                //self.view.bringSubview(toFront: self.infoView)
                
            } else {
                self.infoView.center.y += self.view.bounds.height
                //self.view.bringSubview(toFront: self.view)
            }
            if self.graphView.center.x >= 0 {
                self.graphView.center.x -= self.view.bounds.width
            }
        }, completion: nil
        )
        popButton.isHidden = false
        popButton.isEnabled = true
    }
    
    @IBAction func showMenuView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.menuView.center.x >= 0 {
                self.menuView.center.x -= self.view.bounds.width
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
        //print("swipe action")
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
        //print("swipe action")
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
        graphView.backgroundColor = UIColor.black.withAlphaComponent(0.99)
        popButton.isHidden = true
    }
    
    @IBAction func showGraphView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            //print("graphView center x: \(self.graphView.center.x)")
            //print("bounds: \(self.view.bounds.width)")
            if self.graphView.center.x >= 0 {
                //print(">0: \(self.graphView.center.x)")
                self.graphView.center.x -= self.view.bounds.width
                self.popButton.isEnabled = false
            } else {
                //print("<0: \(self.graphView.center.x)")
                self.graphView.center.x += self.view.bounds.width
                self.popButton.isEnabled = true
            }
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
            }
        }, completion: nil
        )
        
        graphView.backgroundColor = UIColor.black
        graphView.tintColor = UIColor.white
        popButton.isHidden = false
    }
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.appDelegate.saveContext()
        //print("Aankooplijst view will appear, fetching...")
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        rekenen()
        //print("berekenen...")
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        tableView.reloadData()
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Aankooplijst view did load!")
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
        tableView.reloadData()
        updateView()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        setupGraphView()
        setupMenuView()
        setupInfoView()
        tableView.reloadData()
        setupUpArrow()
        btnCloseMenuView.setTitle("", for: .normal)
        //self.updateView()
        //print("view Did Layout subviews")
    }
    
    // MARK: Setup views
    func setupMenuView() {
        self.menuView=UIView(frame:CGRect(x:0, y:0, width: 300, height: self.view.bounds.height))
        self.menuView.center.x -= view.bounds.width
        menuView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        menuView.layer.cornerRadius = 8
        menuView.layer.borderWidth = 1
        menuView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(menuView)
        self.btnCloseMenuView.isHidden = true
        self.btnCloseMenuView.isEnabled = false
    }
    
    func setupInfoView() {
        self.infoView.isHidden = true
        self.infoView=UIView(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 178))
        self.infoView.center.y -= view.bounds.height-104
        infoView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        infoView.layer.cornerRadius = 8
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(infoView)
        self.btnCloseMenuView.isHidden = true
        self.btnCloseMenuView.isEnabled = false
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
        labelvos.text = "Voorschriftnaam (VOS)"
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
        labelremadescription.font = UIFont.systemFont(ofSize: 13)
        let labelremw = UILabel()
        labelremw.text = "Remgeld W:"
        labelremw.textColor = UIColor.white
        let labelremwdescription = UILabel()
        labelremwdescription.text = "Bedrag voor patiënten met OMNIO/WIGW statuut."
        labelremwdescription.textColor = UIColor.white
        labelremwdescription.font = UIFont.systemFont(ofSize: 13)
        
        let leftStack = UIStackView(arrangedSubviews: [labelmp, labelmpp, labelvos, labelfirma, toepassingsgebied])
        leftStack.axis = .vertical
        leftStack.distribution = .fillEqually
        leftStack.alignment = .fill
        leftStack.spacing = 5
        leftStack.translatesAutoresizingMaskIntoConstraints = true
        let rightStack = UIStackView(arrangedSubviews: [labelpupr, labelrema, labelremadescription, labelremw, labelremwdescription])
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
        segmentedButton.setTitle("B....", forSegmentAt: 0)
        segmentedButton.setTitle("..c..", forSegmentAt: 1)
        segmentedButton.setTitle("....e", forSegmentAt: 2)
    }
    
    // MARK: - Setup graph view
    func setupGraphView() {
        //print("original x: \(self.graphView.center.x)")
        self.graphView.center.x -= view.bounds.width
        //print("new x: \(self.graphView.center.x)")
        graphView.layer.cornerRadius = 20
        graphView.layer.borderWidth = 1
        graphView.layer.borderColor = UIColor.black.cgColor
        showGraphButton.layer.cornerRadius = 8
        self.popButton.isEnabled = false
        self.popButton.isHidden = true
        // MARK: Bar Chart
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: 0, to: Double(totalePrijs["pupr"]!)+10, by: 1))
        let frame = CGRect(x: 125, y: 190, width: 300, height: 200)
        let chart = BarsChart(frame: frame, chartConfig: chartConfig, xTitle: "Categorie", yTitle: "Prijs €", bars: [("pubprijs", Double(totalePrijs["pupr"]!)), ("pubprijs alt", Double(gdkpaltpupr)), ("", 0), ("remA", Double(totalePrijs["rema"]!)), ("remA alt", Double(gdkpaltrema)), ("", 0),("remW", Double(totalePrijs["remw"]!)), ("remW alt", Double(gdkpaltremw))], color: UIColor.white, barWidth: 25)
        self.graphView.addSubview(chart.view)
        //self.chart = chart
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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mppnm", ascending: true)]
        let predicate = NSPredicate(format: "userdata.aankooplijst == true")
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
            text += "Product: \(med.mp!.mpnm!) \nVerpakking: \(med.mppnm!) \nVOS: \(med.vosnm_!) \nFirma: \(med.mp!.ir!.nirnm!) \nToepassing: \(toepassing) \nPrijs: \(med.pupr!) €\nRemgeld A: \(med.rema!) €\nRemgeld W: \(med.remw!) €\nIndex \(med.index!) c€\n"
            // draw dashed line
            text += "___________________________________________\n"
            
        }
        
        // set up activity view controller
        let textToShare = [ text ]
        let vc = UIActivityViewController(activityItems: textToShare, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: false, completion: nil)
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        
        searchBar.showsScopeBar = false
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
        
        //print("Segment changed: \(segmentedButton.selectedSegmentIndex)")
        // Focus searchBar (om onmiddellijk typen mogelijk te maken)
        searchBar.updateFocusIfNeeded()
        searchBar.becomeFirstResponder()
        searchActive = true
        if self.zoekwoord != "" {
            self.filterContentForSearchText(searchText: self.zoekwoord, scopeIndex: self.selectedScope)
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
        //print("Zoekterm: \(String(describing: searchBar.text))")
        
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
        //print("Cancel clicked")
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
        //print("should end editing")
        self.tableView.reloadData()
        return true
    }
    
    // MARK: Zoekfilter
    func filterContentForSearchText(searchText: String, scopeIndex: Int) {
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate?
        if scopeIndex == 4 || scopeIndex == -1 {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.aankooplijst == true")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText, searchText])
                let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText)
                let sub3 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2, sub3])
                let predicate2 = NSPredicate(format: "userdata.aankooplijst == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
                
            }
        } else {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "userdata.aankooplijst == true")
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            } else {
                let predicate1 = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                let predicate2 = NSPredicate(format: "userdata.aankooplijst == true")
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
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.tableView.reloadData()
        //print("filterKeyword: \(filterKeyword)")
        //print("sortkeyword \(sortKeyword)")
        //print("searchText: \(searchText)")
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
            let gdkpmppcv = alternatieven(altdict: gdkp, categorie: "rema")
            let gdkpindex = fetchCheapestIndex()
            let gdkpmppcvindex = alternatievenIndex(altdictIndex: gdkpindex)
            let ObjectsRight:Array<String> = Array(Set(gdkpmppcv))
            let ObjectsRightIndex:Array<String> = Array(Set(gdkpmppcvindex))
            let ObjectsLeft:Array<String> = uniekInAankooplijst()
            destination.receivedData = [ObjectsLeft, ObjectsRight, ObjectsRightIndex] /*Add ObjectsRightIndex*/
        default:
            print("Unknown segue: \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Calculator
    // MARK: Totale prijs berekenen
    private func TotalePrijs(managedObjectContext: NSManagedObjectContext) -> Dictionary<String,Float> {
        let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
        let pred = NSPredicate(format: "userdata.aankooplijst == true")
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
    
    // MARK: Alt prijs berekenen (Verpakking)
    private func rekenen() {
        totalePrijs = TotalePrijs(managedObjectContext: self.appDelegate.persistentContainer.viewContext)
        totalePupr.text = "\((totalePrijs["pupr"])!) €"
        totaalRemA.text = "\((totalePrijs["rema"])!) €"
        totaalRemW.text = "\((totalePrijs["remw"])!) €"
        
        let cheappupr = fetchCheapest(categorie: "pupr")
        let cheaprema = fetchCheapest(categorie: "rema")
        let cheapremw = fetchCheapest(categorie: "remw")
        gdkpaltpupr = berekenGoedkoopsteAlternatief(altdict: cheappupr, categorie: "pupr")
        gdkpaltrema = berekenGoedkoopsteAlternatief(altdict: cheaprema, categorie: "rema")
        gdkpaltremw = berekenGoedkoopsteAlternatief(altdict: cheapremw, categorie: "remw")
        altPupr.text = "\(gdkpaltpupr) €"
        altRema.text = "\(gdkpaltrema) €"
        altRemw.text = "\(gdkpaltremw) €"
        
        verschilPupr.text = "\(berekenVerschil(categorie: "pupr", huidig: totalePrijs, altern: gdkpaltpupr)) €"
        verschilRema.text = "\(berekenVerschil(categorie: "rema", huidig: totalePrijs, altern: gdkpaltrema)) €"
        verschilRemw.text = "\(berekenVerschil(categorie: "remw", huidig: totalePrijs, altern: gdkpaltremw)) € "
    }
    // MARK: Tel aantal med in aankooplijst
    private func countAankoop(managedObjectContext: NSManagedObjectContext) -> Int {
        let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
        let pred = NSPredicate(format: "userdata.aankooplijst == true")
        fetchReq.predicate = pred
        
        do {
            let aantal = try managedObjectContext.fetch(fetchReq).count
            return aantal
        } catch {
            return 0
        }
    }
    
    // MARK: - update view
    fileprivate func updateView() {
        //print("Updating view...")
        var hasMedicijnen = false
        
        var x:Int
        
        if let medicijnen = fetchedResultsController.fetchedObjects {
            hasMedicijnen = medicijnen.count > 0
            //print("medicijnen aantal: \(medicijnen.count)")
            
            x = medicijnen.count
            
            let totaalAankoop = countAankoop(managedObjectContext: self.appDelegate.persistentContainer.viewContext)
            if searchActive || hasMedicijnen {
                totaalAantal.text = "\(x)/\(totaalAankoop)"
                tableView.isHidden = false
                messageLabel.isHidden = true
                navigationItem.rightBarButtonItem?.isEnabled = true
                self.tableView.reloadData()
            } else {
                totaalAantal.text = "\(totaalAankoop)"
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
        } else {
            tableView.isHidden = !hasMedicijnen
            messageLabel.isHidden = hasMedicijnen
            navigationItem.rightBarButtonItem?.isEnabled = false
            tableView.reloadData()
        }
    }
    
    // MARK: - setup message label
    private func setupMessageLabel() {
        messageLabel.text = "Je aankooplijst is leeg."
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
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
            print("...ShoppingList didChange anObject")
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
    
    // MARK: - table data
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
        /*
        if medicijn.cheapest == false {
            cell.cheapest.text = "gdkp: Nee"
        } else {
            cell.cheapest.text = "gdkp: Ja"
        }
        */
        cell.cheapest.text = "index: \((medicijn.index?.floatValue)!) c€"

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteFromAankoopLijst = UITableViewRowAction(style: .normal, title: "Verwijder uit\naankooplijst") { (action, indexPath) in
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.userdata?.setValue(false, forKey: "aankooplijst")
            medicijn.userdata?.setValue(true, forKey: "aankooparchief")
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooplijst", uservalue: false, managedObjectContext: context)
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooparchief", uservalue: true, managedObjectContext: context)
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
        deleteFromAankoopLijst.backgroundColor = UIColor.red
        
        let addToMedicijnkast = UITableViewRowAction(style: .normal, title: "Naar\nmedicijnkast") { (action, indexPath) in
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkast", uservalue: true, managedObjectContext: context)
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
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:0.5)
        self.tableView.setEditing(false, animated: true)
        return [deleteFromAankoopLijst, addToMedicijnkast]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    // MARK: - Rekenen
    // MARK: VOS dictionary
    func vosdict() -> Dictionary<String,String> {
        // fetch alle medicijnen in aankooplijst (userdata.aankooplijst == true)
        // vosarray = [aankooplijst mppcv : aankooplijst vosnm_]
        guard let medicijnen = self.fetchedResultsController.fetchedObjects else { return ["":""] as Dictionary<String,String> }
        var versusdict:Dictionary<String,String> = [:]
        for med in medicijnen {
            // vosnaam opvragen
            versusdict[med.mppcv!] = med.vosnm_!
        }
        //print("versusdict: \(versusdict)")
        return versusdict
    }
    // MARK: Fetch Cheapest
    func fetchCheapest(categorie: String) -> Dictionary<String,Array<Any>> {
        // ["aankoop mppcv 3073251": ["alternatief mppcv 3073251", "paracetamol oraal 1g", "1.25"]]
        let versusdict = vosdict()
        // alle medicijnen opvragen
        // voor elke stofnaam het goedkoopste alternatief zoeken (cheapest true (nee) of zelf berekenen (ja)?)
        var resultaat:Array<MPP> = []
        var altdict: Dictionary<String,Array<Any>> = [:]
        
        for (key, value) in versusdict {
            let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
            let predicate = NSPredicate(format: "vosnm_ == %@", value)
            fetchReq.predicate = predicate
            do {
                resultaat = try self.appDelegate.persistentContainer.viewContext.fetch(fetchReq)
            } catch {
                print("fetching error in calculateCheapestPrice")
            }
            //print("resultaat: \(resultaat.count)")
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
            altdict[key] = [minprijsMppcv!, value, minprijs!]
            //vosdict[vos] = [minprijsMppcv!:minprijs!]
        }
        //print("altdict: \(altdict)")
        return altdict
    }
    
    // MARK: Fetch Cheapest Index prijs
    func fetchCheapestIndex() -> Dictionary<String,Array<Any>> {
        // ["aankoop mppcv 3073251": ["alternatief mppcv 3073251", "paracetamol oraal 1g", "1.25"]]
        let versusdict = vosdict()
        // alle medicijnen opvragen
        // voor elke stofnaam het goedkoopste alternatief zoeken (index prijs)
        var resultaat:Array<MPP> = []
        var altdict: Dictionary<String,Array<Any>> = [:]
        
        for (key, value) in versusdict {
            let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
            let predicate = NSPredicate(format: "vosnm_ == %@", value)
            fetchReq.predicate = predicate
            do {
                resultaat = try self.appDelegate.persistentContainer.viewContext.fetch(fetchReq)
            } catch {
                print("fetching error in calculateCheapestPrice")
            }
            //print("resultaat: \(resultaat.count)")
            // Steek index prijs in dictionary
            var prijsdict:Dictionary<Float, String> = [:]
            for med in resultaat {
                prijsdict[med.index!.floatValue!] = med.mppcv!
            }
            // Pik er het medicijn met de laagste prijs uit
            let minprijs = prijsdict.keys.min()
            let minprijsMppcv = prijsdict[minprijs!]
            altdict[key] = [minprijsMppcv!, value, minprijs!]
            //print("altdict index: \(altdict)")
            //vosdict[vos] = [minprijsMppcv!:minprijs!]
        }
        //print("altdict: \(altdict)")
        return altdict
    }
    
    // MARK: Bereken goedkoopste alternatief (tot prijs)
    func berekenGoedkoopsteAlternatief(altdict: Dictionary<String,Array<Any>>, categorie: String) -> Float {
        // Voor elke vosnm in vosarray, goedkoopste alternatief optellen
        // Bereken totaal
        var totaalprijs:Float = 0.0
        for (_, value) in altdict {
            let v = value[2]  /* key = vosnm, value = dict(merknaam, prijs) */
            totaalprijs += Float(v as! Float)
        }
        return totaalprijs
    }
    
    // MARK: uniek in aankooplijst
    func uniekInAankooplijst() -> Array<String> {
        // fetch alle medicijnen in aankooplijst (userdata.aankooplijst == true)
        // vosarray = [aankooplijst mppcv : aankooplijst vosnm_]
        guard let medicijnen = self.fetchedResultsController.fetchedObjects else { return [""] as Array<String> }
        var versusdict:Dictionary<String,String> = [:]
        for med in medicijnen {
            // vosnaam opvragen
            versusdict[med.vosnm_!] = med.mppcv!
        }
        var uniek: Array<String> = []
        for (_, value) in versusdict {
            uniek.append(value)
        }
        //print("unieke vos: \(uniek)")
        return uniek
    }
    
    // MARK: Array alternatieven
    func alternatieven(altdict: Dictionary<String,Array<Any>>, categorie: String) -> Array<String> {
        // Lijst = [Aankooplijst mppcv: Alternatief mppcv]
        // Bereken totaal
        var lijstalternatieven:Array<String> = []
        
        for (_, value) in altdict {  /* key = aankooplijst mppcv, value = array */
            var mppcv:String = ""
            /* key = vosnm, value = dict(mppcv, prijs) */
            mppcv = String(describing: value[0])
            lijstalternatieven.append(mppcv)
        }
        //print("lijstalternatieven: \(lijstalternatieven)")
        return Array(Set(lijstalternatieven))
    }
    
    // MARK: Array alternatieven index prijs
    func alternatievenIndex(altdictIndex: Dictionary<String,Array<Any>>) -> Array<String> {
        // Lijst = [Aankooplijst mppcv: Alternatief mppcv]
        // Bereken totaal
        var lijstalternatievenIndex:Array<String> = []
        
        for (_, value) in altdictIndex {  /* key = aankooplijst mppcv, value = array */
            var mppcv:String = ""
            /* key = vosnm, value = dict(mppcv, prijs) */
            mppcv = String(describing: value[0])
            lijstalternatievenIndex.append(mppcv)
        }
        //print("lijstalternatieven: \(lijstalternatieven)")
        return Array(Set(lijstalternatievenIndex))
    }

    // MARK: Bereken verschil
    func berekenVerschil(categorie: String, huidig:Dictionary<String,Float>, altern: Float) -> Float {
        let prijsverschil = huidig[categorie]! - altern
        return prijsverschil
    }
    
    // MARK: - create and fetch records
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

