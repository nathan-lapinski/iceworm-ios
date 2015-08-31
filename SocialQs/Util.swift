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

func displaySpinnerView(#spinnerActive: Bool, #UIBlock: Bool, var _boxView: UIView, var _blurView: UIVisualEffectView, progressText: String?, sender: UIViewController) {
    
    if UIBlock == true {
        // block application input
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    } else {
        // unblock application input
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    if spinnerActive == true {
        println("Adding activity indicator from superView")
        // You only need to adjust this frame to move it anywhere you want
        _boxView.frame = CGRectMake(sender.view.frame.midX - 90, sender.view.frame.midY - 25, 180, 50)
        _boxView.backgroundColor = UIColor.darkGrayColor()
        _boxView.alpha = 0.8
        _boxView.layer.cornerRadius = 10
        
        // setup blur view
        _blurView.frame = sender.view.frame
        
        //Here the spinnier is initialized
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        var textLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 50))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
        textLabel.text = progressText
        textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(16))!
        
        _boxView.addSubview(activityView)
        _boxView.addSubview(textLabel)
        
        _blurView.alpha = 0.0
        _blurView.layoutIfNeeded()
        _boxView.alpha = 0.0
        _boxView.layoutIfNeeded()
        
        sender.view.addSubview(_blurView)
        sender.view.addSubview(_boxView)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            _blurView.alpha = 1.0
            _blurView.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in })
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            _boxView.alpha = 1.0
            _boxView.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in })
       
    } else {
        
        sender.view.addSubview(_blurView)
        sender.view.addSubview(_boxView)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            _blurView.alpha = 0.0
            _blurView.layoutIfNeeded()
            _boxView.alpha = 0.0
            _boxView.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in
                
                _boxView.removeFromSuperview()
                _blurView.removeFromSuperview()
        })
    }
}


func displayCellSpinnerView(var _boxView: UIView, var _blurView: UIVisualEffectView, progressText: String?, sender: UITableViewCell) {
    
//    if UIBlock == true {
//        // block application input
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//    } else {
//        // unblock application input
//        UIApplication.sharedApplication().endIgnoringInteractionEvents()
//    }
//    
//    if spinnerActive == true {
        println("Adding activity indicator from superView")
        // You only need to adjust this frame to move it anywhere you want
        _boxView.frame = CGRectMake(sender.frame.midX - 90, sender.frame.midY - 25, 180, 50)
        _boxView.backgroundColor = UIColor.darkGrayColor()
        _boxView.alpha = 0.8
        _boxView.layer.cornerRadius = 10
        
        // setup blur view
        _blurView.frame = CGRectMake(8, 8, sender.frame.width - 16, sender.frame.height - 16)
        _blurView.layer.cornerRadius = cornerRadius
        
        //Here the spinnier is initialized
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        var textLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 50))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
        textLabel.text = progressText
        textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(16))!
        
        _boxView.addSubview(activityView)
        _boxView.addSubview(textLabel)
        
        _blurView.alpha = 0.0
        _blurView.layoutIfNeeded()
        _boxView.alpha = 0.0
        _boxView.layoutIfNeeded()
        
        sender.addSubview(_blurView)
        sender.addSubview(_boxView)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            _blurView.alpha = 1.0
            _blurView.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in })
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            _boxView.alpha = 1.0
            _boxView.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in })
        
//    } else {
//        
//        sender.addSubview(_blurView)
//        sender.addSubview(_boxView)
//        
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            
//            _blurView.alpha = 0.0
//            _blurView.layoutIfNeeded()
//            _boxView.alpha = 0.0
//            _boxView.layoutIfNeeded()
//            
//            }, completion: { (isFinished) -> Void in
//                
//                _boxView.removeFromSuperview()
//                _blurView.removeFromSuperview()
//        })
//    }
}


func displayAlert(title: String, message: String, sender: UIViewController) {
    
    var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        
    }))
        
        sender.presentViewController(alert, animated: true, completion: nil)
}




func downloadGroups(completion: (Bool) -> Void) {
    
    backgroundThread(delay: 0.0, background: {
        
        if let myGroupsTemp = PFUser.currentUser()!["myGroups"] as? [String] { myGroups = myGroupsTemp }
     
        var groupsQuery = PFQuery(className: "GroupJoin")
        groupsQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        groupsQuery.whereKey("groupName", containedIn: myGroups)
        
        groupsQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        object.pinInBackgroundWithBlock { (success, error) -> Void in
                            
                            if error == nil {
                                
                                println("Successfully pinned GroupJoin entry")
                            }
                        }
                    }
                }
            }
        })
    })
}




//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************
func downloadSocialQsFriends(completion: (Bool) -> Void) {
    
    backgroundThread(delay: 0.0, background: {
        
        var friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        
        friendsQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                myFriends.removeAll(keepCapacity: true)
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        myFriends.append(object["name"] as! String)
                    }
                }
            }
        })
    })
}
//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************


//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************
func downloadFacebookFriends(completion: (Bool) -> Void) {
    
    backgroundThread(delay: 0.0, background: {
    
        // Get friends from FB to check for new friends OR friends that NOW have SocialQs
        friendsDictionary.removeAll(keepCapacity: true)
        
        // Variable to store items that allow code to check if user is already in LDS
        // and if they have recently downloaded and linked SocialQs
        var friendCheck = Dictionary<String, String>()
        
        // Check currently DLd facebook friends and only log the ones that DNE yet (new friends)
        var facebookFriendsQuery = PFQuery(className: "Friends")
        facebookFriendsQuery.fromLocalDatastore()
        facebookFriendsQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        
        facebookFriendsQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                if let temp = objects as? [PFObject] {
                    
                    for object in temp {
                        
                        var tempDict = Dictionary<String, AnyObject>()
                        
                        // Build an array of dictionaries to use for comparison to FB DL
                        // Suggest: <picURL: type>
                        tempDict["name"] = object["name"]! as! String
                        tempDict["isSelected"] = false
                        if let tempURL = object["picURL"] as? String { tempDict["picURL"] = tempURL as String }
                        tempDict["type"] = object["type"]
                        tempDict["id"] = object["id"]
                        
                        // Pull profile image and store in separate dict
                        if let url = (tempDict["picURL"]) as? String {
                            
                            downloadFacebookFriendsPhotos(url, { (success) -> Void in })
                        }
                        
                        if contains(isGroupieName, object["name"]! as! String) {
                            
                            tempDict["isSelected"] = true
                        }
                        
                        // Add to friendCheck dictionary
                        if let URLCheck = tempDict["picURL"] as? String {
                            
                            friendCheck[URLCheck as String] = tempDict["type"] as? String
                        }
                            
                        // Append user to variable based friends system
                        friendsDictionary.append(tempDict)
                    }
                }
             
                // Download from facebook -----------------------------------------------------------
                struct userInfo {
                    var id: String!
                    var name: String!
                }
                
                var friendsWithApp = Dictionary<String, userInfo>()
                
                // Get list of facebook friends who have SOCIALQS
                var friendsRequest1 = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
                
                friendsRequest1.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    //println("Downloading FB friends WITH sQs")
                    
                    if error == nil {
                        
                        friendsWithApp.removeAll(keepCapacity: true)
                        
                        var results: AnyObject = result["data"]!!
                        
                        for var i = 0; i < results.count; i++ {
                            
                            friendsWithApp[results[i]!["picture"]!!["data"]!!["url"]!! as! String] = userInfo(id: results[i]["id"]!! as! String, name: results[i]["name"]!! as! String)
                        }
                        
                    } else {
                        
                        println("Error retrieving Facebook Users: \n\(error)")
                    }
                    
                    // Get list of ALL facebook friends
                    // - Nest in previous because we need the complete list of users who have SOCIALQS to filter "all" facebook friends properly
                    var friendsRequest2 = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id,picture&limit=1000", parameters: nil);
                    
                    friendsRequest2.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                        
                        //println("Downloading ALL FB friends and sorting")
                        
                        if error == nil {
                            
                            var temp: AnyObject = result["data"]!!
                            
                            var tempDict = Dictionary<String, AnyObject>()
                            
                            for var i = 0; i < temp.count; i++ {
                                
                                tempDict.removeAll(keepCapacity: true)
                                
                                tempDict["name"] = temp[i]["name"]!! as! String
                                tempDict["isSelected"] = false
                                tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
                                
                                // if this URL exists in "friendsWithApp" then we use "friendsWithApp" id because it is not just a token
                                if let tempURL = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String] {
                                    
                                    tempDict["type"] = "facebookWithApp"
                                    tempDict["id"] = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String]!.id
                                    
                                } else {
                                    
                                    tempDict["type"] = "facebookWithoutApp"
                                    tempDict["id"] = temp[i]["id"]!! as! String
                                }
                                
                                // Pull profile image and store in separate dict
                                if let url = (tempDict["picURL"]) as? String {
                                
                                    downloadFacebookFriendsPhotos(url, { (success) -> Void in })
                                }
                                
                                if contains(isGroupieName, temp[i]["name"]!! as! String) {
                                    
                                    tempDict["isSelected"] = true
                                }
                                
                                // ************************************************
                                // If this is going to run a lot, why bother with the skip?
                                // - Just update all in LDS since it will be a background process anyway
                                // ====================================================================
                                // skip this user if they are NOT NEW and have NOT CHANGED type
                                // (compare to friends pulled from LDS above
                                if let check1 = friendCheck[temp[i]!["picture"]!!["data"]!!["url"]!! as! String] { // user already in LDS
                                    
                                    if friendCheck[tempDict["picURL"] as! String] == tempDict["type"] as? String { // user is same type in LDS
                                        
                                        //println("User exists in LDS with same account type. Skipping")
                                        
                                        // skip end of iteration as to not re-append this user
                                        continue
                                        
                                    } else { // user varies in LDS - needs to be updated!
                                        
                                        println("User exists in LDS with different state. Updating user...")
                                        
                                        // update on LDS and DB
                                        var friendQuery = PFQuery(className: "Friends")
                                        friendQuery.fromLocalDatastore()
                                        friendQuery.whereKey("picURL", equalTo: tempDict["picURL"] as! String)
                                        
                                        friendQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                                            
                                            if error == nil {
                                                
                                                // Update account type
                                                object?.setObject(tempDict["type"] as! String, forKey: "type")
                                                
                                                // rePin user to LDS
                                                object?.pinInBackgroundWithBlock { (success, error) -> Void in
                                                    
                                                    if error == nil {
                                                        
                                                        //println("Successfully pinned user with updated account type")
                                                    }
                                                }
                                            }
                                        })
                                        
                                        // skip end of iteration as to not re-append this user
                                        continue
                                    }
                                    
                                } else { // User is NEW, add to dictionary and LDS
                                    
                                    friendsDictionary.append(tempDict)
                                    
                                    // ===================================================================
                                    //
                                    // Pin new asshole users
                                    //
                                    // ===================================================================
                                    
                                    var newFriend = PFObject(className: "Friends")
                                    newFriend["name"] = tempDict["name"] as! String
                                    newFriend["picURL"] = tempDict["picURL"] as! String
                                    newFriend["type"] = tempDict["type"] as! String
                                    newFriend["id"] = tempDict["id"] as! String
                                    newFriend.setObject(PFUser.currentUser()!, forKey: "owner")
                                    
                                    // Pin new user
                                    newFriend.pinInBackgroundWithBlock({ (success, error) -> Void in
                                        
                                        if error == nil {
                                            
                                            //println("Successfully pinned new user!")
                                            
                                        } else {
                                            
                                            println("There was an error pinning new user: \n\(error)")
                                        }
                                    })
                                }
                            }
                            
                            println("Facebook friend retrieval complete")
                            
                            // Set completion
                            completion(true)
                            
                        } else {
                            
                            println("Error retrieving Facebook non-users: \n\(error)")
                        }
                    }
                }
                
            } else {
                
                println("There was an error retrieving friends from the LDS: \n\(error)")
            }
        }
    })
}
//*******************************************************************************
// ^ NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************


func downloadFacebookFriendsPhotos(picURL: String, completion: (Bool) -> Void) {
    
    if friendsPhotoDictionary[picURL] == nil {
        
        let urlRequest = NSURLRequest(URL: NSURL(string: picURL)!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if data != nil {
                
                friendsPhotoDictionary[picURL] = UIImage(data: data)
                
            } else {
                
                println("There was an error downloading a friend's FB photo: \n\(error)")
            }
        }
    }
}


func formatButton(_button: UIButton) {
    
    _button.layer.cornerRadius = cornerRadius
    _button.backgroundColor = buttonBackgroundColor
    _button.titleLabel?.textColor = buttonTextColor
}


func getImageFromPFFile(object: PFFile, completion: (image: UIImage?, error: String?) -> ()) {
    
    
    object.getDataInBackgroundWithBlock({ (data, error) -> Void in
        
        if error == nil {
            
            if let downloadedImage = UIImage(data: data!) {
                
                completion(image: downloadedImage, error: nil)
            }
            
        } else {
            
            completion(image: nil, error: "Error retrieving image")
        }
    })
}


func getUserPhoto(completion: (Bool) -> Void) {
    
    // Check if profilePicture exists on Parse: if not, get from FB and upload to parse
    if let tempPic = PFUser.currentUser()!["profilePicture"] as? PFFile {
        
        tempPic.getDataInBackgroundWithBlock({ (data, error) -> Void in
            
            if error == nil {
                
                if let downloadedImage = UIImage(data: data!) {
                    println("got it!")
                    
                    profilePicture = downloadedImage
                    
                } else {
                    
                    profilePicture = UIImage(named: "profile.png")
                }
                
            } else {
                
                println("There was an error retrieving the users profile picture - welcomeController")
                println(error)
                
                profilePicture = UIImage(named: "profile.png")
            }
            
            completion(true)
        })
        
    } else if (PFUser.currentUser()!["profilePicture"] as? PFFile == nil) && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) == true {
        
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
                })
            })
        }
        
    } else { // no image to be loaded - use default
        
        profilePicture = UIImage(named: "profile.png")
        
        completion(true)
    }
}


//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************
func getUsersFacebookInfo(completion: (Bool) -> Void) { // ONLY USER FOR "ISNEW"
    // Gets facebook user info (name, firstname, email, id) and saves to Parse
    
    let request = FBSDKGraphRequest(graphPath:"me", parameters:nil)
    
    request.startWithCompletionHandler { (connection, result, error) in
        
        if error != nil {
            
            println("Error Getting User's FB infomation \(error)")
            
        } else if let userData = result as? [String:AnyObject] {
            
            var user = PFUser.currentUser()
        
            user!.setObject((userData["name"]! as? String)!, forKey: "name")
            user!.setObject((userData["email"]! as? String)!, forKey: "email")
            user!.setObject((userData["id"]! as? String)!, forKey: "facebookId")
            user!.setObject((userData["first_name"]! as? String)!, forKey: "firstName")
            user!.setObject((userData["last_name"]! as? String)!, forKey: "lastName")
            
            user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    println("User's data successfully stored to Parse")
                    
                } else {
                    
                    println("There was an error storing user's data to Parse")
                }
            })
            
            completion(true)
        }
    }
}
//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************


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


// Function to link/unlink users with facebook (settings and groupies alertView)
func linkUserWithFacebook(completion: (success: Bool, message: String?) -> Void) {
    
    if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: permissions, block: { (succeeded, error) -> Void in
            
            if succeeded {
                
                getUserPhoto() { (isFinished) -> Void in
                    
                    if isFinished {
                        
                        completion(success: true, message: "User is linked with Facebook - photo downloaded")
                        
                    } else {
                        
                        completion(success: true, message: "User is linked with Facebook - photo NOT downloaded")
                    }
                }
                
            } else {
                
                println(error!)
                
                completion(success: false, message: "User could not be linked with ")
            }
        })
    }
//    else { // UNLINK FACEBOOK
//        
//        //
//        //
//        // TEST IF REGULAR PARSE ACCOUNT IS SETUP - REQUIRE SETUP IF NO
//        //
//        //
//        
//        PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()!, block: { (succeeded, error) -> Void in
//            
//            if error == nil {
//                
//                println("User is no longer associated with their Facebook account.")
//            }
//        })
//    }
}


// Sets globals, changes to custom NSUserDefault keys and fills that data in
// - Creates installation if user isNew (notifications)
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
//    myVoted1StorageKey  = username + "votedOn1Ids"
//    myVoted2StorageKey  = username + "votedOn2Ids"
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
        
        println("Returning user data has been stored")
        completion(true)
    
        
//        // Store votedOnIds locally
//        var userQsQuery = PFQuery(className: "UserQs")
//        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
//            
//            if error != nil {
//                
//                println("Error loading UserQs/votedOnId")
//                println(error)
//                
//            } else {
//                
//                if let votedOn1Id = userQsObjects!["votedOn1Id"] as? [String] {
//                    
//                    votedOn1Ids = votedOn1Id
//                    
//                    NSUserDefaults.standardUserDefaults().setObject(votedOn1Ids, forKey: myVoted1StorageKey)
//                }
//                
//                if let votedOn2Id = userQsObjects!["votedOn2Id"] as? [String] {
//                    
//                    votedOn2Ids = votedOn2Id
//                    
//                    NSUserDefaults.standardUserDefaults().setObject(votedOn2Ids, forKey: myVoted2StorageKey)
//                }
//                
//                // Recall myFriends if applicable
//                if NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey) != nil {
//                    
//                    myFriends = NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey)! as! [String]
//                }
//            }
//        })
    }
}



// SYNCHRONOUS IMAGE DL
//                                    let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
//
//                                    var response: NSURLResponse?
//                                    var error: NSErrorPointer = nil
//                                    var data = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &response, error: error)
//
//                                    if let httpResponse = response as? NSHTTPURLResponse {
//
//                                        if httpResponse.statusCode > 199 && httpResponse.statusCode < 300 {
//
//                                            if let image = UIImage(data: data!) {
//                                                tempDict["profilePicture"] = image
//                                            }
//                                        }
//                                    }

