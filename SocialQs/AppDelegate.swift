//
//  AppDelegate.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/8/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import CoreData
import Parse
import ParseCrashReporting
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        var parseAppId = "TLaFl9hrzzz7BG5ou2mJaeokLLElJbOCBIrZqCPR"
        var parseClientKey = "Ajogm9URc6Ix9gxur6j7JnGGcg4tw2ytR89Ooy6s"
        
        //////////////////////////////////////////
        //////////////////////////////////////////
        let mode = "test"  ///////////////////////
        //////////////////////////////////////////
        //////////////////////////////////////////
        
        switch mode {
        case "dev":
            // SocialQs Dev ----------------------------------------------------
            parseAppId = "TLaFl9hrzzz7BG5ou2mJaeokLLElJbOCBIrZqCPR"
            parseClientKey = "Ajogm9URc6Ix9gxur6j7JnGGcg4tw2ytR89Ooy6s"
            // -----------------------------------------------------------------
        case "test":
            // SocialQs Test 5 -------------------------------------------------
            parseAppId = "d7CUQUOHn2tn9bIxpch99L23SixOabT7058UftQ3"
            parseClientKey = "LY3NJ0LXUJh7x0YWu955qJ2sWRdvnr4RwTSB91O5"
            // -----------------------------------------------------------------
        default:
            // SocialQs Dev ----------------------------------------------------
            parseAppId = "TLaFl9hrzzz7BG5ou2mJaeokLLElJbOCBIrZqCPR"
            parseClientKey = "Ajogm9URc6Ix9gxur6j7JnGGcg4tw2ytR89Ooy6s"
            // -----------------------------------------------------------------
        }
        
        // Enable Crash Reporting
        ParseCrashReporting.enable();
        //NSException(name: NSGenericException, reason: "Everything is ok. This is just a test crash.", userInfo: nil).raise()
        
//        dispatch_after(
//            dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))),
//            dispatch_get_main_queue(),
//            { () -> Void in
//                self.crash()
//        });
        
        // Setup Parse
        Parse.setApplicationId(parseAppId, clientKey: parseClientKey)
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        //PFUser.enableRevocableSessionInBackground()
        
        // Setup Parse/Facebook
        PFFacebookUtils.initializeFacebook()
            
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
//        // Setup notifications
//        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge |  UIUserNotificationType.Sound)
//        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//        application.registerUserNotificationSettings(settings)
//        application.registerForRemoteNotifications()
        
        //return true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // MORE NOTIFICATION STUFFS ----------------------
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        //UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        let temp: NSDictionary = userInfo as NSDictionary
        let notification: NSDictionary = temp.objectForKey("aps") as! NSDictionary
        
        //println("-------NOTIFICATION-------")
        //println(notification)
        //println("-------NOTIFICATION-------")
        //println((notification.objectForKey("content-available")) != nil)
        
        if (notification.objectForKey("content-available") != nil) {
            
            // *** KEEP THIS FOR WHEN WE WANT TO SEND GLOBAL Qs FROM THE SOCIALQS TEAM
            // if equal to one, silent notification is telling us there is a new Q
            if (notification.objectForKey("content-available")?.isEqualToNumber(1) != nil) {
                // Then this is a silent notification - post local notification
                // This can be used to trigger a function and reload data within the app when a push is recieved
                NSNotificationCenter.defaultCenter().postNotificationName("reloadTheirTable", object: nil)
            } else {
                // Else this is a standard notification - standard display of push message/badge/alertview
                // ie: we can set "content-available" to nil and make the push a standard message or some shit
                PFPush.handlePush(userInfo)
            }
        }
    }
    
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // Store the deviceToken in the current Installation and save it to Parse
        // This lets parse know which user is using which device(s) so it knows where to send pushes
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
        print(error)
        
    }
    // MORE PUSH STUFFS ----------------------
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Clear badges
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        
        FBSDKAppEvents.activateApp()
    }
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.saveContext()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.booksix.socialQs" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SocialQs", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("socialQs.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
}

