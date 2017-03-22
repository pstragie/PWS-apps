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
    let wadadict: Dictionary<String,String> = ["A":"Anabolica, ten allen tijde verboden", "B":"Beta-blokkers, verboden bij bepaalde concentratiesporten binnen wedstrijdverband en ten alle tijde verboden bij (boog)schieten.", "B2":"Alle beta2-mimetica zijn verboden, behalve salbutamol, salmeterol en formoterol die via inhalatie en in overeenkomstig met het therapeutisch regime, worden gebruikt.", "C":"Corticosteroïden, verboden binnen wedstrijdverband behalve bij nasaal of dermatologisch gebruik of via inhalatie.", "c": "Opgelet. Corticosteroïden (nasaal, dermatologisch, inhalatie). Geen TTN (toestemming tot therapeutische noodzaak) vereist maar gebruik ervan te melden aan de controlearts.", "D":"Diuretica, ten allen tijde verboden", "d":"Opgelet. Bevat codeïne of ethylmorfine. Geen formulier toestemming tot therapeutische noodzaak vereist, maar gebruik ervan te melden aan de controlearts.", "DB":"Bevat diuretica, ten allen tijde verboden.", "Hman":"Ten allen tijde verboden voor mannelijke atleten.", "H":"Ten allen tijde verboden.", "M":"Maskerende middelen, ten allen tijde verboden.", "N":"Narcotica, verboden binnen wedstrijdverband.", "O":"Anti-oestrogene middelen, ten allen tijde verboden.", "AO":"Anti-oestrogene middelen, ten allen tijde verboden.", "P":"Opgelet! Kan mogelijk aanleiding geven tot een afwijkend analyseresultaat voor cathine. Geen 'toestemming tot therapeutische noodzaak' vereist, maar gebruik ervan te melden aan de controlearts.", "S":"Stimulantia, verboden binnen wedstrijdverband.", "s":"Opgelet! Bevat stimulantia en kan mogelijk aanleiding geven tot een positieve dopingtest. Geen 'toestemming tot therapeutische noodzaak' vereist, maar gebruik ervan te melden aan de controlearts.", "_":"Niet op de dopinglijst."]
    let ssecrdict: Dictionary<String,String> = ["a":"categorie a", "b":"categorie b", "c":"categorie c", "cx":"categorie cx", "cs":"categorie cs", "b2":"b2: a priori controle", "c2":"c2: a priori controle", "a4":"a4: a posteriori controle", "b4":"b4: a posteriori controle", "c4":"c4: a posteriori controle", "s4":"s4: a posteriori controle", "h": "h: enkel terugbetaling in hospitaalgebruik", "J":"J: speciale toelage door RIZIV voor vrouwen < 21j.", "aJ":"aJ: gratis voor vrouwen < 21j.", "Chr":"Chr: speciale toelage door RIZIV voor chronische pijn.", "_":"geen"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load!")
        navigationItem.title = "Info: \((medicijn?.mp?.mpnm)!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        dataPassed = medicijn
    }

    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
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
        
        let stofcv = medicijn?.sam?.value(forKey: "stofcv") as! NSSet /* (AnyObject) __NSSetI */
        let stofcvArr = Array(stofcv)
        
        
        var stofcvString: String = ""
        for stof in stofcvArr {
            stofcvString += stof as! String+" "
        }
        let samsam = medicijn?.sam?.value(forKey: "stof")
        let stofnaam = (samsam! as AnyObject).value(forKey: "ninnm") as! NSSet
        let stofnaamArr = Array(stofnaam)
        var stofnaamString: String = ""
        for stofn in stofnaamArr {
            stofnaamString += stofn as! String + " "
        }
        
        cell.stofnm.setTitle(stofnaamString, for: .normal)
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
        cell.ssecr.text = ssecrdict[(medicijn?.ssecr)!]
        print((medicijn?.mp?.wadan)!)
        cell.wadan.text = wadadict[(medicijn?.mp?.wadan)!]
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
            let timeString = dateFormatter.string(from: medicijn?.lastupdate as! Date)
            cell.updatedAt.text = timeString
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            let timeString = dateFormatter.string(from: medicijn?.createdAt as! Date)
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
        default:
            print("Unknown segue: \(segue.identifier)")
        }
        
    }
    
    
}
