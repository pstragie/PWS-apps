//
//  MedicijnDetailViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 18/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import os.log

class MedicijnDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Fetch Medicijn
    weak var medicijn: MPP?
    weak var dataPassed: MPP?
    weak var stofdb: Stof?
    var H: Bool = true
    var noteView = UIView()
    var arrayPassed: Array<String> = []
    var stofnaamArr: Array<String> = []

    // MARK: - Button actions
    var kastRichting: Bool = false
    var lijstRichting: Bool = false
    
    @IBAction func kastWijzigen(_ sender: UIButton) {
        medicijn?.userdata?.setValue(true, forKey: "medicijnkast")
        let context = self.appDelegate.persistentContainer.viewContext
        AddMedicijnViewController().addUserData(mppcvValue: (medicijn?.mppcv!)!, userkey: "medicijnkast", uservalue: kastRichting, managedObjectContext: context)
        do {
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedKast"), object: nil)
//            print("med saved in aankooplijst")
        } catch {
            print("med not saved in aankooplijst!")
        }
        tableView.reloadData()
    }
    
    @IBAction func lijstWijzigen(_ sender: UIButton) {
        medicijn?.userdata?.setValue(true, forKey: "aankooplijst")
        let context = self.appDelegate.persistentContainer.viewContext
        AddMedicijnViewController().addUserData(mppcvValue: (medicijn?.mppcv!)!, userkey: "aankooplijst", uservalue: lijstRichting, managedObjectContext: context)
        do {
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedAankoop"), object: nil)
//            print("med saved in aankooplijst")
        } catch {
            print("med not saved in aankooplijst!")
        }
        tableView.reloadData()
    }

    @IBAction func noteView(_ sender: UIButton) {
        if self.noteView.isHidden == true {
            self.noteView.isHidden = false
        } else {
            self.noteView.isHidden = true
        }
    }
    
    func setupNoteView() {
//        print("setup note view")
        self.noteView.isHidden = true
        self.noteView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = (self.view.bounds.width)/2
        let height = (self.view.bounds.height)/2
        self.noteView=UIView(frame:CGRect(x: self.view.center.x-(width/2), y: self.view.center.y-(height/2), width: width, height: height))
        
        self.noteView.backgroundColor = UIColor.black.withAlphaComponent(0.99)
        self.noteView.layer.cornerRadius = 8
        self.noteView.layer.borderWidth = 2
        self.noteView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(noteView)
        self.noteView.isHidden = self.H		
        
        let closenote = UIButton()
        closenote.setTitle("Sluiten", for: .normal)
        closenote.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closenote.setTitleColor(.white, for: .normal)
        closenote.setTitleColor(.red, for: .highlighted)
        closenote.layer.cornerRadius = 8
        closenote.layer.borderWidth = 2
        closenote.layer.borderColor = UIColor.gray.cgColor
        closenote.showsTouchWhenHighlighted = true
        closenote.translatesAutoresizingMaskIntoConstraints = false
        closenote.addTarget(self, action: #selector(closeNoteAction), for: .touchUpInside)
        closenote.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let labelnote = UILabel()
        labelnote.text = medicijn?.note
        labelnote.font = UIFont.boldSystemFont(ofSize: 17)
        labelnote.textColor = UIColor.white
        labelnote.translatesAutoresizingMaskIntoConstraints = false
        labelnote.lineBreakMode = .byWordWrapping
        labelnote.numberOfLines = 10
        
        let vertStack = UIStackView(arrangedSubviews: [closenote, labelnote])
        vertStack.axis = .vertical
        vertStack.distribution = .fill
        vertStack.alignment = .fill
        vertStack.spacing = 10
        vertStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.noteView.addSubview(vertStack)
        
        //Stackview Layout (constraints)
        vertStack.leftAnchor.constraint(equalTo: noteView.leftAnchor, constant: 20).isActive = true
        vertStack.topAnchor.constraint(equalTo: noteView.topAnchor, constant: 20).isActive = true
        vertStack.rightAnchor.constraint(equalTo: noteView.rightAnchor, constant: -20).isActive = true
        vertStack.heightAnchor.constraint(equalTo: noteView.heightAnchor, constant: -20).isActive = true
    }
    
    func closeNoteAction(sender: UIButton!) {
        if self.noteView.isHidden == true {
            self.noteView.isHidden = false
        } else {
            self.noteView.isHidden = true
        }
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("View did load!")
        navigationItem.title = "Info: \((medicijn?.mp?.mpnm)!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        dataPassed = medicijn
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        print("View did appear, arrayPassed: \(stofnaamArr)")
        arrayPassed = stofnaamArr
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("View did layout subviews")
        scrollToTop()
        setupNoteView()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if self.noteView.isHidden == false {
            self.H = false
        } else {
            self.H = true
        }
        setupNoteView()
    }
    
    
    // MARK: - Scrolling behaviour
    func scrollToTop() {
//        print("Scroll to top button clicked")
        let topOffset = CGPoint(x: 0, y: 0)
        tableView.setContentOffset(topOffset, animated: true)
    }

    // MARK: - share button
    func shareTapped() {
        
        // Image (screenshot version)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imagesToShare = [AnyObject]()
        imagesToShare.append(image!)
        
        let vc = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        vc.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.postToFlickr, UIActivityType.postToTencentWeibo ]
        present(vc, animated: false, completion: nil)
    }

    // This variable will hold the data being passed from the Source View Controller
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnDetailViewCell.reuseIdentifier, for: indexPath) as? MedicijnDetailViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        // Configure Cell
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = false
        cell.layer.borderWidth = 1
        
        // Stack top
        cell.mpnm.text = medicijn?.mp?.mpnm
        cell.mppnm.text = medicijn?.mppnm
        
        // Stack middle Center
        cell.vosnm.setTitle(medicijn?.vosnm_, for: .normal)
        cell.irnm.setTitle(medicijn?.mp?.ir?.nirnm, for: .normal)
        let toepassing = Dictionaries().hierarchy(hyr: (medicijn?.mp?.hyr?.hyr)!)
        cell.ti.setTitle(toepassing, for: .normal)
        //let stofcv = medicijn?.sam?.value(forKey: "stofcv") as! NSSet /* (AnyObject) __NSSetI */
        //let stofcvArr = Array(stofcv)
        //var stofcvString: String = ""
        //for stof in stofcvArr {
        //    stofcvString += stof as! String+" "
        //}
        let samsam = medicijn?.sam?.value(forKey: "stof")
        let stofnaam = (samsam! as AnyObject).value(forKey: "ninnm") as! NSSet
        
        for s in stofnaam {
            stofnaamArr.append(s as! String)
        }
        //var stofnaamString: String = ""
        if stofnaamArr.count == 1 {
            cell.stofnm1.setTitle(stofnaamArr[0], for: .normal)
            cell.stofnm2.isHidden = true
            cell.stofnm3.isHidden = true
            cell.stofnm4.isHidden = true
            cell.stofnm5.isHidden = true
        }
        if stofnaamArr.count == 2 {
            cell.stofnm1.setTitle(stofnaamArr[0], for: .normal)
            cell.stofnm2.setTitle(stofnaamArr[1], for: .normal)
            cell.stofnm3.isHidden = true
            cell.stofnm4.isHidden = true
            cell.stofnm5.isHidden = true
        }
        if stofnaamArr.count == 3 {
            cell.stofnm1.setTitle(stofnaamArr[0], for: .normal)
            cell.stofnm2.setTitle(stofnaamArr[1], for: .normal)
            cell.stofnm3.setTitle(stofnaamArr[2], for: .normal)
            cell.stofnm4.isHidden = true
            cell.stofnm5.isHidden = true
        }
        if stofnaamArr.count == 4 {
            cell.stofnm1.setTitle(stofnaamArr[0], for: .normal)
            cell.stofnm2.setTitle(stofnaamArr[1], for: .normal)
            cell.stofnm3.setTitle(stofnaamArr[2], for: .normal)
            cell.stofnm4.setTitle(stofnaamArr[3], for: .normal)
            cell.stofnm5.isHidden = true
        }
        if stofnaamArr.count >= 5 {
            cell.stofnm1.setTitle(stofnaamArr[0], for: .normal)
            cell.stofnm2.setTitle(stofnaamArr[1], for: .normal)
            cell.stofnm3.setTitle(stofnaamArr[2], for: .normal)
            cell.stofnm4.setTitle(stofnaamArr[3], for: .normal)
            cell.stofnm5.setTitle(stofnaamArr[4], for: .normal)
        }
        
        cell.galnm.text = medicijn?.gal?.ngalnm

        // Stack middle left
        // Stack Bottom left
        cell.pupr.text = "\((medicijn?.pupr)!) €"
        cell.rema.text = "\((medicijn?.rema)!) €"
        cell.remw.text = "\((medicijn?.remw)!) €"
        cell.index.text = "\((medicijn?.index)!) cent"
        if (medicijn?.law) == "R" {
            cell.law.text = "Ja"
        } else {
            cell.law.text = "Nee"
        }
        cell.ssecr.text = Dictionaries().ssecr(ssecr: (medicijn?.ssecr)!)
//        print((medicijn?.mp?.wadan)!)
        cell.wadan.text = Dictionaries().wada(wada: (medicijn?.mp?.wadan)!)
        if medicijn?.use == "H" {
            cell.use.text = "Hospitaal"
        } else {
            cell.use.text = "Algemeen"
        }
        if (medicijn?.ouc == "O") {
            cell.ouc.text = "Mono-ingrediënt"
        } else if (medicijn?.ouc == "U") {
            cell.ouc.text = "Multi-ingrediënt"
        } else if (medicijn?.ouc == "C") {
            cell.ouc.text = "Gecombineerd multi-ingrediënt"
        }
        if (medicijn?.ogc == "G") {
            cell.ogc.text = "Verpakking zonder supplement voor de patiënt en in categorie goedkoop."
        } else if (medicijn?.ogc == "B") {
            cell.ogc.text = "Verpakking zonder supplement voor de patiënt maar niet in categorie goedkoop."
        } else if (medicijn?.ogc == "R") {
            cell.ogc.text = "Verpakking met supplement voor de patiënt en niet in categorie goedkoop."
        } else {
            cell.ogc.text = "Geen terugbetaling door RIZIV."
        }

        // Stack Bottom right
        if (medicijn?.cheapest)! {
            cell.cheapest.text = "Ja"
        } else {
            cell.cheapest.text = "Nee"
        }
        if (medicijn?.gdkp)! {
            cell.gdkp.text = "Ja"
        } else {
            cell.gdkp.text = "Nee"
        }
        if (medicijn?.bt)! {
            cell.bt.text = "Ja"
        } else {
            cell.bt.text = "Nee"
        }
        if (medicijn?.mp?.orphan)! {
            cell.orphan.text = "Ja"
        } else {
            cell.orphan.text = "Nee"
        }
        if (medicijn?.narcotic)! {
            cell.narcotic.text = "Ja"
        } else {
            cell.narcotic.text = "Nee"
        }
        if (medicijn?.specrules)! {
            cell.specrules.text = "Ja"
        } else {
            cell.specrules.text = "Nee"
        }
        
        // Stack End Left
        cell.kast.text = "In medicijnkast"
        cell.aankoop.text = "In aankooplijst"
        if medicijn?.userdata == nil || medicijn?.userdata?.medicijnkast == false {
            cell.kastimage.image = #imageLiteral(resourceName: "kruisje")
            cell.kastWijzigen.setTitle("+", for: .normal)
            cell.kastWijzigen.setTitleColor(UIColor.green, for: .normal)
            cell.kastWijzigen.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            kastRichting = true
        } else {
            cell.kastimage.image = #imageLiteral(resourceName: "vinkje")
            cell.kastWijzigen.setTitle("-", for: .normal)
            cell.kastWijzigen.setTitleColor(UIColor.red, for: .normal)
            cell.kastWijzigen.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            kastRichting = false
        }
        if medicijn?.userdata == nil || medicijn?.userdata?.aankooplijst == false {
            cell.aankoopimage.image = #imageLiteral(resourceName: "kruisje")
            cell.lijstWijzigen.setTitle("+", for: .normal)
            cell.lijstWijzigen.setTitleColor(UIColor.green, for: .normal)
            cell.lijstWijzigen.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            lijstRichting = true
        } else {
            cell.aankoopimage.image = #imageLiteral(resourceName: "vinkje")
            cell.lijstWijzigen.setTitle("-", for: .normal)
            cell.lijstWijzigen.setTitleColor(UIColor.red, for: .normal)
            cell.lijstWijzigen.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            lijstRichting = false
        }
        
        cell.moreButton.layer.cornerRadius = 3
        cell.moreButton.layer.borderWidth = 3
        cell.moreButton.layer.borderColor = UIColor.white.cgColor
        
        cell.noteButton.layer.cornerRadius = 3
        cell.noteButton.layer.masksToBounds = false
        cell.noteButton.layer.borderWidth = 3
        cell.noteButton.layer.borderColor = UIColor.white.cgColor
        if medicijn?.note != "_" {
            cell.noteButton.isHidden = false
            cell.noteButton.layer.backgroundColor = UIColor.green.cgColor

        } else {
            cell.noteButton.isHidden = true
        }
        
        // Footer
        if medicijn?.lastupdate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            let timeString = dateFormatter.string(from: (medicijn?.lastupdate)! as Date)
            cell.updatedAt.text = timeString
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            let timeString = dateFormatter.string(from: (medicijn?.createdAt)! as Date)
            cell.updatedAt.text = timeString
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.layer.cornerRadius = 3
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height - 80
    }
    
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    // MARK: - Navigation
    let pvt = "pvtToWeb"
    let mpg = "mpgToWeb"
    let ti = "tiToKlachten"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case pvt:
            let destination = segue.destination as! BCFIWebViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
            let selectedLink = medicijn?.ggr_link?.link2pvt
            destination.link = selectedLink
        case mpg:
            let destination = segue.destination as! BCFIWebViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
            let selectedLink = medicijn?.ggr_link?.link2mpg
            destination.link = selectedLink
        case ti:
            let destination = segue.destination as! KlachtenViewController
            let selectedObject = medicijn
            destination.medicijn = selectedObject
        default:
//            print("Segue: \(String(describing: segue.identifier!))")
            break
        }
    }
}
