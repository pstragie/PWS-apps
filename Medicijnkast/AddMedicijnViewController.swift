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
    let CellDetailIdentifier = "SegueFromAddToDetail"
    let localdata = UserDefaults.standard
    @IBOutlet weak var zoekenImage: UIImageView!

    // MARK: - Properties Variables
    var hyrView: Bool = false
    var selectedHyr0: String = "D"
    var selectedHyr1: String = "DA"
    var toepzoekwoord: String = "D"
    var infoView = UIView()
    var appVersionView = UIView()
    var versionView = UIView()
    var hyrPickerView = UIView()
    var pickerChanged: Bool = false
    var upArrow = UIView()
    var sortDescriptorIndex: Int? = nil
    var selectedScope: Int = -1
    var selectedSegmentIndex: Int = 0
    var searchActive: Bool = false
    weak var receivedData: MPP?
    var receivedArray: Array<String> = []
    var zoekwoord: String? = nil
    var filterKeyword:String = "mppnm"
    var zoekoperator:String = "BEGINSWITH"
    var format:String = "mppnm BEGINSWITH[c] %@"
    var sortKeyword:String = "mppnm"
    
    // MARK: - Referencing Outlets
    
    @IBOutlet weak var gevondenItemsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCloseMenuView: UIButton!
    //@IBOutlet weak var buttonRate: UIButton!
    @IBAction func appVersion(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.appVersionView.center.x >= 0 {
                self.appVersionView.center.x -= self.view.bounds.width
            } else {
                self.appVersionView.center.x += self.view.bounds.width
            }
        }, completion: nil
        )
        btnCloseMenuView.isHidden = false
        btnCloseMenuView.isEnabled = true
    }
    
    // MARK: - Referencing Actions
    @IBAction func btnCloseMenuView(_ sender: UIButton) {
        print("btnCloseMenuView pressed!")
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            if self.infoView.center.y >= 0 {
                self.infoView.center.y -= self.view.bounds.height
                self.view.bringSubview(toFront: self.infoView)
            }
            if self.appVersionView.center.x >= 0 {
                self.appVersionView.center.x -= self.view.bounds.width
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
                self.infoView.center.y -= self.view.bounds.height
                //self.view.bringSubview(toFront: self.infoView)
                
            } else {
                self.infoView.center.y += self.view.bounds.height
                //self.view.bringSubview(toFront: self.view)
            }
        }, completion: nil
        )
        btnCloseMenuView.isHidden = false
        btnCloseMenuView.isEnabled = true
    }

    // MARK: - Unwind actions
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? MedicijnDetailViewController {
            receivedData = sourceViewController.dataPassed
            //print("received data: \(receivedData)")
            receivedArray = sourceViewController.arrayPassed
            //print("received string: \(receivedArray)")
        }
        
        switch segue.identifier {
        case "vosnmToSearch"?:
            filterKeyword = "vosnm_"
            sortKeyword = "index"
            zoekwoord = (receivedData?.vosnm_)!
            self.selectedScope = 2
            hyrView = false
            //print("vosnm_: \(zoekwoord!)")
        case "stofnaam1"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[0]
            self.selectedScope = 2
            hyrView = false
            //print("stofnm1")
        case "stofnaam2"?:
            filterKeyword = "ANY sam.stof.ninnm"
            sortKeyword = "index"
            zoekwoord = receivedArray[1]
            self.selectedScope = 2
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
                print("More than two characters")
                secondCharacter = hyr[hyr.index(hyr.startIndex, offsetBy: 1)]
                hyrstring = String(firstTwoCharacters)
            }
            filterKeyword = "mp.hyr.hyr"
            sortKeyword = "mp.mpnm"
            toepzoekwoord = hyrstring!
            zoekwoord = ""
            searchBar.text = ""
            self.selectedScope = 4
            //print("hyr")
            var x: Int = 0
            let v = level0dict[String(firstCharacter)]
            x = sortData(level0dict).index(of: v!)!
            level0Picker.selectRow(x, inComponent: 0, animated: true)
            selectedHyr0 = String(firstCharacter)
            //print("selectedHyr0: \(selectedHyr0)")
            updatePicker1()
            
            var y: Int = 0
            let w = Dictionaries().level1Picker()[String(firstCharacter)+String(secondCharacter!)]
            //print("w: \(w!)")
            y = sortData(level1dict).index(of: w!)!
            //print("y: \(y)")
            level1Picker.selectRow(y, inComponent: 0, animated: true)
            hyrView = true
        default:
            filterKeyword = "mppnm"
        }
        //print("Unwind selectedScope: \(selectedScope)")
        self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: selectedScope)
    }
    
    // MARK: - View Life Cycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //print("View did disappear!")
        self.appDelegate.saveContext()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Addmedicijn View did load!")
        setupLayout()
        setUpSearchBar(selectedScope: -1)
        navigationItem.title = "Zoeken"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        level0Picker.delegate = self
        level0Picker.dataSource = self
        level1Picker.delegate = self
        level1Picker.dataSource = self
        updatePicker1() // Fill second picker with options matching row 0 in first picker
        setupHyrPickerView()

        self.updateView()
        setupAppVersionView()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        /*// MARK: - Temp copy defaults to userdata
        let context = self.appDelegate.persistentContainer.viewContext
        copyUserDefaultsToUserData(managedObjectContext: context)*/
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print("SelectedScope: \(selectedScope)")
        setUpSearchBar(selectedScope: selectedScope)
        //print("Layout selectedHyr0 \(selectedHyr0)")
        updatePicker1()
        zoekenImage.image = #imageLiteral(resourceName: "ZoekenArrow")
        level1Picker.reloadAllComponents()
        //print("hyrView: \(hyrView)")
        if hyrView == true {
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
        setupInfoView()
        setupUpArrow()
        //print("view Did Layout subviews")
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
    
    // MARK: - Setup HyrPickerView
    func setupHyrPickerView() {
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
        
        let horstack = UIStackView(arrangedSubviews: [level0Picker, level1Picker])
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
        // MARK: Stackview Layout
        let viewsDictionary = ["stackView": horstack]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-115-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stackView]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        infoView.addConstraints(stackView_H)
        infoView.addConstraints(stackView_V)
    }
    
    // MARK: - Setup appVersionView
    func setupAppVersionView() {
        self.appVersionView.isHidden = true
        self.appVersionView=UIView(frame:CGRect(x: ((self.view.bounds.width)/2)-(self.view.bounds.width)/4, y: ((self.view.bounds.height)/2)-80, width: (self.view.bounds.width)/2, height: 160))
        self.appVersionView.center.x -= view.bounds.width
        appVersionView.backgroundColor = UIColor(red: 125/255, green: 0/255, blue:0/255, alpha:1)
        appVersionView.layer.cornerRadius = 8
        appVersionView.layer.borderWidth = 1
        appVersionView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(appVersionView)
        self.appVersionView.isHidden = false
        
        let labelApp = UILabel()
        labelApp.text = "MedCabinet Free"
        labelApp.font = UIFont.boldSystemFont(ofSize: 26)
        labelApp.textColor = UIColor.white
        let labelVersion = UILabel()
        
        // MARK: Version and build
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        var appBuild = ""
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appBuild = build
        }
        labelVersion.text = "Version: \(appVersion)"
        labelVersion.font = UIFont.boldSystemFont(ofSize: 22)
        labelVersion.textColor = UIColor.white
        
        let labelBuild = UILabel()
        labelBuild.text = "Build: \(appBuild)"
        labelBuild.font = UIFont.systemFont(ofSize: 17)
        labelBuild.textColor = UIColor.white
        
        // MARK: Rate this app!
        
        let buttonRate = UIButton(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.width)/2, height: 30))
        buttonRate.backgroundColor = .white
        buttonRate.layer.cornerRadius = 8        
        buttonRate.setTitle("Rate this app", for: .normal)
        buttonRate.setTitleColor(UIColor.blue, for: .normal)
        buttonRate.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
 
        let vertstack = UIStackView(arrangedSubviews: [labelApp, labelVersion, labelBuild, buttonRate])
        vertstack.axis = .vertical
        vertstack.distribution = .fillProportionally
        vertstack.alignment = .fill
        vertstack.spacing = 8
        vertstack.translatesAutoresizingMaskIntoConstraints = false
        self.appVersionView.addSubview(vertstack)
        
        // Layout the stack view
        let viewsDictionary = ["stackView": vertstack]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        appVersionView.addConstraints(stackView_H)
        appVersionView.addConstraints(stackView_V)
    }

    // MARK: - Rate app in the App Store
    func rateApp() {
        print("buttonRate pressed!")
        let appId = "1257430169"
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
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == level0Picker {
            let sortedValues: Array<String> = sortData(level0dict)
            return sortedValues[row]
        } else if pickerView == level1Picker {
            return Array(level1dict.values).sorted()[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            
            updatePicker1()
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
        let row1 = level1Picker.selectedRow(inComponent: 0)
        if row1 != 0 {
            level1Picker.selectRow(row1, inComponent: 0, animated: true)
        } else {
            level1Picker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - search bar related
    fileprivate func setUpSearchBar(selectedScope: Int) {
        //print("setting up searchbar")
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        searchBar.isHidden = false
        searchBar.showsScopeBar = true
        // scope button titles: mpnm, mppnm, vosnm_, nirnnm, alles(mpnm,vosnm,nirnm)
        searchBar.scopeButtonTitles = ["merknaam", "verpakking", "stofnaam", "firmanaam", "toepassing", "alles"]
        searchBar.selectedScopeButtonIndex = selectedScope
        //print("Current zoekwoord: \(String(describing: zoekwoord))")
        searchBar.text = zoekwoord
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }
    
    func setupUpArrow() {
        self.upArrow=UIView(frame:CGRect(x: self.view.bounds.width-52, y: self.view.bounds.height-200, width: 50, height: 50))
        upArrow.isHidden = true
        upArrow.backgroundColor = UIColor.black.withAlphaComponent(0.60)
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
    
    func scrollToTop() {
        //print("Scroll to top button clicked")
        let topOffset = CGPoint(x: 0, y: 0)
        let offset = CGPoint(x: 0, y: -188)
        if hyrView == true {
            tableView.setContentOffset(offset, animated: false)
        } else {
            tableView.setContentOffset(topOffset, animated: false)
        }
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
            //print("scope: merknaam")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 0
            hyrView = false
        case 1:
            //print("scope: verpakking")
            filterKeyword = "mppnm"
            sortKeyword = "mppnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 1
            hyrView = false
        case 2:
            //print("scope: vosnaam")
            filterKeyword = "vosnm_"
            sortKeyword = "vosnm_"
            zoekwoord = searchBar.text!
            self.selectedScope = 2
            hyrView = false
        case 3:
            //print("scope: firmanaam")
            filterKeyword = "mp.ir.nirnm"
            sortKeyword = "mp.ir.nirnm"
            zoekwoord = searchBar.text!
            self.selectedScope = 3
            hyrView = false
        case 4:
            //print("scope: hierarchie")
            self.view.endEditing(true)
            filterKeyword = "mp.hyr.hyr"
            sortKeyword = "mp.mpnm"
            self.selectedScope = 4
            if searchBar.text == nil {
                searchBar.text = ""
            }
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

            hyrView = true
        case 5:
            //print("scope: alles")
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            self.selectedScope = 5
            hyrView = false
            zoekwoord = searchBar.text!
        default:
            filterKeyword = "mp.mpnm"
            sortKeyword = "mp.mpnm"
            zoekwoord = searchBar.text!
            self.selectedScope = -1
        }
        
        //print("scope changed: \(selectedScope)")
        //print("filterKeyword: \(filterKeyword)")
        //print("searchbar text: \(searchBar.text!)")
        if hyrView == false {
            //print("zoekwoord: \(zoekwoord!)")
            self.filterContentForSearchText(searchText: zoekwoord!, scopeIndex: selectedScope)
        } else {
            //print("toepzoekwoord: \(toepzoekwoord)")
            self.filterContentForSearchText(searchText: "", scopeIndex: 4)
        }
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
            print("zoekwoord nil!")
            if hyrView == true {
                self.filterContentForSearchText(searchText: self.toepzoekwoord, scopeIndex: 4)
            } else {
                self.filterContentForSearchText(searchText: "", scopeIndex: self.selectedScope)
            }
            
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
        searchBar.text = zoekwoord
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print("text did change")
        zoekwoord = searchText
        searchActive = true
        //print("Zoekterm: \(searchBar.text!)")
        //print("Scope: \(self.selectedScope)")
        if hyrView == false {
            self.filterContentForSearchText(searchText: searchText, scopeIndex: self.selectedScope)
        } else {
            self.filterContentForSearchText(searchText: searchText, scopeIndex: 4)
        }
    }
    
    func searchBarSearchButtonClicked(_: UISearchBar) {
        searchActive = true
        self.filterContentForSearchText(searchText: self.zoekwoord!, scopeIndex: self.selectedScope)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterKeyword = "mppnm"
        sortKeyword = "mppnm"
        hyrView = false
        //print("Cancel clicked")
        searchBar.showsScopeBar = false
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
        //print("should end editing")
        self.tableView.reloadData()
        return true
    }

    // MARK: - Zoekfilter
    func filterContentForSearchText(searchText: String, scopeIndex: Int) {
        let offset = CGPoint(x: 0, y: -188)
        var sortDescriptors: Array<NSSortDescriptor>?
        var predicate: NSPredicate?
        if scopeIndex == -1 {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || mp.mpnm \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText])
                let sub2 = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", searchText)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }

        } else if scopeIndex == 5 {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                format = ("mppnm \(zoekoperator)[c] %@ || vosnm_ \(zoekoperator)[c] %@")
                let sub1 = NSPredicate(format: format, argumentArray: [searchText, searchText])
                let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText)
                let sub3 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                let predicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: [sub1, sub2, sub3])
                let predicate2 = NSPredicate(format: "mp.ir.nirnm \(zoekoperator)[c] %@", searchText)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        } else if scopeIndex == 4 {
            //print("zoekwoord: ", self.zoekwoord!) /* nil */
            //print("toepassingszoekwoord: ", self.toepzoekwoord)
            //print("searchbar text: ", searchBar.text!)
            //print("searchText: ", searchText)
            if pickerChanged == false {
                if searchText.isEmpty == false {
                    let sub1 = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", self.toepzoekwoord)
                    let sub2 = NSPredicate(format: "mp.mpnm \(zoekoperator)[c] %@", searchText)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sub1, sub2])
                } else {
                    predicate = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", self.toepzoekwoord)
                }
                sortDescriptors = [NSSortDescriptor(key: "mp.mpnm", ascending: true)]
            } else {
                predicate = NSPredicate(format: "mp.hyr.hyr BEGINSWITH %@", searchText)
                sortDescriptors = [NSSortDescriptor(key: "mp.mpnm", ascending: true)]
                pickerChanged = false
            }
        } else {
            if searchText.isEmpty == true {
                predicate = NSPredicate(format: "mppnm \(zoekoperator)[c] %@", "AlotofMumboJumboblablabla")
            } else {
                predicate = NSPredicate(format: "\(filterKeyword) \(zoekoperator)[c] %@", searchText)
                sortDescriptors = [NSSortDescriptor(key: "\(sortKeyword)", ascending: true)]
            }
        }
        self.fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
            //print("fetching from mpp...")
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        if self.tableView.contentOffset == offset {
            self.tableView.reloadData()
            self.tableView.setContentOffset(offset, animated: false)
        } else {
            self.tableView.reloadData()
        }
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
            print("Segue: \(segue.identifier!)!")
        default:
            print("Segue: \(segue.identifier!)!")
            break
        }
    }

    // MARK: - View Methods
    private func setupView() {
        updateView()
    }

    fileprivate func updateView() {
        //print("Updating view...")
        tableView.isHidden = false
        var x:Int
        if let medicijnen = fetchedResultsController.fetchedObjects {
            
            x = medicijnen.count
            if x == 0 {
                gevondenItemsLabel.isHidden = false
                tableView.isHidden = false
                tableView.tableFooterView = UIView()
                if hyrView == false {
                    zoekenImage.isHidden = false
                } else {
                    zoekenImage.isHidden = true
                }
                self.view.bringSubview(toFront: self.zoekenImage)
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                gevondenItemsLabel.isHidden = false
                zoekenImage.isHidden = true
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            //print("ELSE")
            x = 0
            gevondenItemsLabel.isHidden = false
            zoekenImage.isHidden = false
            tableView.isHidden = true
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        self.tableView.reloadData()
        gevondenItemsLabel.text = "\(x)"
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("view did end decelerating")
        //print("offset: \(scrollView.contentOffset)")
        if (scrollView.contentOffset.y == 0.0) {  // TOP
            upArrow.isHidden = true
            let topOffset = CGPoint(x: 0, y: 0)
            let offset = CGPoint(x: 0, y: -188)
            if hyrView == true {
                tableView.setContentOffset(offset, animated: false)
            } else {
                tableView.setContentOffset(topOffset, animated: false)
            }
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
                //print("med saved in medicijnkast")
            } catch {
                print(error.localizedDescription)
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
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
                //print("med saved in aankooplijst")
            } catch {
                print("med not saved in aankooplijst!")
            }
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.curveEaseIn], animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.6).cgColor}, completion: {_ in UIView.animate(withDuration: 0.1, animations: {cell?.layer.backgroundColor = UIColor.green.withAlphaComponent(0.0).cgColor}) }
            )
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
        print("addUserData: \(mppcvValue), \(userkey), \(uservalue)")
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
        print("Copying localdata to Userdata")
        // Read UserDefaults array: from localdata, key: userdata
        print("Localdata: \(String(describing: localdata.array(forKey: "userdata")))")
        // Use UserDefaults array values to obtain dictionary data
        for userData in localdata.array(forKey: "userdata")! {
            print("userdata: \(userData)")
            let dict = localdata.dictionary(forKey: (userData as! String))
            print("Dict: \(dict!)")
            for (key, value) in dict! {
                if key == "medicijnkast" || key == "medicijnkastarchief" || key == "aankooplijst" || key == "aankooparchief" {
                    addUserData(mppcvValue: (userData as! String), userkey: key, uservalue: (value as! Bool), managedObjectContext: context)
                }
            }
        }
    }
}
