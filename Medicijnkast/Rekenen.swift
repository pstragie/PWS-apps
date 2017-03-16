//
//  Rekenen.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 23/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData 

class Rekenen {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    /*
    fileprivate lazy var fR: NSFetchedResultsController<MPP> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<MPP> = MPP()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mpnm", ascending: true)]
        let predicate = NSPredicate(format: "aankoop == true")
        fetchRequest.predicate = predicate
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        
        return fetchedResultsController
    }()
    */
    func TotalePrijs(_ fetchedResultsController: NSFetchedResultsController<MPP>) -> Dictionary<String,Double> {
        var totaleprijs:Dictionary<String,Double> = [:]
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        guard let medicijnen = fetchedResultsController.fetchedObjects else { return ["pupr":0.0, "rema":0.0, "remw":0.0] }
        for med in medicijnen {
            totaleprijs["pupr"] = (med.pupr?.doubleValue)!
            totaleprijs["rema"] = (med.rema?.doubleValue)!
            totaleprijs["remw"] = (med.remw?.doubleValue)!
        }
        return totaleprijs
    }

    func fetchCheapest(_ fetchedResultsController: NSFetchedResultsController<MPP>, categorie: String) -> Dictionary<String, Dictionary<String,Double>> {
        
        // fetch alle medicijnen in aankooplijst (aankoop == true)
        guard let medicijnen = fetchedResultsController.fetchedObjects else { return ["vosnaam":["mppnm":0.0]] as Dictionary<String, Dictionary<String,Double>> }
        var vosarray:Array<String> = []
        for med in medicijnen {
            // vosnaam opvragen
            vosarray.append(med.vosnm_!)
        }
        
        // alle medicijnen opvragen
        // voor elke stofnaam het goedkoopste alternatief zoeken (cheapest true of zelf berekenen?)
        var resultaat:Array<MPP> = []
        var vosdict: Dictionary<String,Dictionary<String,Double>> = [:]
        
        for vos in vosarray {
            let fetchReq: NSFetchRequest<MPP> = MPP.fetchRequest()
            let predicate = NSPredicate(format: "vosnm_ == %@", vos)
            fetchReq.predicate = predicate
            do {
                resultaat = try self.appDelegate.persistentContainer.viewContext.fetch(fetchReq)
                print("aantal matches: \(resultaat.count)")
            } catch {
                print("fetching error in calculateCheapestPrice")
            }
        
            // Steek merknaam en prijscategorie (pupr, rema of remw) in dictionary
            var prijsdict:Dictionary<Double, String> = [:]
            for med in resultaat {
                if categorie == "pupr" {
                    prijsdict[med.pupr!.doubleValue!] = med.mp?.mpnm!
                }
                if categorie == "rema" {
                    prijsdict[med.rema!.doubleValue!] = med.mp?.mpnm!
                }
                if categorie == "remw" {
                    prijsdict[med.remw!.doubleValue!] = med.mp?.mpnm!
                }
            }
        
            // Pik er het medicijn met de laagste prijs uit
            let minprijs = prijsdict.keys.min()
            let minprijsMerknaam = prijsdict[minprijs!]
        
            vosdict[vos] = [minprijsMerknaam!:minprijs!]
        }
        return vosdict
    }
        
    func berekenGoedkoopsteAlternatief(vosdict: Dictionary<String, Dictionary<String,Double>>, categorie: String) -> Double {
        // Bereken totaal
        var totaalprijs:Double = 0.0
        for (_, value) in vosdict {  /* key = vosnm_, value = dict(merknaam, prijs) */
            for (_, v) in value {
                totaalprijs += v
            }
        }
        return totaalprijs
    }
    
    func alternatieven(vosdict: Dictionary<String, Dictionary<String,Double>>, categorie: String) -> Dictionary<String,Array<String>> {
        // Bereken totaal
        var lijstalternatieven:Dictionary<String,Array<String>> = [:]
        
        for (key, value) in vosdict {  /* key = vosnm_, value = dict(merknaam, prijs) */
            lijstalternatieven[key] = Array(value.keys)
        }
        return lijstalternatieven
    }
    func berekenVerschil(categorie: String, huidig:Dictionary<String,Double>, altern: Double) -> Double {
        let prijsverschil = huidig[categorie]! - altern
        
        return prijsverschil
    }
}
