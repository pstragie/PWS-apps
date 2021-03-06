//
//  AddMedicijnViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

class AddMedicijnViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Properties Constants
    let segueShowDetail = "SegueFromAddToDetail"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let level0dict = Dictionaries().level0Picker()
    let level0Picker = UIPickerView()
    var level1dict = Dictionaries().level1Picker()
    let level1Picker = UIPickerView()
    let lekenPicker = UIPickerView()
    var lekendict = Dictionaries().lekenPicker()
    let CellDetailIdentifier = "SegueFromAddToDetail"
    let localdata = UserDefaults.standard
    let databaseV: String = "Database versie: 10/2017"
    
    // MARK: - Properties Variables
    var asc = true
    var hyrView: Bool = false
    var selectedHyr0: String = "D"
    var selectedHyr1: String = "DA"
    var toepzoekwoord: Any = "D"
    var infoView = UIView()
    var appVersionView = UIView()
    var versionView = UIView()
    var hyrPickerView = UIView()
    var pickerChanged: Bool = false
    var sortDescriptorIndex: Int? = nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    weak var receivedData: MPP?
    var receivedArray: Array<String> = []
    var zoekwoord: String? = nil
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var filterOperator:String = "medisch"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    var noHosp: Bool = true
    var H: Bool = true
    var S: Bool = true
    var unwindToep: Bool = false
    var unwindRow: Int = 0

    // MARK: Version and build
    var appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    var appBuild: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String)!

    // MARK: - Referencing Outlets
    @IBOutlet weak var noodnummers: UILabel!
    @IBOutlet weak var Hospitaal: UILabel!
    @IBOutlet weak var zoekenImage: UIImageView!
    @IBOutlet weak var hospSwitch: UISwitch!
    @IBOutlet weak var IndexSortButton: UIButton!
    @IBOutlet weak var AZSortButton: UIButton!
    @IBOutlet weak var TopButton: UIButton!
    @IBAction func IndexSortButton(_ sender: UIButton) {
        sortIndex()
    }
    @IBAction func AZSortButton(_ sender: UIButton) {
        sortIndexAZ()
    }
    @IBAction func TopButton(_ sender: UIButton) {
        scrollToTop()
    }
    @IBAction func hospSwitch(_ sender: UISwitch) {
        searchActive = true
        pickerChanged = true
        if hyrView == false {
            if zoekwoord != nil {
                self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: self.selectedScope)
            }
        } else {
            self.filterContentForSearchText(searchText: toepzoekwoord, scopeIndex: 4)
        }
        searchBar.becomeFirstResponder()
        self.tableView.reloadData()
    }
    
    @IBOutlet weak var gevondenItemsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var segmentedToepSearch: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    @IBAction func appVersion(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.appVersionView.isHidden == false { // View zichtbaar
                self.appVersionView.isHidden = true     // verberg view
                self.H = true
//                self.view.sendSubview(toBack: self.appVersionView)
                if self.infoView.center.y >= 0 {
                    self.btnCloseMenuView.isHidden = false
                    self.btnCloseMenuView.isEnabled = true
                } else {
                    self.btnCloseMenuView.isHidden = true
                    self.btnCloseMenuView.isEnabled = false
                }
            } else {                                    // View verborgen
//                self.view.bringSubview(toFront: self.appVersionView)
                self.appVersionView.isHidden = false    // toon view
                self.btnCloseMenuView.isHidden = false
                self.btnCloseMenuView.isEnabled = true
            }
        }, completion: nil
        )
    }
    
    // MARK: - Referencing Actions
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
        //print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)
            }
            if self.appVersionView.isHidden == false {
                self.appVersionView.isHidden = true
                self.H = true
            }
        }, completion: nil
        )
        btnCloseMenuView.isHidden = true
        btnCloseMenuView.isEnabled = false
    }
    
    @IBAction func info(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            //print("infoview: \(self.infoView.center.y)")
            if self.infoView.center.y >= 0 {
                if self.hyrView == true {
                    self.infoView.center.y -= self.view.bounds.height + 188 // Hide infoview
                } else {
                self.infoView.center.y -= self.view.bounds.height // Hide infoview
                }
                if self.appVersionView.isHidden == false {
                    self.btnCloseMenuView.isHidden = false
                    self.btnCloseMenuView.isEnabled = true
                } else {
                    self.btnCloseMenuView.isHidden = true
                    self.btnCloseMenuView.isEnabled = false
                }
            } else {
                if self.hyrView == true {
                    self.infoView.center.y += self.view.bounds.height + 188
                } else {
                self.infoView.center.y += self.view.bounds.height // Show infoview
                }
                self.btnCloseMenuView.isHidden = false
                self.btnCloseMenuView.isEnabled = true

            }
        }, completion: nil
        )
        
    }

    // MARK: - Unwind actions
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? MedicijnDetailViewController {
            receivedData = sourceViewController.dataPassed
            //print("received data: \(receivedData)")
            receivedArray = sourceViewController.arrayPassed
            //print("received string: \(receivedArray)")
        }
        scrollToTop()
        
        self.asc = true
        self.IndexSortButton.isHidden = true
        switch segue.identifier {
        case "vosnmToSearch"?:
            filterKeyword = "vosnm_"
            sortKeyword = "index"
            zoekwoord = (receivedData?.vosnm_)!
            self.selectedScope = 2
            self.asc = false
            hyrView = false
            //print("vosnm_: \(zoekwoord!)")
        case "stofnaam1"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[0]
            self.selectedScope = 2
            self.asc = false
            hyrView = false
            //print("stofnm1")
        case "stofnaam2"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[1]
            self.selectedScope = 2
            self.asc = false
            //print("stofnm2")
        case "stofnaam3"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[2]
            self.selectedScope = 2
            hyrView = false
            //print("stofnm3")
        case "stofnaam4"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[3]
            self.selectedScope = 2
            hyrView = false
            //print("stofnm4")
        case "stofnaam5"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[4]
            self.selectedScope = 2
            self.asc = false
            hyrView = false
            //print("stofnm5")
        case "irnmToSearch"?:
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = (receivedData?.mp?.ir?.nirnm)!
            self.selectedScope = 3
            hyrView = false
            //print("irnm")
        case "hyrToSearch"?:
            self.view.endEditing(true)
            hyrView = true

            pickerChanged = true
            segmentedToepSearch.isHidden = false
            filterOperator = "medisch"
            setupHyrPickerView()
            let hyr:String = (receivedData?.mp?.hyr?.hyr)!
            let firstCharacter = hyr[hyr.index(hyr.startIndex, offsetBy: 0)]
            var secondCharacter: Character?
            let start = hyr.index(hyr.startIndex, offsetBy: 0)
            let end = hyr.index(hyr.startIndex, offsetBy: 1)
            let range = start...end
            let firstTwoCharacters = hyr[range]
            var hyrstring:String?
            if hyr.characters.count == 1 {
                hyrstring = String(firstCharacter)
            } else if hyr.characters.count == 2 {
                secondCharacter = hyr[hyr.index(hyr.startIndex, offsetBy: 1)]
                hyrstring = String(firstTwoCharacters)
            } else {
//                print("More than two characters")
                secondCharacter = hyr[hyr.index(hyr.startIndex, offsetBy: 1)]
                hyrstring = String(firstTwoCharacters)
            }
            unwindToep = true
            filterKeyword = "mp.hyr.hyr"
            sortKeyword = "mp.mpnm"
            toepzoekwoord = hyrstring!
            zoekwoord = ""
            searchBar.text = ""
            self.selectedScope = 4
            self.segmentedToepSearch.selectedSegmentIndex = 0
            self.AZSortButton.isHidden = true
            IndexSortButton.isHidden = true
            var x: Int = 0
            let v = level0dict[String(firstCharacter)]
            x = sortData(level0dict).index(of: v!)!
            level0Picker.selectRow(x, inComponent: 0, animated: true)
            selectedHyr0 = String(firstCharacter)
            hyrView = true
            updatePicker1() // Fill second picker with options matching selected row in first picker
            let w = Dictionaries().level1Picker()[String(firstCharacter)+String(secondCharacter!)]
            //print("w: \(w!)")
            unwindRow = sortData(level1dict).index(of: w!)!
            level1Picker.reloadAllComponents()
//            updatePicker1() // Select correct row in picker
//            level1Picker.selectRow(unwindRow, inComponent: 0, animated: true)
            tableView.reloadData()
            print("unwind from hyr")
        default:
            filterKeyword = "mppnm"
        }
        //print("Unwind selectedScope: \(selectedScope)")
        self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: selectedScope)
    }
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
//        print("view will appear")
        setupPickerView()
        setUpSearchBar(selectedScope: selectedScope)
        if selectedScope == 1 || selectedScope == 2 {
            self.IndexSortButton.isHidden = false
        } else {
            self.IndexSortButton.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        print("View did disappear!")
        self.appDelegate.saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Addmedicijn View did load!")
        setupLayout()
        self.automaticallyAdjustsScrollViewInsets = false
        setUpSearchBar(selectedScope: -1)
//        setupIndexSort()
        setupTopButton()
        setupIndexSortButton()
        setupAZSortButton()
        updatePicker1()
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            fatalError("Could not fetch records: \(fetchError)")
//            print("Unable to Perform Fetch Request")
//            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        level0Picker.delegate = self
        level0Picker.dataSource = self
        level1Picker.delegate = self
        level1Picker.dataSource = self
        lekenPicker.delegate = self
        lekenPicker.dataSource = self
        
        setupHyrPickerView()
        
        self.updateView()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
//        MARK: Temp copy defaults to userdata
//        let context = self.appDelegate.persistentContainer.viewContext
//        copyUserDefaultsToUserData(managedObjectContext: context)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("viewDidLayoutSubviews")
        updateView()
        setupInfoView()
        setupPickerView()
        setupAppVersionView()
//        print("SelectedScope: \(selectedScope)")
//        setUpSearchBar(selectedScope: selectedScope)
//        print("Layout selectedHyr0 \(selectedHyr0)")
//        print("hyrView: \(hyrView)")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        print("view will transition")
        if self.appVersionView.isHidden == false {
            self.H = false
        } else {
            self.H = true
        }
                scrollToTop()
//        self.view.layoutSubviews()
//        self.view.setNeedsDisplay()
//        setupAppVersionView()
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
        // text to share
        var text = ""
        // fetch medicijnen op pagina
        let medicijnen = fetchedResultsController.fetchedObjects
        for med in medicijnen! {
            let toepassing = Dictionaries().hierarchy(hyr: (med.mp?.hyr?.hyr)!)
            if hyrView == true {
                text += "\(toepassing)\n___________________________________________\n"
            }
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
    
    // MARK: - Setup HyrPickerView
    func setupPickerView() { // Layout subviews
//        print("setup Picker view")
        if hyrView == true {
            updatePicker1() // Fill second picker with options matching row 0 in first picker
            level1Picker.reloadAllComponents()
            self.hyrPickerView.isHidden = false
            
            self.view.bringSubview(toFront: hyrPickerView)
            let topOffset = CGPoint(x: 0, y: -188)
            if self.tableView.contentOffset != topOffset {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
                    self.tableView.setContentOffset(topOffset, animated: false)
                })
            }
        } else {
            self.hyrPickerView.isHidden = true
            self.view.sendSubview(toBack: hyrPickerView)
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                let topOffset = CGPoint(x: 0, y: 0)
                self.tableView.setContentOffset(topOffset, animated: true)
            })
        }
    }
    
    func setupHyrPickerView() {
//        print("setup HyrPicker view")
        self.hyrPickerView.removeFromSuperview()
        self.hyrPickerView.isHidden = false
        self.hyrPickerView=UIView(frame:CGRect(x:10, y:104, width: self.view.bounds.width-20, height: 188))
        //self.hyrPickerView.center.y -= view.bounds.height
        hyrPickerView.backgroundColor = UIColor.white.withAlphaComponent(1)
        hyrPickerView.layer.cornerRadius = 8
        hyrPickerView.layer.borderWidth = 1
        hyrPickerView.layer.borderColor = UIColor.gray.cgColor
        hyrPickerView.autoresizingMask = .flexibleWidth
        
        self.view.addSubview(hyrPickerView)
        self.btnCloseMenuView.isHidden = true
        self.btnCloseMenuView.isEnabled = false
        var horstack = UIStackView()
        if filterOperator == "medisch" || segmentedToepSearch.selectedSegmentIndex == 0 {
            horstack = UIStackView(arrangedSubviews: [level0Picker, level1Picker])
        } else {
            horstack = UIStackView(arrangedSubviews: [lekenPicker])
        }
        horstack.axis = .horizontal
        horstack.distribution = .fillProportionally
        horstack.alignment = .fill
        horstack.autoresizingMask = .flexibleWidth
        horstack.spacing = 5
        horstack.translatesAutoresizingMaskIntoConstraints = false
        self.hyrPickerView.addSubview(horstack)
        // MARK: Stackview Layout
        
        let viewsDictionary = ["stackView": horstack]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stackView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        hyrPickerView.addConstraints(stackView_H)
        hyrPickerView.addConstraints(stackView_V)
 
        self.view.sendSubview(toBack: self.hyrPickerView)
    }
    
    // MARK: - Setup infoView
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
        
        // Not HyrView Info
        let RxL = UILabel()
        RxL.text = "Rx: Op voorschrift"
        RxL.font = UIFont.systemFont(ofSize: 10)
        RxL.textColor = UIColor.white
        let wadaL = UILabel()
        wadaL.text = "W: Doping"
        wadaL.font = UIFont.systemFont(ofSize: 10)
        wadaL.textColor = UIColor.white
        let goedkoopL = UILabel()
        goedkoopL.text = "€: Goedkoop"
        goedkoopL.font = UIFont.systemFont(ofSize: 10)
        goedkoopL.textColor = UIColor.white
        let hospitaalL = UILabel()
        hospitaalL.text = "H: Hospitaal"
        hospitaalL.font = UIFont.systemFont(ofSize: 10)
        hospitaalL.textColor = UIColor.white
        let firstStack = UIStackView(arrangedSubviews: [RxL, wadaL, goedkoopL, hospitaalL])
        firstStack.axis = .vertical
        firstStack.distribution = .fillEqually
        firstStack.alignment = .fill
        firstStack.spacing = 5
        firstStack.translatesAutoresizingMaskIntoConstraints = true
        
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
        let horstack = UIStackView(arrangedSubviews: [firstStack, leftStack, rightStack])
        horstack.axis = .horizontal
        horstack.distribution = .fillProportionally
        horstack.alignment = .fill
        horstack.spacing = 5
        horstack.translatesAutoresizingMaskIntoConstraints = false
        
        // HyrView Info
        let medisch = UILabel()
        medisch.text = "Medisch: zoeken op medische termen."
        medisch.font = UIFont.boldSystemFont(ofSize: 16)
        medisch.textColor = UIColor.white
        let medischnota = UILabel()
        medischnota.text = "Indeling waarbij alle medicijnen te vinden zijn."
        medischnota.font = UIFont.systemFont(ofSize: 14)
        medischnota.textColor = UIColor.white
        let basis = UILabel()
        basis.text = "Basis: zoeken op eenvoudige termen."
        basis.font = UIFont.boldSystemFont(ofSize: 16)
        basis.textColor = UIColor.white
        let basisnota = UILabel()
        basisnota.text = "Indeling waarbij niet alle medicijnen te vinden zijn. Bekijk bovendien de details om de juiste toepassing van een medicijn te vinden."
        basisnota.font = UIFont.systemFont(ofSize: 14)
        basisnota.textColor = UIColor.white
        basisnota.lineBreakMode = .byWordWrapping
        basisnota.numberOfLines = 2
        
        let topStack = UIStackView(arrangedSubviews: [medisch, medischnota])
        topStack.axis = .vertical
        topStack.spacing = 0
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomStack = UIStackView(arrangedSubviews: [basis, basisnota])
        bottomStack.axis = .vertical
        bottomStack.distribution = .fillProportionally
        bottomStack.spacing = 0
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        let hyrstack = UIStackView(arrangedSubviews: [topStack, bottomStack])
        hyrstack.axis = .vertical
        hyrstack.distribution = .fillProportionally
        hyrstack.spacing = 8
        hyrstack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: Stackview Layout
        var viewsDictionary: Dictionary<String, UIStackView> = [:]
        if hyrView == true {
            self.infoView.addSubview(hyrstack)
            viewsDictionary = ["stackView": hyrstack]
        } else {
            self.infoView.addSubview(horstack)
            viewsDictionary = ["stackView": horstack]
        }
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stackView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        infoView.addConstraints(stackView_H)
        infoView.addConstraints(stackView_V)
    }
    
//     MARK: - Setup appVersionView
    func setupAppVersionView() {
//        print("setup AppVersionView")
        self.appVersionView.isHidden = true
        self.appVersionView.translatesAutoresizingMaskIntoConstraints = false
        let width: CGFloat = 320.0
        let height: CGFloat = 180.0
        self.appVersionView=UIView(frame:CGRect(x: (self.view.center.x)-(width/2), y: (self.view.center.y)-(height/2), width: width, height: height))

        appVersionView.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        appVersionView.layer.cornerRadius = 8
        appVersionView.layer.borderWidth = 1
        appVersionView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(appVersionView)
        self.appVersionView.isHidden = self.H
        
        let labelApp = UILabel()
        labelApp.text = "MedCabinet België"
        labelApp.font = UIFont.boldSystemFont(ofSize: 22)
        labelApp.textColor = UIColor.white
        labelApp.translatesAutoresizingMaskIntoConstraints = false
        
        let labelVersion = UILabel()
        labelVersion.text = "Versie: \(appVersion)"
        labelVersion.font = UIFont.boldSystemFont(ofSize: 18)
        labelVersion.textColor = UIColor.white
        labelVersion.translatesAutoresizingMaskIntoConstraints = false
        
        let labelBuild = UILabel()
        labelBuild.text = "Model: \(appBuild)"
        labelBuild.font = UIFont.systemFont(ofSize: 15)
        labelBuild.textColor = UIColor.white
        labelBuild.translatesAutoresizingMaskIntoConstraints = false
        
        let databaseVersion = UILabel()
        databaseVersion.text = self.databaseV
        databaseVersion.font = UIFont.systemFont(ofSize: 15)
        databaseVersion.textColor = UIColor.white
        databaseVersion.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: Rate this app!
        let buttonRate = UIButton()
        buttonRate.setTitle("Rate this app", for: .normal)
        buttonRate.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        buttonRate.setTitleColor(.blue, for: .normal)
        buttonRate.setTitleColor(.red, for: .highlighted)
        buttonRate.backgroundColor = .white
        buttonRate.layer.cornerRadius = 8
        buttonRate.layer.borderWidth = 1
        buttonRate.layer.borderColor = UIColor.gray.cgColor
        buttonRate.showsTouchWhenHighlighted = true
        buttonRate.translatesAutoresizingMaskIntoConstraints = false
        buttonRate.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
 
        // MARK: Vertical stack
        let vertStack = UIStackView(arrangedSubviews: [labelApp, labelVersion, labelBuild, databaseVersion, buttonRate])
        vertStack.axis = .vertical
        vertStack.distribution = .fillProportionally
        vertStack.alignment = .fill
        vertStack.spacing = 8
        vertStack.translatesAutoresizingMaskIntoConstraints = false
        self.appVersionView.addSubview(vertStack)
        
        //Stackview Layout (constraints)
        vertStack.leftAnchor.constraint(equalTo: appVersionView.leftAnchor, constant: 20).isActive = true
        vertStack.topAnchor.constraint(equalTo: appVersionView.topAnchor, constant: 15).isActive = true
        vertStack.rightAnchor.constraint(equalTo: appVersionView.rightAnchor, constant: -20).isActive = true
        vertStack.heightAnchor.constraint(equalTo: appVersionView.heightAnchor, constant: -20).isActive = true
        vertStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        vertStack.isLayoutMarginsRelativeArrangement = true
    }

    // MARK: - Rate app in the App Store
    func rateApp() {
//        print("buttonRate pressed!")
        let appId = "1292288501"
        let url_string = "itms-apps://itunes.apple.com/gb/app/id\(appId)"
        /* ?action=write-review&mt=8 */
        if let url = URL(string: url_string) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - PickerView
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == level0Picker {
            return Array(level0dict.values).count
        } else if pickerView == level1Picker {
            return Array(level1dict.values).count
        } else if pickerView == lekenPicker {
            return Array(hyrdictleek.keys).count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == level0Picker {
            let sortedValues: Array<String> = sortData(level0dict)
            return sortedValues[row]
        } else if pickerView == level1Picker {
            return Array(level1dict.values).sorted()[row]
        } else if pickerView == lekenPicker {
            return Array(hyrdictleek.keys).sorted()[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//      goes in lieu of titleForRow if customization is desired
        let label = UILabel()
        if pickerView == level0Picker {
            label.text = String(sortData(level0dict)[row])
            label.textAlignment = .center
        } else if pickerView == level1Picker {
            label.text = String(sortData(level1dict)[row])
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
        } else if pickerView == lekenPicker {
            label.text = String(Array(lekendict.keys).sorted()[row])
            label.textAlignment = .center
        }
        
        return label
    }
/*    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == level1Picker {
            let pickerLabel = UILabel()
            let titleData = Array(level1dict.values).sorted()[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "System" ,size:10)!])
            pickerLabel.attributedText = myTitle
            return pickerLabel
        }
        return pickerLabel
    }
 */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unwindToep = false
//        print("pickerView row selected")
        if pickerView == level0Picker {
            let hyrvalue = sortData(level0dict)[row]
            for (key, value) in level0dict {
                if value == hyrvalue {
                    selectedHyr0 = key
                    toepzoekwoord = key
                }
            }
            pickerChanged = true
            filterContentForSearchText(searchText: selectedHyr0, scopeIndex: 4)
//            print("didSelectRow --> update picker 1")
            updatePicker1() // Fill second picker with options matching selected row in first picker

            //self.tableView.reloadData()
        }
        if pickerView == level1Picker {
            let hyrvalue = sortData(level1dict)[row] // Array sorted
            for (key, value) in level1dict {
                if value == hyrvalue {
                    selectedHyr1 = key
                    toepzoekwoord = key
                }
            }
            pickerChanged = true
            filterContentForSearchText(searchText: selectedHyr1, scopeIndex: 4)
        }
        if pickerView == lekenPicker {
            let hyrvalue = Array(hyrdictleek.keys).sorted() // Array sorted
//            print("hyrvalue: \(hyrvalue)")

            for (key, value) in hyrdictleek {
                if key == hyrvalue[row] {
                    toepzoekwoord = value
                }
            }
            pickerChanged = true
            filterContentForSearchText(searchText: toepzoekwoord, scopeIndex: 4)
        }
    }
    
    func sortData(_ dict: Dictionary<String,String>) -> Array<String> {
        let dictarray = Array(dict.keys)
        let orderedkeys = dictarray.sorted()
        var valuearray: Array<String> = []
        for k in orderedkeys {
            for (key, value) in dict {
                if k == key {
                    valuearray.append(value)
                }
            }
        }
        return valuearray.sorted()
    }
    
    func updatePicker1() {
//        print("updatePicker1")
//        print("unwindToep = \(unwindToep)")
        // Get first character hyr
        let firstCharacter = selectedHyr0
        // Filter level1 dictionary
        var tempArray: Dictionary<String, String> = [selectedHyr0:" Alle"]
        for (key, value) in Dictionaries().level1Picker() {
            let firstCharacterofKey = key[key.index(key.startIndex, offsetBy: 0)]
            if String(firstCharacterofKey) == String(firstCharacter) {
                tempArray[key] = value
            }
        }
        level1dict = tempArray
        
        if unwindToep == false {
            let row1 = level1Picker.selectedRow(inComponent: 0)
//            print("unwindToep = false, row1 = \(row1)")
            
            level1Picker.selectRow(row1, inComponent: 0, animated: true)
            
        } else {
//            print("unwindToep = true, unwindRow = \(unwindRow)")
            level1Picker.selectRow(unwindRow, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar(selectedScope: Int) {
//        print("setting up searchbar")
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        searchBar.isHidden = false
        searchBar.showsScopeBar = true
        searchBar.tintColor = UIColor.gray
        // scope button titles: mpnm, mppnm, vosnm_, nirnnm, alles(mpnm,vosnm,nirnm)
        searchBar.scopeButtonTitles = ["merknaam", "verpakking", "stofnaam", "firmanaam", "toepassing", "alles"]
        searchBar.selectedScopeButtonIndex = selectedScope
        //print("Current zoekwoord: \(String(describing: zoekwoord))")
        searchBar.text = zoekwoord
        searchBar.delegate = self

        self.tableView.tableHeaderView = searchBar
    }
    
    func scrollToTop() {
//        print("Scroll to top")
        self.TopButton.isHidden = true
        let topOffset = CGPoint(x: 0, y: 0)
        let offset = CGPoint(x: 0, y: -188)
        if hyrView == true {
            tableView.setContentOffset(offset, animated: false)
        } else {
            tableView.setContentOffset(topOffset, animated: false)
        }
    }
    
    // MARK: - setupTopButton
    func setupTopButton() {
        TopButton.isHidden = true
        TopButton.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        TopButton.layer.cornerRadius = 25
        TopButton.setTitle("Top", for: .normal)
        TopButton.setTitleColor(UIColor.white, for: .normal)
        TopButton.titleLabel?.lineBreakMode = .byWordWrapping
        TopButton.titleLabel?.textAlignment = .center
        TopButton.titleLabel?.font.withSize(7)
    }
    // MARK: - setupIndexSort
    func setupIndexSortButton() {
        IndexSortButton.isHidden = true
        IndexSortButton.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        IndexSortButton.layer.cornerRadius = 25
        IndexSortButton.setTitle("Sort index", for: .normal)
        IndexSortButton.setTitleColor(UIColor.white, for: .normal)
        IndexSortButton.titleLabel?.lineBreakMode = .byWordWrapping
        IndexSortButton.titleLabel?.textAlignment = .center
        IndexSortButton.titleLabel?.font.withSize(7)
    }
    
    func sortIndex() {
        if self.sortKeyword != "index" {
            self.asc = true
        } else {
            if self.asc == false {
                self.asc = true
            } else {
                self.asc = false
            }
        }
        self.sortKeyword = "index"
        self.AZSortButton.isHidden = false
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
        
    }
    
    // MARK: - setupIndexSort
    func setupAZSortButton() {
        AZSortButton.isHidden = true
        AZSortButton.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        AZSortButton.layer.cornerRadius = 25
        AZSortButton.setTitle("A-Z", for: .normal)
        AZSortButton.setTitleColor(UIColor.white, for: .normal)
        AZSortButton.titleLabel?.lineBreakMode = .byWordWrapping
        AZSortButton.titleLabel?.textAlignment = .center
        AZSortButton.titleLabel?.font.withSize(7)
    }
    
    func sortIndexAZ() {
        if self.selectedScope == 1 {
            self.sortKeyword = "mppnm"
        } else if self.selectedScope == 2 {
            self.sortKeyword = "vosnm_"
        }
        //print("self asc = \(self.asc)")
        //print("Sort Index A-Z")
        self.asc = true
        self.AZSortButton.isHidden = true
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
        
    }

    
    // MARK: - Layout
    func setupLayout() {
        segmentedButton.setTitle("•....", forSegmentAt: 0)
        segmentedButton.setTitle("..•..", forSegmentAt: 1)
        segmentedButton.setTitle("....•", forSegmentAt: 2)
        segmentedToepSearch.setTitle("medisch", forSegmentAt: 0)
        segmentedToepSearch.setTitle("basis", forSegmentAt: 1)
        segmentedToepSearch.isHidden = true
        noodnummers.numberOfLines = 2
        noodnummers.text = "Anti-gifcentrum: 070 245 245\nDruglijn: 078 15 10 20"
        noodnummers.font = UIFont.boldSystemFont(ofSize: 14)
        noodnummers.textColor = UIColor.darkGray
        noodnummers.translatesAutoresizingMaskIntoConstraints = false
        
        zoekenImage.image = #imageLiteral(resourceName: "ZoekenArrow")
        
        navigationItem.title = "Zoeken"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        

    }
    
    // MARK: Set Scope
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        /* FILTER SCOPE */

        switch selectedScope {
        case 0:
            //print("scope: merknaam")
            hyrPickerView.isHidden = true
            segmentedToepSearch.isHidden = true
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 0
            hyrView = false
            IndexSortButton.isHidden = true
            self.AZSortButton.isHidden = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        case 1:
            //print("scope: verpakking")
            hyrPickerView.isHidden = true
            segmentedToepSearch.isHidden = true
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 1
            hyrView = false
            IndexSortButton.isHidden = false
        case 2:
            //print("scope: vosnaam")
            hyrPickerView.isHidden = true
            segmentedToepSearch.isHidden = true
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
            zoekwoord = searchBar.text!
            self.selectedScope = 2
            hyrView = false
            IndexSortButton.isHidden = false
        case 3:
            //print("scope: firmanaam")
            hyrPickerView.isHidden = true
            segmentedToepSearch.isHidden = true
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.ir.nirnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 3
            hyrView = false
            IndexSortButton.isHidden = true
            self.AZSortButton.isHidden = true
        case 4:
            //print("scope: hierarchie")
            self.view.endEditing(true)
//            setupHyrPickerView()
            pickerChanged = true
            segmentedToepSearch.isHidden = false
            filterKeyword = "mp.hyr.hyr"
            sortKeyword = "mp.mpnm"
            self.selectedScope = 4
            if searchBar.text == nil {
                searchBar.text = ""
            }
            if segmentedToepSearch.selectedSegmentIndex == 1 {
                let l: Int = lekenPicker.selectedRow(inComponent: 0)
                let vall = Array(hyrdictleek.keys).sorted() // Array sorted

                for (key, value) in hyrdictleek {
                    if key == vall[l] {
                        toepzoekwoord = value
                    }
                }
            } else {
                let z: Int = level0Picker.selectedRow(inComponent: 0)
                let valz = sortData(level0dict)[z]
                for (key, value) in level0dict {
                    if value == valz {
                        //zoekwoord = searchBar.text!
                        //print("value == valz")
                        toepzoekwoord = key
                        selectedHyr0 = key
                    }
                }
                let a: Int = level1Picker.selectedRow(inComponent: 0)
                let vala = sortData(level1dict)[a]
                for (key, value) in level1dict {
                    if value == vala {
                        //print("value == vala")
                        //zoekwoord = key
                        toepzoekwoord = key
                        selectedHyr1 = key
                    }
                }
            }
            hyrView = true
            IndexSortButton.isHidden = true
            self.AZSortButton.isHidden = true
        case 5:
            //print("scope: alles")
            hyrPickerView.isHidden = true
            segmentedToepSearch.isHidden = true
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            self.selectedScope = 5
            hyrView = false
            IndexSortButton.isHidden = true
            self.AZSortButton.isHidden = true
            zoekwoord = searchBar.text!
        default:
            segmentedToepSearch.isHidden = true
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
            self.selectedScope = -1
            IndexSortButton.isHidden = true
            self.AZSortButton.isHidden = true
        }
        
        //print("scope changed: \(selectedScope)")
        //print("filterKeyword: \(filterKeyword)")
        //print("searchbar text: \(searchBar.text!)")
        if hyrView == false {
            //print("zoekwoord: \(zoekwoord!)")
            self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: selectedScope)
        } else {
            //print("toepzoekwoord: \(toepzoekwoord)")
            self.filterContentForSearchText(searchText: toepzoekwoord, scopeIndex: 4)
        }
    }
    
    // MARK: Set Toepassing search filter
    @IBAction func searchFilterChanged(_ sender: UISegmentedControl) {
        switch segmentedToepSearch.selectedSegmentIndex {
        case 0:
            filterOperator = "medisch"
            let hyr0value = sortData(level0dict)[level0Picker.selectedRow(inComponent: 0)]
            for (key, value) in level0dict {
                if value == hyr0value {
                    selectedHyr0 = key
                    toepzoekwoord = key
                }
            }
            let hyr1value = sortData(level1dict)[level1Picker.selectedRow(inComponent: 0)]
            for (key, value) in level1dict {
                if value == hyr1value {
                    selectedHyr1 = key
                    toepzoekwoord = key
                }
            }
        case 1:
            filterOperator = "basis"
            let hyrvalue = Array(hyrdictleek.keys).sorted() // Array sorted
            for (key, value) in hyrdictleek {
                if key == hyrvalue[lekenPicker.selectedRow(inComponent: 0)] {
                    toepzoekwoord = value
                }
            }
        default:
            filterOperator = "medisch"
            break
        }
        pickerChanged = true
        setupHyrPickerView()
        
        self.filterContentForSearchText(searchText: toepzoekwoord, scopeIndex: 4)
        self.tableView.reloadData()
//        updateView()
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
        if self.zoekwoord != nil {
            //print("zoekwoord not nil!")
            //print("hyrView: ", hyrView)
            if hyrView == true {
                //print("scope = 4, toepzoekwoord: ", self.toepzoekwoord)
                //print("zoekwoord: ", self.zoekwoord!)
                self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: 4)
            } else {
                //print("huidig zoekwoord: \(self.zoekwoord!)")
                self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
            }
        } else {
//            print("zoekwoord nil!")
            if hyrView == true {
                self.filterContentForSearchText(searchText: self.toepzoekwoord, scopeIndex: 4)
            } else {
                self.filterContentForSearchText(searchText: "", scopeIndex: self.selectedScope)
            }
            
        }
        self.tableView.reloadData()
        updateView()
    }
    
    // MARK: - Searchbar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        scrollToTop()
        searchActive = true
        searchBar.text = zoekwoord
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        zoekwoord = searchText
        searchActive = true
        //print("Zoekterm: \(searchBar.text!)")
        //print("Scope: \(self.selectedScope)")
        if hyrView == false {
            self.filterContentForSearchText(searchText: searchText, scopeIndex: self.selectedScope)
        } else {
            self.filterContentForSearchText(searchText: searchText, scopeIndex: 4)
        }
        if (self.selectedScope == 1 || self.selectedScope == 2) && self.IndexSortButton.isHidden == true  {
            let m = fetchedResultsController.fetchedObjects?.count
            if m != 0 {
//                print("textDidChange: sortIndexUp is shown")
                self.IndexSortButton.isHidden = false
            }
        }
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar) {
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        print("cancel clicked")
        filterKeyword = "mppnm"
        sortKeyword = "mppnm"
        hyrView = false
        self.setUpSearchBar(selectedScope: -1)
        self.selectedScope = -1
        self.searchBar.showsScopeBar = false
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
//        print("should end editing")
        self.tableView.reloadData()
        return true
    }

    // MARK: - Zoekfilter
    func filterContentForSearchText(searchText: Any, scopeIndex: Int) {
//        print("filter content for searchtext")
        let offset = CGPoint(x: 0, y: -188)
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate
        if scopeIndex == -1 {
//            Zoeken in naam en verpakking (default)
            if (searchText as! String).isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || mp.mpnm \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText])
                let sub2 = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", searchText as! String)
                let sub3 = NSPredicate(format: "use != %@", "H")
                let subpredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2])
                
                if !hospSwitch.isOn {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub3])
                } else {
                    predicate = subpredicate
                }
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }

        } else if scopeIndex == 5 {
//            Zoeken in alles
            if (searchText as! String).isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText])
                let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText as! String)
                let sub3 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText as! String)
                let sub4 = NSPredicate(format: "use != %@", "H")
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2, sub3])
                let predicate2 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText as! String)
                let subpredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
                if !hospSwitch.isOn {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub4])
                } else {
                    predicate = subpredicate
                }
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        } else if scopeIndex == 4 {
//            Zoeken via Toepassing
            if pickerChanged == false {
                var sTA: Array<String> = []
                if toepzoekwoord is String {
                    sTA.append(toepzoekwoord as! String)
                } else {
                    sTA = toepzoekwoord as! Array<String>
                }
                if (searchText as! String) != "" {
                    var sub1: [NSPredicate] = []
                    var subpredicate: NSPredicate
                    for i in stride(from: 0, to: sTA.count, by: 1) {
                        let key = sTA[i]
                        let subpred = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", key)
                        sub1.append(subpred)
                    }
                    subpredicate = NSCompoundPredicate(orPredicateWithSubpredicates: sub1)
                    let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText as! String)
                    
                    let sub3 = NSPredicate(format: "use != %@", "H")
                    let subpredicate1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub2])
                    if !hospSwitch.isOn {
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate1, sub3])
                    } else {
                        predicate = subpredicate1
                    }
                } else {
                    let sub3 = NSPredicate(format: "use != %@", "H")
                    var subpredicate: NSPredicate
                    if toepzoekwoord is Array<String> {
                        var subpredicates: [NSPredicate] = []
                        for i in stride(from: 0, to: (toepzoekwoord as! Array<String>).count, by: 1) {
                            let key = (toepzoekwoord as! Array<String>)[i]
                            let subpred = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", key)
                            subpredicates.append(subpred)
                        }
                        subpredicate = NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
                    } else {
                        subpredicate = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", toepzoekwoord as! String)
                    }

                    if !hospSwitch.isOn {
                        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub3])
                    } else {
                        predicate = subpredicate
                    }
                }
            
                sortDescriptors = [NSSortDescriptor(key: "mp.mpnm", ascending: true)]
                
            } else {  // Picker changed
                let sub3 = NSPredicate(format: "use != %@", "H")
                var subpredicate: NSPredicate
                if searchText is Array<String> {
                    var subpredicates: [NSPredicate] = []
                    for i in stride(from: 0, to: (searchText as! Array<String>).count, by: 1) {
                        let key = (searchText as! Array<String>)[i]
                        let subpred = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", key)
                        subpredicates.append(subpred)
                    }
                    subpredicate = NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
                } else {
                    subpredicate = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", self.toepzoekwoord as! String)
                }
                if !hospSwitch.isOn {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub3])
                } else {
                    predicate = subpredicate
                }
                sortDescriptors = [NSSortDescriptor(key: "mp.mpnm", ascending: true)]
                pickerChanged = false
            }
            
        } else {
            if (searchText as! String).isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                let sub3 = NSPredicate(format: "use != %@", "H")
                let subpredicate = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText as! String)
                if !hospSwitch.isOn {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subpredicate, sub3])
                } else {
                    predicate = subpredicate
                }
                //print("sort keyword = \(sortKeyword)")
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: self.asc)]
            }
        }
        
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchedResultsController.fetchRequest.predicate = predicate
//        print(predicate)
        do {
            try self.fetchedResultsController.performFetch()
            //print("fetching from mpp...")
        } catch {
            let fetchError = error as NSError
            fatalError("\(fetchError), \(fetchError.userInfo)")
        }
        if self.tableView.contentOffset == offset {
            self.tableView.setContentOffset(offset, animated: false)
        }
        self.tableView.reloadData()
        //print("filterKeyword: \(filterKeyword)")
        //print("sortkeyword \(sortKeyword)")
        //print("searchText: \(searchText)")
        self.updateView()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destination as! MedicijnDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath)
            destination.medicijn = selectedObject
//            print("Segue: \(segue.identifier!)!")
        default:
//            print("Segue: \(segue.identifier!)!")
            break
        }
    }

    // MARK: - View Methods
    fileprivate func updateView() {
//        print("updateView")
        tableView.isHidden = false
        var x:Int
        if let medicijnen = fetchedResultsController.fetchedObjects {
            x = medicijnen.count
            if x == 0 {
                self.tableView.alwaysBounceVertical = false
                IndexSortButton.isHidden = true
                AZSortButton.isHidden = true
                gevondenItemsLabel.isHidden = false
                tableView.isHidden = false
                tableView.tableFooterView = UIView()
                if hyrView == false {
                    zoekenImage.isHidden = false
                    noodnummers.isHidden = false
                    tableView.isScrollEnabled = false
                    self.view.bringSubview(toFront: self.zoekenImage)
                } else {
                    zoekenImage.isHidden = true
                    noodnummers.isHidden = true
                }
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.tableView.alwaysBounceVertical = true
                gevondenItemsLabel.isHidden = false
                zoekenImage.isHidden = true
                noodnummers.isHidden = true
                tableView.isScrollEnabled = true
                
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            x = 0
            gevondenItemsLabel.isHidden = false
            zoekenImage.isHidden = false
            noodnummers.isHidden = false
            tableView.isHidden = true
            tableView.isScrollEnabled = true
            tableView.bounces = true
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        self.tableView.reloadData()
        gevondenItemsLabel.text = "\(x)"
//        view.layoutSubviews()
//        view.setNeedsDisplay()
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        self.appDelegate.saveContext()
    }
    
}
extension AddMedicijnViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("controller will change content: beginUpdates()")
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("controller did change content: endUpdates()")
        self.tableView.endUpdates()
        updateView()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("Controller did change an object")
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
//            print("...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    // MARK: - Scrolling behaviour
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.TopButton.isHidden = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("Scroll detected")
        if (scrollView.contentOffset.y == 0.0) || (hyrView && scrollView.contentOffset.y == -188.0) {  // TOP
//            print("Hide Top Button")
            self.TopButton.isHidden = true
            let topOffset = CGPoint(x: 0, y: 0)
            let offset = CGPoint(x: 0, y: -188)
            if hyrView == true {
                tableView.setContentOffset(offset, animated: false)
            } else {
                tableView.setContentOffset(topOffset, animated: false)
            }
        } else {
//            print("Show Top Button")
            self.TopButton.isHidden = false
        }

    }
    
    // MARK: - Table data
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // MARK: Add to Medicijnkast
        let addToMedicijnkast = UITableViewRowAction(style: .normal, title: "Naar\nmedicijnkast") { (action, indexPath) in
            //print("naar medicijnkast")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "medicijnkast", uservalue: true, managedObjectContext: context)
            // Save data to context
            do {
                try context.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedKast"), object: nil)
//                print("med saved in medicijnkast")
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.0, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor; self.tableView.reloadRows(at: [indexPath], with: .none)}) }
            )
            // Copy entity data to userdefaults
            self.copyUserdataToUserdefaults(managedObjectContext: context)

        }
        addToMedicijnkast.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        
        // MARK: Add to Shoppinglist
        let addToShoppingList = UITableViewRowAction(style: .normal, title: "Naar\naankooplijst") { (action, indexPath) in
            //print("naar aankooplijst")
            // Fetch Medicijn
            let medicijn = self.fetchedResultsController.object(at: indexPath)
            medicijn.userdata?.setValue(true, forKey: "aankooplijst")
            let context = self.appDelegate.persistentContainer.viewContext
            self.addUserData(mppcvValue: medicijn.mppcv!, userkey: "aankooplijst", uservalue: true, managedObjectContext: context)
            do {
                try context.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedAankoop"), object: nil)
//                print("med saved in aankooplijst")
            } catch {
//                print("med not saved in aankooplijst!")
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor; self.tableView.reloadRows(at: [indexPath], with: .none)}) }
            )
            // Copy entity data to userdefaults
            self.copyUserdataToUserdefaults(managedObjectContext: context)

        }
        addToShoppingList.backgroundColor = UIColor(red: 85/255, green: 0/255, blue:0/255, alpha:1)
        
//        self.tableView.setEditing(false, animated: false)
        return [addToMedicijnkast, addToShoppingList]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnTableViewCell.reuseIdentifier, for: indexPath) as? MedicijnTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        cell.selectionStyle = .none
        
//         Fetch Medicijn
        let medicijn = fetchedResultsController.object(at: indexPath)

//         Configure Cell
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
        if medicijn.userdata != nil && medicijn.userdata?.medicijnkast == true {
            cell.iconKast.image = #imageLiteral(resourceName: "medicijnkast_icon_black")
        } else {
            cell.iconKast.image = nil
        }
        if medicijn.userdata != nil && medicijn.userdata?.aankooplijst == true {
            cell.iconLijst.image = #imageLiteral(resourceName: "aankooplijst_icon_black")
        } else {
            cell.iconLijst.image = nil
        }
        cell.mppnm.text = medicijn.mppnm
//        print(medicijn.mppnm!)
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
        cell.cheapest.text = "index: \(String(describing: medicijn.index)) c€"
        
        return cell
    }
    
    // MARK: - private create record
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
    
    // MARK: - private fetch records
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

    // MARK: - fetch all records from Userdata
    private func fetchAllRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
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
    
    // MARK: - add userdata
    func addUserData(mppcvValue: String, userkey: String, uservalue: Bool, managedObjectContext: NSManagedObjectContext) {
        // one-to-one relationship
        // Check if record exists
        //print("addUserData: \(mppcvValue), \(userkey), \(uservalue)")
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
            } else {
//                print("not newUserData")
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
    
    // MARK: - Copy to Userdefaults
    func copyUserdataToUserdefaults(managedObjectContext: NSManagedObjectContext) {
        //print("Copying Userdata to localdata")
        // Read entity Userdata values
        let userdata = fetchAllRecordsForEntity("Userdata", inManagedObjectContext: managedObjectContext)
        var medarray: Array<Any> = []
        // Check if Userdefaults exist
        // Store to Userdefaults - Create array and store in localdata under key: mppcv
        // Read array of userdata in localdata
        if localdata.object(forKey: "userdata") != nil {
            //print("userdata exists in localdata")
            medarray = localdata.array(forKey: "userdata")!
        } else {
            //print("userdata does not exist in localdata")
            medarray = [] as [Any]
        }
        
        for userData in userdata {
            //print("userData: ", userData)
            let dict = ["medicijnkast": (userData.value(forKey: "medicijnkast")) as! Bool, "medicijnkastarchief": (userData.value(forKey: "medicijnkastarchief")) as! Bool, "aankooplijst": (userData.value(forKey: "aankooplijst")) as! Bool, "aankooparchief": (userData.value(forKey: "aankooparchief")) as! Bool, "aantal": (userData.value(forKey: "aantal")) as! Int, "lastupdate": (userData.value(forKey: "lastupdate")) as! Date, "mppcv": (userData.value(forKey: "mppcv")) as! String, "restant": (userData.value(forKey: "restant")) as! Int] as [String : Any]
            //print("dict: ", dict)
            
            
            // Add mppcv to array of userdata in localdata
            medarray.append(userData.value(forKey: "mppcv")!)
            localdata.set(medarray, forKey: "userdata")
            localdata.set(dict, forKey: (userData.value(forKey: "mppcv")) as! String)
            //print("saved \(String(describing: userData.value(forKey: "mppcv"))) to localdata")
        }
    }
    
    // MARK: - Copy Userdefaults to UserData (DB) --> after update!
    func copyUserDefaultsToUserData(managedObjectContext: NSManagedObjectContext) {
        let context = self.appDelegate.persistentContainer.viewContext
//        print("Copying localdata to Userdata")
        // Read UserDefaults array: from localdata, key: userdata
//        print("Localdata: \(String(describing: localdata.array(forKey: "userdata")))")
        // Use UserDefaults array values to obtain dictionary data
        for userData in localdata.array(forKey: "userdata")! {
//            print("userdata: \(userData)")
            let dict = localdata.dictionary(forKey: (userData as! String))
//            print("Dict: \(dict!)")
            for (key, value) in dict! {
                if key == "medicijnkast" || key == "medicijnkastarchief" || key == "aankooplijst" || key == "aankooparchief" {
                    addUserData(mppcvValue: (userData as! String), userkey: key, uservalue: (value as! Bool), managedObjectContext: context)
                }
            }
        }
    }
}
