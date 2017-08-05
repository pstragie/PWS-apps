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
    var arrayPassed: Array<String> = []
    var stofnaamArr: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("View did load!")
        navigationItem.title = "Info: \((medicijn?.mp?.mpnm)!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        dataPassed = medicijn
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //print("View did appear, arrayPassed: \(stofnaamArr)")
        arrayPassed = stofnaamArr
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToTop()
    }
    
    func scrollToTop() {
        //print("Scroll to top button clicked")
        let topOffset = CGPoint(x: 0, y: 0)
        tableView.setContentOffset(topOffset, animated: true)
    }

    // MARK: - share button
    func shareTapped() {
        /* // Text Version
        // text to share
        var text = ""
        // fetch medicijn op pagina
        let med = medicijn!
        let toepassing = Dictionaries().hierarchy(hyr: (med.mp?.hyr?.hyr)!)
        text += "Product: \(med.mp!.mpnm!) \nVerpakking: \(med.mppnm!) \nVOS: \(med.vosnm_!) \nFirma: \(med.mp!.ir!.nirnm!) \nToepassing: \(toepassing) \nPrijs: \(med.pupr!) €\nRemgeld A: \(med.rema!) €\nRemgeld W: \(med.remw!) €\nIndex \(med.index!) c€\n"
        */
        // TODO: add more details
        
        // set up activity view controller
        //let textToShare = [ text ]
        //let vc = UIActivityViewController(activityItems: textToShare, applicationActivities: [])
 
        
        // Image (screenshot version)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imagesToShare = [AnyObject]()
        imagesToShare.append(image!)
        
        let vc = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: false, completion: nil)
    }

    // This variable will hold the data being passed from the Source View Controller
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedicijnDetailViewCell.reuseIdentifier, for: indexPath) as? MedicijnDetailViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        // Configure Cell
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
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
        //print((medicijn?.mp?.wadan)!)
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
        } else {
            cell.kastimage.image = #imageLiteral(resourceName: "vinkje")
        }
        if medicijn?.userdata == nil || medicijn?.userdata?.aankooplijst == false {
            cell.aankoopimage.image = #imageLiteral(resourceName: "kruisje")
        } else {
            cell.aankoopimage.image = #imageLiteral(resourceName: "vinkje")
        }
        
        cell.noteButton.layer.cornerRadius = 3
        cell.noteButton.layer.masksToBounds = true
        cell.noteButton.layer.borderWidth = 1
        if medicijn?.note != "_" {
            cell.noteButton.layer.borderColor = UIColor.black.cgColor
            cell.noteButton.layer.backgroundColor = UIColor.green.cgColor

        } else {
            cell.noteButton.layer.borderColor = UIColor.gray.cgColor
            cell.noteButton.layer.backgroundColor = UIColor.gray.cgColor
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
            print("Unknown segue: \(String(describing: segue.identifier))")
        }
    }
}
