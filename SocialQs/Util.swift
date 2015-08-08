//
//  UserActivites.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/17/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import Foundation
import UIKit

func blockUI(block: Bool, _activityIndicator: UIActivityIndicatorView, _blurView: UIVisualEffectView, sender: UIViewController) {
    
    if block == true {
        
        println("Blocking UI")
        
        // Add blur view
        _blurView.frame = sender.view.frame
        sender.view.addSubview(_blurView)
        
        // Setup and start spinner
        _activityIndicator.center = sender.view.center
        _activityIndicator.hidesWhenStopped = true
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        sender.view.addSubview(_activityIndicator)
        _activityIndicator.startAnimating()
        
        // block application input
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    } else {
        
        println("unBlocking UI")
        
        // Stop spinner
        _activityIndicator.stopAnimating()
        
        // Release lock on app input
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        // Un-blur ASK tab
        _blurView.removeFromSuperview()
    }
}


func displayAlert(title: String, message: String, sender: UIViewController) {
    
    var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        
    }))
        
        sender.presentViewController(alert, animated: true, completion: nil)
}

func formatButton(_button: UIButton) {
    
    _button.layer.cornerRadius = cornerRadius
    _button.backgroundColor = buttonBackgroundColor
    _button.titleLabel?.textColor = buttonTextColor
}


func getPersonalInfoFromFacebook(completion: (Bool) -> Void) {
    
    // Get profile pic from FB and store it locally (var) and on Parse
    var accessToken = FBSDKAccessToken.currentAccessToken().tokenString
    var url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + accessToken)
    let urlRequest = NSURLRequest(URL: url!)
    
    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
        
        // Set app image
        if data != nil {
            let image = UIImage(data: data)
            profilePicture = image
        } else {
            profilePicture = UIImage(named: "profile.png")
        }
        
        // Download data in background queue
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            var user = PFUser.currentUser()
            let imageData = UIImagePNGRepresentation(profilePicture)
            let picture = PFFile(name:"profilePicture.png", data: imageData)
            user!.setObject(picture, forKey: "profilePicture")
            
            user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    println("image saved successfully")
                    
                } else {
                    
                    println("image not saved")
                }
                
                // Get My Info facebook info and set my name
                var meRequest = FBSDKGraphRequest(graphPath:"/me", parameters: nil);
                
                meRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    if error == nil {
                        
                        name = result["name"]!! as! String
                        println("\(name) has signed in")
                        
                    } else {
                        
                        println("Error Getting Friends \(error)")
                    }
                    
                    println("Setting completion")
                    completion(true)
                }
            })
        })
    }
}


func globalBlurView() -> (UIVisualEffectView) {
    
    return UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
}


func storeUserInfo(usernameToStore: String, isNew: Bool, completion: (Bool) -> Void) {
    
    // Store login information in globals
    username = usernameToStore.lowercaseString
    uId = PFUser.currentUser()!.objectId!
    uQId = PFUser.currentUser()?["uQId"]! as! String
    
    // Set NSUserDefault storage keys
    usernameStorageKey  = username + "myName"
    nameStorageKey      = username + "name"
    uIdStorageKey       = username + "uId"
    uQIdStorageKey      = username + "uQId"
    myVoted1StorageKey  = username + "votedOn1Ids"
    myVoted2StorageKey  = username + "votedOn2Ids"
    //myVotesStorageKey  = username + "votes"
    profilePictureKey   = username + "profilePicture"
    myFriendsStorageKey = username + "myFriends"
    //deletedTheirStorageKey = username + "deletedTheirPermanent"
    
    // Store user info on the phone
    NSUserDefaults.standardUserDefaults().setObject(username, forKey: usernameStorageKey)
    NSUserDefaults.standardUserDefaults().setObject(uId, forKey: uIdStorageKey)
    NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: uQIdStorageKey)
    //NSUserDefaults.standardUserDefaults().setObject(profilePicture, forKey: profilePictureKey)
    
    if isNew {
        
        // Set PFInstallation pointer to user table
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                println("New user data stored!")
                
            } else {
                
                println("Error storing new user data:")
                println(error)
                
            }
            
            completion(true)
        })
        
    } else {
        
        // If has name set, store it
        if name != "" {
            
            NSUserDefaults.standardUserDefaults().setObject(name, forKey: nameStorageKey)
        }
    
        // Store votedOnIds locally
        var userQsQuery = PFQuery(className: "UserQs")
        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
            
            if error != nil {
                
                println("Error loading UserQs/votedOnId")
                println(error)
                
            } else {
                
                if let votedOn1Id = userQsObjects!["votedOn1Id"] as? [String] {
                    
                    votedOn1Ids = votedOn1Id
                    
                    NSUserDefaults.standardUserDefaults().setObject(votedOn1Ids, forKey: myVoted1StorageKey)
                }
                
                if let votedOn2Id = userQsObjects!["votedOn2Id"] as? [String] {
                    
                    votedOn2Ids = votedOn2Id
                    
                    NSUserDefaults.standardUserDefaults().setObject(votedOn2Ids, forKey: myVoted2StorageKey)
                }
                
                // Recall myFriends if applicable
                if NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey) != nil {
                    
                    myFriends = NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey)! as! [String]
                }
                
                println("Returning user data has been stored")
                completion(true)
            }
        })
    }
}



