//
//  BestellingPlaatsenViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 27/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class BestellingPlaatsenViewController: UIViewController, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate {

    // MARK: - Properties Constants
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Properties Variables
    
    // MARK: - Referencing Outlets
    
    // MARK: - Referencing Actions
    @IBAction func exportToCSV(_ sender: AnyObject) {
        // Make mail composer controller and fill it with the proper information
        let mailComposeViewController = configuredMailComposeViewController()
        
        // If the composer is functioning properly ...
        if MFMailComposeViewController.canSendMail() {
            // ... Present the generated mail composer controller
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            // ... Otherwise, show why it is not working properly
            print("Could not compose mail")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bestelling plaatsen"
        // Do any additional setup after loading the view.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - fetchedResultsController
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Medicijn> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mpnm", ascending: true)]
        let predicate = NSPredicate(format: "aankoop == true")
        fetchRequest.predicate = predicate
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Outgoing mail
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        // Establish the controller from scratch
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        // Set preset information included in the email
        mailComposerVC.setSubject("Bestelling medicijnen")
        mailComposerVC.setMessageBody("Generic Email Body", isHTML: false)
        
        // Turn core data for responses into a .csv file
        
        // Pull core data in
        var aankoopResultsList = [NSManagedObject]()
        let fetchReq: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        let pred = NSPredicate(format: "aankoop == true")
        fetchReq.predicate = pred
        
        do {
            aankoopResultsList = try CoreDataStack.shared.persistentContainer.viewContext.fetch(fetchReq)
        } catch {
            print("Error in fetching objects.")
        }
        
        let csvString = writeCoreObjectsToCSV(objects: aankoopResultsList)
        let data = csvString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        mailComposerVC.addAttachmentData(data!, mimeType: "text/csv", fileName: "Bestelling.csv")
        
        return mailComposerVC
    }
    
    func writeCoreObjectsToCSV(objects: [NSManagedObject]) -> NSMutableString {
        // Maker sure there is data to export
        guard objects.count > 0 else { return "" }
        let mailString = NSMutableString()
        
        mailString.append("mpnm, mppcv, mppnm, stofnm")
        
        for object in objects {
            // Put "\n" at the beginning so you don't have an extra row at the end
            mailString.append("\n\(object.value(forKey: "mppcv")!),\(object.value(forKey: "mpnm")!), \(object.value(forKey: "stofnm")!)")
        }
        return mailString
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
