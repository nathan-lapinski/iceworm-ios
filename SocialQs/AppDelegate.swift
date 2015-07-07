//
//  AppDelegate.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/8/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // SocialQs Dev --------------------------------------------------------------------------------------------------------------
        //Parse.setApplicationId("TLaFl9hrzzz7BG5ou2mJaeokLLElJbOCBIrZqCPR", clientKey: "Ajogm9URc6Ix9gxur6j7JnGGcg4tw2ytR89Ooy6s")
        
        // SocialQs Blackula ---------------------------------------------------------------------------------------------------------
        //Parse.setApplicationId("7aEu2aiPHAun7HWnN42hWJ4eQuZueBiHZoGq7GZb", clientKey: "FU38Qh4hHo0LDGLAQP8PKB8wtjzwhPFGArpwqj7t")
        
        // SocialQs Test 2 -----------------------------------------------------------------------------------------------------------
        Parse.setApplicationId("4Jp7N84ASCGrEMdCxaWRWWmtHBDdxstvQxGIRqQb", clientKey: "RehfxlD1kQP6VdnzhJt3MbBCZShJx5jbMV0jZj8x")
        
        
        
        //PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // [Optional] Track statistics around application opens.
        //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Setup push
        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge |  UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    /*
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    */
    
    // MORE PUSH STUFFS ----------------------
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        var temp: NSDictionary = userInfo as NSDictionary
        var notification: NSDictionary = temp.objectForKey("aps") as! NSDictionary
        
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
        
        println(error)
        
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
        
        //FBSDKAppEvents.activateApp()
    
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

