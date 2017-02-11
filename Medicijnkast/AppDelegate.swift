//
//  AppDelegate.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 08/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Medicijnkast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
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
    
    // MARK: - CSV Parsing
    func parseCSV (contentsOf: NSURL, encoding: String.Encoding, error: NSErrorPointer) -> [(merknaam:String, stofnaam:String, boximage:NSData, kast:Bool)]? {
        // Load the CSV file and parse it
        print("Loading CSV file...")
        let delimiter = ";"
        var items:[(merknaam:String, stofnaam:String, boximage:NSData, kast:Bool)]?
        //let content = "(contentsOf: contentsOf, encoding: encoding, error: error)"
        var lines:[String] = []
        items = []
        do {
            lines = try String(contentsOf: contentsOf as URL, encoding: encoding).components(separatedBy: NSCharacterSet.newlines)
        } catch {
            print("Error reading line.")
        }
        for line in lines {
            //print("line: \(line)")
            var values:[String] = []
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
                // Put the values into the tuple and add it to the items array
                
                guard let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "Pill-box-sample"), 0.5) as NSData? else {
                    print("failed to convert JPEG to data")
                    break
                }
                let item = (merknaam: values[6], stofnaam: values[32], boximage: imageData, kast: false)
                items?.append(item)
            }
            
        }
        return items
    }
    
    // MARK: Preload all data from csv file
    func preloadData () {
        print("Preloading data...")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Medicijn", in: context)
        
        // Retrieve data from the source file
        if let path =  Bundle.main.path(forResource: "MPP_short", ofType: "csv") {
            print("path")
            let contentsOfURL = NSURL(fileURLWithPath: path)
            //let data = NSData(contentsOf: path)
            print("url found!: \(contentsOfURL)")
            // Remove all the menu items before preloading
            cleanCoreData()
            
            var error:NSError?
            if let items = parseCSV(contentsOf: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                print("parsing successful.")
                for item in items {
                    let medItem = NSManagedObject(entity: entity!, insertInto: context)
                        medItem.setValue(item.merknaam, forKey: "merknaam")
                        medItem.setValue(item.stofnaam, forKey: "stofnaam")
                        medItem.setValue(false, forKey: "kast")
                    //print("medItem: \(medItem)")
                    do {
                        try context.save()
                        print("saved!")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            print("path not found")
        }
    }
    
    // MARK: Remove all Data from DB before adding the parsed data.
    func cleanCoreData () {
        print("Cleaning core data...")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
}

