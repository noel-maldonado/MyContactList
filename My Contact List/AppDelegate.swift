//
//  AppDelegate.swift
//  My Contact List
//
//  Created by Noel Maldonado on 3/31/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit

import CoreData
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    lazy var motionManager = CMMotionManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //gets reference to the standard UserDefaults Object
        let settings = UserDefaults.standard
        //if sortfield has not been set, the default sort is by City
        if settings.string(forKey: Constants.kSortField) == nil {
            settings.set("city", forKey: Constants.kSortField)
        }
        //if sortDirectionAscending has not been set, the default sor is Ascending (true)
        if settings.string(forKey: Constants.kSortDirectionAscending) == nil {
            settings.set(true, forKey: Constants.kSortDirectionAscending)
        }
        
        if settings.string(forKey: Constants.kState) == nil {
            settings.set("city", forKey: Constants.kState)
        }
        
        if settings.string(forKey: Constants.kSortDirectionAscending2) == nil {
            settings.set(true, forKey: Constants.kSortDirectionAscending2)
        }

        settings.synchronize()
        print("Sort field: %@", settings.string(forKey: Constants.kSortField)!)
        print("Sort direction: \(settings.bool(forKey: Constants.kSortDirectionAscending))")
        print("Sort field: %@", settings.string(forKey: Constants.kState)!)
        
        return true
    }

    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MyContactListModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should
                // not use this function in a shipping application, although it may be useful during
                // development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when
                 * the device is locked.
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
                // fatalError() causes the application to generate a crash log and terminate. You should
                // not use this function in a shipping application, although it may be useful during
                // development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}

