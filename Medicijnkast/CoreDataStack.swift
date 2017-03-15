//
//  CoreDataStack.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 18/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
    
    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = {_ in }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appcoda.Medicijnkast" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Medicijnkast", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    /*
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Medicijnkast.sqlite")
        
        /*
        if !FileManager.default.fileExists(atPath: url.path) {
            let sourceSqliteURLs = [Bundle.main.url(forResource: "Medicijnkast", withExtension: "sqlite")!, Bundle.main.url(forResource: "Medicijnkast", withExtension: "sqlite-wal")!, Bundle.main.url(forResource: "Medicijnkast", withExtension: "sqlite-shm")!]
            
            let destSqliteURLs = [self.applicationDocumentsDirectory.appendingPathComponent("Medicijnkast.sqlite"),
                                  self.applicationDocumentsDirectory.appendingPathComponent("Medicijnkast.sqlite-wal"),
                                  self.applicationDocumentsDirectory.appendingPathComponent("Medicijnkast.sqlite-shm")]
            
            var error:NSError? = nil
            for index in 0 ..< sourceSqliteURLs.count {
                
                do {
                    try FileManager.default.copyItem(at: sourceSqliteURLs[index], to: destSqliteURLs[index])
                    //FileManager.default.copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index], error: &error)
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        */
        var error:NSError? = nil /* remove */
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    */
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
                NSLog("CoreData error \(error), \(error._userInfo)")
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

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    // Optional
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    
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
    
    /*
     // example with DispatchQueue --> keep for updating
     func loadAllAttributes(entitynaam: String) {
     print("loading attributes...")
     let items = self.appDelegate.preloadData(entitynaam: entitynaam)
     self.totalLines = Float(items.count)
     for item in items {
     self.readLines += 1
     self.progressie = self.readLines/self.totalLines
     print("progressie in did appear: \(self.progressie)")
     //print("saveAttributes: \(entitynaam), /(dict)")
     self.saveAttributes(entitynaam: entitynaam, dict: item)
     DispatchQueue.main.sync() {
     self.updateProgressBar()
     }
     }
     }
     
     func updateProgressBar() {
     // To set a label with digital follow-up
     self.progressBar.progress = self.progressie
     let procentGeladen = Int(self.progressie*100)
     loadProgress.text = "\(procentGeladen) %"
     //print("progressBar: \(self.progressBar.progress)")
     // To set progressBar
     self.progressBar.setProgress(self.progressie, animated: true)
     }
     */

}
