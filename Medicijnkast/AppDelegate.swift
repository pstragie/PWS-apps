//
//  AppDelegate.swift
//  Medicijnkast: MedCabinetFree Franstalig
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
    //let AddMed = AddMedicijnViewController()
    let localdata = UserDefaults.standard
    //let coreDataManager = CoreDataManager(modelName: "Medicijnkast")
    var errorHandler: (Error) -> Void = {_ in }

    // MARK: - DidFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        print("NSHomeDir: \(NSHomeDirectory())")
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
        tabBarAppearance.barTintColor = UIColor.white.withAlphaComponent(0.8)
        
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.tintColor = UIColor.white
        //searchBarAppearance.barTintColor = UIColor.red
        
        // MARK: Check current version
        let defaults = UserDefaults.standard
        let cAV = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        // MARK: preloaDBData of three database files included in the app
        // For distribution purposes!
        // Unmark simultaneously with marking the seedPersistentDatabase function to import csv!
        
        preloadDBData()
        
        guard let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let previousVersion = defaults.string(forKey: "appVersion") else {
            // Key does not exist in UserDefaults, must be a fresh install
//            print("Fresh install")
            // Writing version to UserDefaults for the first time
            defaults.set(cAV, forKey: "appVersion")
            
            
            
            // Override point for customization after application launch.
            
            // MARK: Load from CSV, for update of bcfi database!
            // Developer use only! Load persistent store with data from csv files.
            // Step 0: Delete the database files (3) in the "Medicijnkast" folder (on the left and in Finder
            // Step 0b: Mark the preloadDBData() function above
            // Step 0c: Delete the app from the simulator
            // Step 1a: Unmark the two following lines of code below the steps
            // Step 1b: Run the app (10 minutes or more to read and load all the files)
            // Step 2: Locate the database files (3)
            // Step 3a: Copy the database files (3) from the "NSHomeDir" folder
            // Step 4: Mark the two following lines of code
            // Step 5: Unmark the preloaDBData function above!
            
//            let moc = persistentContainer.viewContext
//            seedPersistentStoreWithManagedObjectContext(moc)

            
            // Print local file directory
//            let fm = FileManager.default
//            let appdir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            print(appdir)
            
            // Save Managed Object Context
            self.saveContext()
            
            
            
            return false
        }
        
        let comparisonResult = currentAppVersion.compare(previousVersion, options: .numeric, range: nil, locale: nil)
        switch comparisonResult {
        case .orderedSame:
//            print("Same version is running like before")
            break
        case .orderedAscending:
//            print("Earlier version is running")
            break
        case .orderedDescending:
//            print("older version is running")
            break
        }
        
        // Updating new version to UserDefaults
        defaults.set(currentAppVersion, forKey: "appVersion")
        
        // Save Managed Object Context
        self.saveContext()
        
        return true
    }
    // MARK: - Application behaviour
    // MARK: didUpdate userActivity
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("App did update!")
        // Copy Userdefaults to Userdata entity
        for mppcv in localdata.array(forKey: "userdata")! {
            print("mppcv: ", mppcv)
            let meddict = localdata.dictionary(forKey: mppcv as! String)
            print("meddict: ", meddict!)
        }
        // Check if medicine is still present in database
        AddMedicijnViewController().copyUserDefaultsToUserData(managedObjectContext: persistentContainer.viewContext)
    }

    
    // MARK: applicationWillResignActive
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    // MARK: applicationDidEnterBackground
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        self.saveContext()
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //print(UserDefaults.standard.value(forKey: "last_update")!)
        // Get file last save date of creation date
        //checkForUpdates()
    }

    // MARK: applicationWillEnterForeground
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    // MARK: applicationDidBecomeActive
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    // MARK: applicationWillTerminate
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - seedPersistentStoreWithManagedObjectContext
    // CSV load version: obsolete!
    func seedPersistentStoreWithManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) {
        if seedCoreDataContainerIfFirstLaunch() {
            //destroyPersistentStore()
            print("First Launch!!!")
            let Entities = ["MPP", "MP", "Hyr", "Gal", "Ggr_Link", "Sam", "Stof", "Ir"]
            //let Entities = ["MPP", "MP"]
            for entitynaam in Entities {
                //cleanCoreData(entitynaam: entitynaam)
                print(entitynaam)
                loadAllAttributes(entitynaam: entitynaam)
            }
        } else {
            print("Not the first launch!!!")
            // Check for updates
            /* let Entities = ["MPP"]
             for entitynaam in Entities {
             updateAllAttributes(entitynaam: entitynaam)
             } */
        }

    }
    
    // MARK: - preloadDBData Core Data stack
    func preloadDBData() {
//        print("Preloading DB...")
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Medicijnkast.sqlite") {
//            print("Files do not exist!")
            let sourceSqliteURLs = [URL(fileURLWithPath: Bundle.main.path(forResource: "Medicijnkast", ofType: "sqlite")!), URL(fileURLWithPath: Bundle.main.path(forResource: "Medicijnkast", ofType: "sqlite-wal")!), URL(fileURLWithPath: Bundle.main.path(forResource: "Medicijnkast", ofType: "sqlite-shm")!)]
            let destSqliteURLs = [URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Medicijnkast.sqlite"), URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Medicijnkast.sqlite-wal"), URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Medicijnkast.sqlite-shm")]
            
            for index in 0 ..< sourceSqliteURLs.count {
                do {
                    try fileManager.copyItem(at: sourceSqliteURLs[index], to: destSqliteURLs[index])
//                    print("Files Copied!")
                } catch {
                    fatalError("Could not copy sqlite to destination.")
                }
            }
            // MARK: Print UserDefaults
            /*print("localdata: ", localdata)
            for (key, value) in localdata.dictionaryRepresentation() {
                print("\(key) = \(value) \n")
            }*/
        } else {
//            print("Files Exist!")
            
            //print("Stored Userdefaults: \(localdata)")
            /*for (key, value) in localdata.dictionaryRepresentation() {
                print("\(key) = \(value) \n")
            }*/

        }
    }
    
    // MARK: - persistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
//        print("Loading persistentContainer")
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
                NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
                self.errorHandler(error)
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved CoreData error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Optional
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.viewContext.perform {
            block(self.persistentContainer.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Check for first launc
    func seedCoreDataContainerIfFirstLaunch() -> Bool {
        //1
        let previouslyLaunched = UserDefaults.standard.bool(forKey: "previouslyLaunched")
        if !previouslyLaunched {
            UserDefaults.standard.set(true, forKey: "previouslyLaunched")
            return true
            
        } else {
            
            return false
        }
    }


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
    
    func loadAllAttributes(entitynaam: String) {
        print("loading attributes...")
        let items = preloadData(entitynaam: entitynaam)
        var readLines: Float = 0.0
        var progressie: Float = 0.0
        let totalLines = Float(items.count)
        for item in items {
            readLines += 1
            progressie = readLines/totalLines
            print("progressie: \(progressie)")
//            print("saveAttributes: \(entitynaam), \(dict)")
            var newdict: Dictionary<String,Any> = [:]
            for (key, value) in item {
                var val: Any?
                let key = key.replacingOccurrences(of: "\"", with: "")
                if value == "true" {
                    val = 1
                } else if value == "false" {
                    val = 0
                } else if value == "" {
                    val = "empty"
                } else if key == "index" {
                    
                    if (value.floatValue != nil) {
                    val = Float(value)
                    }
                } else {
                    val = value
                }
                newdict[key] = val
            }

            self.saveAttributes(entitynaam: entitynaam, dict: newdict)
        }
    }
    
    
    // MARK: - createRecordForEntity
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
    
    // MARK: - fetchRecordsForEntity
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
    
    // MARK: - saveAttributes
    func saveAttributes(entitynaam: String, dict: [String:Any]) {
        let managedObjectContext = persistentContainer.viewContext
        print("saving attributes...")
        
        if entitynaam == "MPP" {
            if let newMPP = createRecordForEntity("MPP", inManagedObjectContext: managedObjectContext) {
                for (key, value) in dict {
                    newMPP.setValue(value, forKey: key)
                }
                newMPP.setValue(Date(), forKey: "createdAt")
            }
        }
        
        if entitynaam == "Sam" {
            if let newSam = createRecordForEntity("Sam", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "mppcv" {
                        recordKey = (value as? String)!
                    }
                    newSam.setValue(value, forKey: key)
                }
                let mpps = fetchRecordsForEntity("MPP", key: "mppcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                //let newMPP = mpp?.mutableSetValue(forKey: "sam")
                newSam.setValue(Date(), forKey: "createdAt")
                // Set Relationship
                for mpp in mpps {
                    newSam.setValue(mpp, forKey: "mpp")
                }
                // Add item to items
                //newMPP?.add(newSam)
            }
        }
        
        if entitynaam == "MP" {
            if let newMP = createRecordForEntity("MP", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "mpcv" {
                        recordKey = (value as? String)!
                    }
                    newMP.setValue(value, forKey: key)
                }
                
                let mpps = fetchRecordsForEntity("MPP", key: "mpcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newMP.setValue(Date(), forKey: "createdAt")
                for mpp in mpps {
                    mpp.setValue(newMP, forKeyPath: "mp")
                }
            }
        }
        
        if entitynaam == "Gal" {
            //cleanCoreData(entitynaam: "Gal")
            if let newGal = createRecordForEntity("Gal", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "galcv" {
                        recordKey = (value as? String)!
                        print(value)
                    }
                    newGal.setValue(value, forKey: key)
                }
                
                let mpps = fetchRecordsForEntity("MPP", key: "galcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newGal.setValue(Date(), forKey: "createdAt")
                // Set Relationship
                for mpp in mpps {
                    mpp.setValue(newGal, forKeyPath: "gal")
                }
            }
        }

        if entitynaam == "Hyr" {
            if let newHyr = createRecordForEntity("Hyr", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "hyrcv" {
                        recordKey = (value as? String)!
                    }
                    newHyr.setValue(value, forKey: key)
                }
                
                let mps = fetchRecordsForEntity("MP", key: "hyrcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newHyr.setValue(Date(), forKey: "createdAt")
                // Set Relationship
                //newHyr.setValue(NSSet(object: mpp!), forKey: "mp")
                // Add item to items
                for mp in mps {
                    mp.setValue(newHyr, forKeyPath: "hyr")
                }
            }
        }
        if entitynaam == "Ir" {
            if let newIr = createRecordForEntity("Ir", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "ircv" {
                        recordKey = (value as? String)!
                    }
                    newIr.setValue(value, forKey: key)
                }
                
                let mps = fetchRecordsForEntity("MP", key: "ircv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newIr.setValue(Date(), forKey: "createdAt")
                for mp in mps {
                    mp.setValue(newIr, forKeyPath: "ir")
                }
            }
        }
        if entitynaam == "Stof" {
            if let newStof = createRecordForEntity("Stof", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "stofcv" {
                        recordKey = (value as? String)!
                    }
                    newStof.setValue(value, forKey: key)
                }
                
                let sams = fetchRecordsForEntity("Sam", key: "stofcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newStof.setValue(Date(), forKey: "createdAt")
                for sam in sams {
                    sam.setValue(newStof, forKeyPath: "stof")
                }
            }
        }
        if entitynaam == "Ggr_Link" {
            // one-to-one relationship
            if let newGgr = createRecordForEntity("Ggr_Link", inManagedObjectContext: managedObjectContext) {
                var recordKey: String = ""
                for (key, value) in dict {
                    if key == "mppcv" {
                        recordKey = (value as? String)!
                    }
                    newGgr.setValue(value, forKey: key)
                }
                
                let mpps = fetchRecordsForEntity("MPP", key: "mppcv", arg: recordKey, inManagedObjectContext: managedObjectContext)
                
                newGgr.setValue(Date(), forKey: "createdAt")
                for mpp in mpps {
                    mpp.setValue(newGgr, forKeyPath: "ggr_link")
                }
            }
        }

        do {
            try managedObjectContext.save()
            print("context saved")
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
                subd[keys[val].lowercased()] = v[val]
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
//                    print(line)
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
                        values.append(value! as String)
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
                //print(values)
                items.append(values)
                
            }
        }
        //print("parsing: \([(keys, items)])")
        return [(keys, items)]
    }


    // MARK: Preload all data from csv file
    func preloadData (entitynaam: String) -> [Dictionary<String,String>] {
        
        // Store date to track updates
        UserDefaults.standard.setValue(Date(), forKey: "last_update")
        let filename = entitynaam + "_swift"
        var items:[Dictionary<String,String>] = [[:]]
        print("Preloading data...")
        // Retrieve data from the source file
        if let path = Bundle.main.path(forResource: filename, ofType: "csv") {
            let contentsOfURL = NSURL(fileURLWithPath: path)
            var error:NSError?
            if let values = parseCSV(contentsOf: contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                print("parsing data successful...")
                //item -> Dictionary<String,String>
                let keys = values[0].0
                //print("keys: \(keys)")
                let val = values[0].1
                //print("val: \(val)")
                items = parseCSV2Dict(keys: keys, values: val) /* items = list of dictionaries */
                                
            } else {
                print("Parsing of data failed")
            }
        } else {
            print("File not found!")
        }
        return items
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
