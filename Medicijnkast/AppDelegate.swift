//
//  AppDelegate.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData
import Foundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationBarAppearance = UINavigationBar.appearance()
        
        // Change tint and and bar tint
        navigationBarAppearance.tintColor = UIColor.black
        navigationBarAppearance.barTintColor = UIColor.white
        
        // Change navigation item title color
        let navbarfont = UIFont(name:"San Franciso", size: 21) ?? UIFont.systemFont(ofSize: 21)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black, NSFontAttributeName: navbarfont]
        
        let tabBarAppearance = UITabBar.appearance()
        // Change tint and bar tint
        tabBarAppearance.tintColor = UIColor.black.withAlphaComponent(1.0)
        tabBarAppearance.barTintColor = UIColor.white.withAlphaComponent(0.0)
        
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        
        // Helpers
        var list: NSManagedObject? = nil
        
        // Fetch List Records
        let lists = fetchRecordsForEntity("Medicijn", inManagedObjectContext: managedObjectContext)
        
        if let listRecord = lists.first {
            list = listRecord
        } else if let listRecord = createRecordForEntity("Medicijn", inManagedObjectContext: managedObjectContext) {
            list = listRecord
        }
        
        print("number of lists: \(lists.count)")
        print("--")
        
        if let list = list {
            print(list)
        } else {
            print("unable to fetch or create list")
        }
        
        do {
            // Save Managed Object Context
            try managedObjectContext.save()
        } catch {
            print("Unable to save managed object context")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    /* See CoreDataStack.swift */

    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        let coreData = UIApplication.shared.delegate as! CoreDataStack
        return coreData.persistentContainer.viewContext
    }
    
    // Obsolete - moved to KastViewController (progress bar)
    func saveAttributes(dict: [String:String]) {
        print("Saving attributes...")
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let entityMedicijn = NSEntityDescription.entity(forEntityName: "Medicijn", in: context)
        let newMedicijn = NSManagedObject(entity: entityMedicijn!, insertInto: context)
        
        for (key, value) in dict {
            //print("key: \(key) and value: \(value)")
            //print("\(type(of:value))")
            if value == "true" {
                //print("value is true")
                newMedicijn.setValue(1, forKey: key)
            } else if value == "false" {
                //print("value is false")
                newMedicijn.setValue(0, forKey: key)
            } else if value == "" {
                //print("value is empty")
                newMedicijn.setValue("", forKey: key)
            } else {
                //print("value is not boolean")
                newMedicijn.setValue(value, forKey: key)
            }
        }
        
        do {
            try context.save()
            //print("context saved")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    
    // MARK: - CSV Parsing
    func parseCSV2Dict (keys: [String], values: [[String]]) -> [Dictionary<String,String>] {
        print("CSV to dictionary")
        
        //print("keys ok: \(keys)")
        //print("values ok: \(values)")
        var items = [Dictionary<String,String>]()
        for v in values {
            var subd = [String:String]()
            for val in 0..<v.endIndex {
                //print("\(keys[val]) : \(v[val])")
                subd[keys[val]] = v[val]
            }
            items.append(subd)
        }
        //print("items: \(items)")
        return items
    }
    
    func parseCSV (contentsOf: NSURL, encoding: String.Encoding, error: NSErrorPointer) -> [(Array<String>,Array<Array<String>>)]? {
        // Load the CSV file and parse it
        
        print("Loading CSV file...")
        let delimiter = ";"
        //let content = "(contentsOf: contentsOf, encoding: encoding, error: error)"
        var keys = [String]()
        var lines = [String]()
        var items = [[String]]()
        do {
            lines = try String(contentsOf: contentsOf as URL, encoding: encoding).components(separatedBy: NSCharacterSet.newlines)
        } catch {
            print("Error reading line.")
        }

        for line in lines[0...0] {
            keys = line.components(separatedBy: ";")
        }
        
        for line in lines[1..<lines.endIndex] {
            var values:[String] = []
            //print("line: \(line)")
            if line != "" {
                // For a line with double quotes
                // we use NSScanner to perform the parsing
                if line.range(of: "\"") != nil {
                    var textToScan:String = line
                    var value:NSString?
                    var textScanner:Scanner = Scanner(string: textToScan)
                    while textScanner.string != "" {
                        
                        if (textScanner.string as NSString).substring(to: 1) == "\"" {
                            textScanner.scanLocation += 1
                            textScanner.scanUpTo("\"", into: &value)
                            textScanner.scanLocation += 1
                        } else {
                            textScanner.scanUpTo(delimiter, into: &value)
                        }
                        
                        // Store the value into the values array
                        
                        values.append(value as! String)
                        
                        // Retrieve the unscanned remainder of the string
                        if textScanner.scanLocation < textScanner.string.characters.count {
                            textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                        } else {
                            textToScan = ""
                        }
                        textScanner = Scanner(string: textToScan)
                    }
                    
                    // For a line without double quotes, we can simply separate the string
                    // by using the delimiter (e.g. comma)
                } else  {
                    values = line.components(separatedBy: delimiter)
                }
                // Put the values into a dictionary and add it to the items dictionary
                
                items.append(values)
                            
            }
        }
        return [(keys, items)]
    }

    // MARK: Preload all data from csv file
    func preloadData (_ entitynaam: String) -> [Dictionary<String,String>] {
        var items:[Dictionary<String,String>] = [[:]]
        print("Preloading data...")
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: entitynaam, in: context)
        
        // Retrieve data from the source file
        if let path = Bundle.main.path(forResource: "combinednoempties", ofType: "csv") {
        //let path =  "/users/pstragier/Documents/PWS/Medicijnkast/Medicijnkast/combinednoempties.csv"
            print("\(path)")
            let contentsOfURL = NSURL(fileURLWithPath: path)
            
            //let data = NSData(contentsOf: path)
            print("url found!: \(contentsOfURL)")
            //TODO: Update protocol needed without deleting all data first!!!
            cleanCoreDataMedicijn()
            var error:NSError?
            //parseCSV -> [Dictionary<String,String>]
            if let values = parseCSV(contentsOf: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                print("parsing data successful...")
                //item -> Dictionary<String,String>
                let keys = values[0].0
                let val = values[0].1
                items = parseCSV2Dict(keys: keys, values: val) /* items = list of dictionaries */
                                
            } else {
                print("Parsing of data failed")
            }
        } else {
            print("File not found!")
        }
        return items
    }
    
    // MARK: Remove all Data from DB before adding the parsed data.
    func cleanCoreDataMedicijn() {
        print("Cleaning core data...")
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Medicijn> = Medicijn.fetchRequest()
        //var predicate = NSPredicate(format: "merknaam contains[c] %@", "")
        
        //fetchRequest.predicate = predicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            print("deleting all contents...")
            try context.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Existing installation with existing data - check for updates
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
    
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
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
}

extension String {
    var doubleValue: Double? {
        return Double(self)
    }
    var floatValue: Float? {
        return Float(self)
    }
    var integerValue: Int? {
        return Int(self)
    }
    var stringValue: String? {
        return String(self)
    }
    var boolValue: Bool? {
        return Bool(self)
    }
}
