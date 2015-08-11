//
//  UserActivites.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/17/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import Foundation
import UIKit


func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    
    println("!!!!!!!")
    
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
        
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            
            if(completion != nil){ completion!(); }
        }
    }
}
/*
A. To run a process in the background with a delay of 3 seconds:

backgroundThread(delay: 3.0, background: {
// Your background function here
});

B. To run a process in the background then run a completion in the foreground:

backgroundThread(background: {
// Your function here to run in the background
},
completion: {
// A function to run in the foreground when the background thread is complete
});

C. To delay by 3 seconds - note use of completion parameter without background parameter:

backgroundThread(delay: 3.0, completion: {
// Your delayed function here to be run in the foreground
});
*/

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


func downloadFacebookFriends(completion: (Bool) -> Void) {
    
    friendsDictionary.removeAll(keepCapacity: true)
    
    struct userInfo {
        var id: String!
        var name: String!
    }
    var friendsWithApp = Dictionary<String, userInfo>()
    
    // Get list of facebook friends who have SOCIALQS
    var friendsRequest1 = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
    
    friendsRequest1.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
        
        println("Downloading FB friends WITH sQs")
        
        if error == nil {
            
            friendsWithApp.removeAll(keepCapacity: true)
            
            var results: AnyObject = result["data"]!!
            
            for var i = 0; i < results.count; i++ {
                
                friendsWithApp[results[i]!["picture"]!!["data"]!!["url"]!! as! String] = userInfo(id: results[i]["id"]!! as! String, name: results[i]["name"]!! as! String)
            }
            
        } else {
            
            println("Error retrieving Facebook Users")
            println(error)
        }
        
        // Get list of all facebook friends
        // - Nest in previous because we need the complete list of users who have SOCIALQS to filter "all" facebook friends properly
        var friendsRequest2 = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id,picture&limit=1000", parameters: nil);
        
        friendsRequest2.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            println("Downloading ALL FB friends and sorting")
            
            if error == nil {
                
                var temp: AnyObject = result["data"]!!
                
                var tempDict = Dictionary<String, AnyObject>()
                
                for var i = 0; i < temp.count; i++ {
                    
                    tempDict.removeAll(keepCapacity: true)
                    
                    tempDict["name"] = temp[i]["name"]!! as! String
                    tempDict["isSelected"] = false
                    tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
                    
                    if let tempURL = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String] {
                        
                        tempDict["type"] = "facebookWithApp"
                        tempDict["id"] = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String]!.id
                        
                    } else {
                        
                        tempDict["type"] = "facebookWithoutApp"
                        tempDict["id"] = temp[i]["id"]!! as! String
                    }
                    
                    // Pull profile image synchornously and store in tempDict
                    if let url = (tempDict["picURL"]) as? String {
                        
                        let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
                        
                        var response: NSURLResponse?
                        var error: NSErrorPointer = nil
                        var data = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &response, error: error)!
                        
                        if let httpResponse = response as? NSHTTPURLResponse {
                            //println(httpResponse.statusCode)
                            if httpResponse.statusCode > 199 && httpResponse.statusCode < 300 {
                                
                                if let image = UIImage(data: data) {
                                    tempDict["profilePicture"] = image
                                }
                            }
                        }
                    }
                    
                    if contains(isGroupieName, temp[i]["name"]!! as! String) {
                        
                        tempDict["isSelected"] = true
                    }
                    
                    friendsDictionary.append(tempDict)
                }
                
                println("Facebook friend retrieval complete")
                
                // Set completion OR set global variable to TRUE
                completion(true)
            }
        }
    }
    
    
    //    // get myFriends and add to dictionary
    //    var socialQsUsersQuery = PFQuery(className: "_User")
    //    socialQsUsersQuery.whereKey("username", notEqualTo: username) // omit current user
    //    socialQsUsersQuery.whereKey("username", containedIn: myFriends) // No users that are already myFriends
    //    socialQsUsersQuery.whereKeyDoesNotExist("authData") // No users linked to FB
    //
    //    socialQsUsersQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    //
    //        if error == nil {
    //
    //            if let temp = objects {
    //
    //                for object in temp {
    //
    //                    var tempDict = Dictionary<String, AnyObject>()
    //
    //                    tempDict["name"] = object.username!!
    //                    tempDict["type"] = "socialQs"
    //                    tempDict["id"] = object.objectId!!
    //                    tempDict["isSelected"] = false
    //                    //tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
    //
    //                    self.friendsDictionary.append(tempDict)
    //                }
    //            }
    //
    //            self.loadUsers("")
    //        }
    //    })
}


// Gets facebook profile picture and saves it to Parse
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
                        user!.setObject(name, forKey: "name")
                        println("\(name) has signed in")
                        
                    } else {
                        
                        println("Error Getting User's FB infomation \(error)")
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


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}


func storeUserInfo(usernameToStore: String, isNew: Bool, completion: (Bool) -> Void) {
    
    // Store login information in globals
    username = usernameToStore.lowercaseString
    uId = PFUser.currentUser()!.objectId!
    uQId = PFUser.currentUser()?["uQId"]! as! String
    if let temp = PFUser.currentUser()!["name"] as? String {
        name = temp
    }
    
    // Set NSUserDefault storage keys
    usernameStorageKey  = username + "username"
    nameStorageKey      = username + "name"
    uIdStorageKey       = username + "uId"
    uQIdStorageKey      = username + "uQId"
    myVoted1StorageKey  = username + "votedOn1Ids"
    myVoted2StorageKey  = username + "votedOn2Ids"
    myFriendsStorageKey = username + "myFriends"
    
    // Store user info on the phone
    NSUserDefaults.standardUserDefaults().setObject(username, forKey: usernameStorageKey)
    NSUserDefaults.standardUserDefaults().setObject(uId, forKey: uIdStorageKey)
    NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: uQIdStorageKey)
    
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



