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
    
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
        
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

func displaySpinnerView(spinnerActive spinnerActive: Bool, UIBlock: Bool, _boxView: UIView, _blurView: UIVisualEffectView, progressText: String?, sender: UIViewController) {
    
    if UIBlock == true {
        // block application input
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    } else {
        // unblock application input
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    if spinnerActive == true {
        print("Adding activity indicator from superView")
        // You only need to adjust this frame to move it anywhere you want
        //_boxView.frame = CGRectMake(sender.view.frame.midX - 90, sender.view.frame.midY - 25, 180, 50)
        _boxView.frame = CGRectMake(sender.view.frame.midX - 90, sender.view.frame.height/2 - 50, 180, 50)
        _boxView.backgroundColor = UIColor.darkGrayColor()
        _boxView.alpha = 0.8
        _boxView.layer.cornerRadius = 10
        
        // setup blur view
        _blurView.frame = CGRectMake(0, 0, sender.view.frame.width, sender.view.frame.height)// sender.view.frame
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 50))
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


func displayCellSpinnerView(_boxView: UIView, _blurView: UIVisualEffectView, progressText: String?, sender: UITableViewCell) {
    
//    if UIBlock == true {
//        // block application input
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//    } else {
//        // unblock application input
//        UIApplication.sharedApplication().endIgnoringInteractionEvents()
//    }
//    
//    if spinnerActive == true {
        print("Adding activity indicator from superView")
        // You only need to adjust this frame to move it anywhere you want
        _boxView.frame = CGRectMake(sender.frame.midX - 90, sender.frame.midY - 25, 180, 50)
        _boxView.backgroundColor = UIColor.darkGrayColor()
        _boxView.alpha = 0.8
        _boxView.layer.cornerRadius = 10
        
        // setup blur view
        _blurView.frame = CGRectMake(8, 8, sender.frame.width - 16, sender.frame.height - 16)
        _blurView.layer.cornerRadius = cornerRadius
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 50))
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
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        
    }))
        
        sender.presentViewController(alert, animated: true, completion: nil)
}




func downloadGroups(completion: (Bool) -> Void) {
    
    //backgroundThread(0.0, background: {
    
    if let myGroupsTemp = PFUser.currentUser()!["myGroups"] as? [String] {
        
        myGroups = myGroupsTemp
        
        let groupsQuery = PFQuery(className: "GroupJoin")
        groupsQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        groupsQuery.whereKey("groupName", containedIn: myGroups)
                
        groupsQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        
            if error == nil {
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        object.pinInBackgroundWithBlock { (success, error) -> Void in
                            
                            if error == nil {
                                
                                //print("Successfully pinned GROUPJOIN entry")
                            }
                        }
                    }
                }
            }
        })
    }
    //})
}


//*******************************************************************************
// NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************
func downloadFacebookFriends(completion: (Bool) -> Void) {
    
    //!!! Graph requests F up when on a background thread...(?)
    //backgroundThread(delay: 0.0, background: {
        
        // Get friends from FB to check for new friends OR friends that NOW have SocialQs
        friendsDictionary.removeAll(keepCapacity: true)

        // Get list of facebook friends who have SOCIALQS
        let friendsRequest1 = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
        
        print("GETTING FRIENDS")
    
        friendsRequest1.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            print("Downloading FB friends WITH sQs")
            
            if error == nil {
                
                let results: AnyObject = result["data"]!!
                //var temp: AnyObject = result["data"]!!
                var tempDict = Dictionary<String, AnyObject>()
                
                for var i = 0; i < results.count; i++ {
                    tempDict.removeAll(keepCapacity: true)
                    
                    tempDict["name"] = results[i]["name"]!! as! String
                    tempDict["isSelected"] = false
                    tempDict["picURL"] = results[i]!["picture"]!!["data"]!!["url"]!!
                    
                    tempDict["type"] = "facebookWithApp"
                    tempDict["id"] = results[i]["id"]!! as! String
                    
                    // Pull profile image and store in separate dict
                    if let url = (tempDict["picURL"]) as? String {
                        
                        downloadFacebookFriendsPhotos(url, completion: { (success) -> Void in })
                    }
                    
                    if isGroupieName.contains((results[i]["name"]!! as! String)) {
                        
                        tempDict["isSelected"] = true
                    }
                    
                    friendsDictionary.append(tempDict)
                    
                }
                
                //println("FRIENDS RETRIEVED: \(friendsDictionary)")
                
                completion(true)
                
            } else {
                
                print("Error retrieving Facebook Users: \n\(error)")
                
                completion(false)
            }
        }
    //})
    
//
//
//    backgroundThread(delay: 0.0, background: {
//
//        // Get friends from FB to check for new friends OR friends that NOW have SocialQs
//        friendsDictionary.removeAll(keepCapacity: true)
//
//        // Variable to store items that allow code to check if user is already in LDS
//        // and if they have recently downloaded and linked SocialQs
//        var friendCheck = Dictionary<String, String>()
//        
//        // Check currently DLd facebook friends and only log the ones that DNE yet (new friends)
//        var facebookFriendsQuery = PFQuery(className: "Friends")
//        facebookFriendsQuery.fromLocalDatastore()
//        facebookFriendsQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
//        
//        facebookFriendsQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            
//            if error == nil {
//                
//                if let temp = objects as? [PFObject] {
//                    
//                    for object in temp {
//                        
//                        var tempDict = Dictionary<String, AnyObject>()
//                        
//                        // Build an array of dictionaries to use for comparison to FB DL
//                        // Suggest: <picURL: type>
//                        tempDict["name"] = object["name"]! as! String
//                        tempDict["isSelected"] = false
//                        if let tempURL = object["picURL"] as? String { tempDict["picURL"] = tempURL as String }
//                        tempDict["type"] = object["type"]
//                        tempDict["id"] = object["id"]
//                        
//                        // Pull profile image and store in separate dict
//                        if let url = (tempDict["picURL"]) as? String {
//                            
//                            downloadFacebookFriendsPhotos(url, { (success) -> Void in })
//                        }
//                        
//                        if contains(isGroupieName, object["name"]! as! String) {
//                            
//                            tempDict["isSelected"] = true
//                        }
//                        
//                        // Add to friendCheck dictionary
//                        if let URLCheck = tempDict["picURL"] as? String {
//                            
//                            friendCheck[URLCheck as String] = tempDict["type"] as? String
//                        }
//                            
//                        // Append user to variable based friends system
//                        friendsDictionary.append(tempDict)
//                    }
//                }
//                
//                println(friendCheck.count)
//                println(friendCheck)
//             
//                // Download from facebook -----------------------------------------------------------
//                struct userInfo {
//                    var id: String!
//                    var name: String!
//                }
//                
//                var friendsWithApp = Dictionary<String, userInfo>()
//                
                // Get list of facebook friends who have SOCIALQS
//                var friendsRequest1 = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
//                
//                friendsRequest1.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
//                    
//                    //println("Downloading FB friends WITH sQs")
//                    
//                    if error == nil {
//                        
//                        friendsWithApp.removeAll(keepCapacity: true)
//                        
//                        var results: AnyObject = result["data"]!!
//                        
//                        for var i = 0; i < results.count; i++ {
//                            
//                            //println(results[i])
//                            
//                            friendsWithApp[results[i]!["picture"]!!["data"]!!["url"]!! as! String] = userInfo(id: results[i]["id"]!! as! String, name: results[i]["name"]!! as! String)
//                        }
//                        
//                    } else {
//                        
//                        println("Error retrieving Facebook Users: \n\(error)")
//                    }
//
//                    // Get list of ALL facebook friends
//                    // - Nest in previous because we need the complete list of users who have SOCIALQS to filter "all" facebook friends properly
//                    var friendsRequest2 = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id,picture&limit=1000", parameters: nil);
//                    
//                    friendsRequest2.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
//                        
//                        //println("Downloading ALL FB friends and sorting")
//                        
//                        if error == nil {
//                            
//                            var temp: AnyObject = result["data"]!!
//
//                            var tempDict = Dictionary<String, AnyObject>()
//                            
//                            for var i = 0; i < temp.count; i++ {
//                                
//                                //println(temp[i])
//                                
//                                tempDict.removeAll(keepCapacity: true)
//                                
//                                tempDict["name"] = temp[i]["name"]!! as! String
//                                tempDict["isSelected"] = false
//                                tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
//                                
//                                // if this URL exists in "friendsWithApp" then we use "friendsWithApp" id because it is not just a token
//                                if let tempURL = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String] {
//                                    
//                                    tempDict["type"] = "facebookWithApp"
//                                    tempDict["id"] = friendsWithApp[temp[i]!["picture"]!!["data"]!!["url"]!! as! String]!.id
//                                    
//                                } else {
//                                    
//                                    tempDict["type"] = "facebookWithoutApp"
//                                    tempDict["id"] = temp[i]["id"]!! as! String
//                                }
//                                
//                                // Pull profile image and store in separate dict
//                                if let url = (tempDict["picURL"]) as? String {
//                                
//                                    downloadFacebookFriendsPhotos(url, { (success) -> Void in })
//                                }
//                                
//                                if contains(isGroupieName, temp[i]["name"]!! as! String) {
//                                    
//                                    tempDict["isSelected"] = true
//                                }
//
//                                // ************************************************
//                                // If this is going to run a lot, why bother with the skip?
//                                // - Just update all in LDS since it will be a background process anyway
//                                // ====================================================================
//                                // skip this user if they are NOT NEW and have NOT CHANGED type
//                                // (compare to friends pulled from LDS above
//                                if let check1 = friendCheck[temp[i]!["picture"]!!["data"]!!["url"]!! as! String] { // user already in LDS
//                                    
//                                    if friendCheck[tempDict["picURL"] as! String] == tempDict["type"] as? String { // user is same type in LDS
//                                        
//                                        //println("User exists in LDS with same account type. Skipping")
//                                        
//                                        // skip end of iteration as to not re-append this user
//                                        continue
//                                        
//                                    } else { // user varies in LDS - needs to be updated!
//                                        
//                                        println("User exists in LDS with different state. Updating user...")
//                                        
//                                        // update on LDS and DB
//                                        var friendQuery = PFQuery(className: "Friends")
//                                        friendQuery.fromLocalDatastore()
//                                        friendQuery.whereKey("picURL", equalTo: tempDict["picURL"] as! String)
//                                        
//                                        friendQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
//                                            
//                                            if error == nil {
//                                                
//                                                // Update account type
//                                                object?.setObject(tempDict["type"] as! String, forKey: "type")
//                                                
//                                                // rePin user to LDS
//                                                object?.pinInBackgroundWithBlock { (success, error) -> Void in
//                                                    
//                                                    if error == nil {
//                                                        
//                                                        //println("Successfully pinned user with updated account type")
//                                                    }
//                                                }
//                                            }
//                                        })
//                                        
//                                        // skip end of iteration as to not re-append this user
//                                        continue
//                                    }
//                                    
//                                } else { // User is NEW, add to dictionary and LDS
//                                    
//                                    friendsDictionary.append(tempDict)
//                                    
//                                    // ===================================================================
//                                    //
//                                    // Pin new asshole users
//                                    //
//                                    // ===================================================================
//                                    
//                                    var newFriend = PFObject(className: "Friends")
//                                    newFriend["name"] = tempDict["name"] as! String
//                                    newFriend["picURL"] = tempDict["picURL"] as! String
//                                    newFriend["type"] = tempDict["type"] as! String
//                                    newFriend["id"] = tempDict["id"] as! String
//                                    newFriend.setObject(PFUser.currentUser()!, forKey: "owner")
//                                    
//                                    // Pin new user
//                                    newFriend.pinInBackgroundWithBlock({ (success, error) -> Void in
//                                        
//                                        if error == nil {
//                                            
//                                            //println("Successfully pinned new user!")
//                                            
//                                        } else {
//                                            
//                                            println("There was an error pinning new user: \n\(error)")
//                                        }
//                                    })
//                                }
//                            }
//                            
//                            println("Facebook friend retrieval complete")
//                            
//                            // Set completion
//                            completion(true)
//                            
//                            println(friendsDictionary)
//                            
//                        } else {
//                            
//                            println("Error retrieving Facebook non-users: \n\(error)")
//                        }
//                    }
//                }
//                
//            } else {
//                
//                println("There was an error retrieving friends from the LDS: \n\(error)")
//            }
//        }
//    })
}
//*******************************************************************************
// ^ NEEDS PROPER ERROR HANDLING - and appropriate use of completion with errors!
//*******************************************************************************


func downloadFacebookFriendsPhotos(picURL: String, completion: (Bool) -> Void) {
    
    if friendsPhotoDictionary[picURL] == nil {
        
        let urlRequest = NSURLRequest(URL: NSURL(string: picURL)!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if data != nil {
                
                friendsPhotoDictionary[picURL] = UIImage(data: data!)
                
            } else {
                
                print("There was an error downloading a friend's FB photo: \n\(error)")
            }
        }
    }
}


func formatButton(_button: UIButton) {
    
    _button.layer.cornerRadius = cornerRadius
    _button.backgroundColor = UIColor.clearColor()//buttonBackgroundColor
    _button.titleLabel?.textColor = buttonTextColor//UIColor.whiteColor()//
    _button.layer.borderWidth = 1.0
    _button.layer.borderColor = UIColor.whiteColor().CGColor
    _button.layer.cornerRadius = 4.0
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
                    print("got it!")
                    
                    profilePicture = downloadedImage
                    
                } else {
                    
                    profilePicture = UIImage(named: "profile.png")
                }
                
            } else {
                
                print("There was an error retrieving the users profile picture - welcomeController")
                print(error)
                
                profilePicture = UIImage(named: "profile.png")
            }
            
            completion(true)
        })
        
    } else if (PFUser.currentUser()!["profilePicture"] as? PFFile == nil) && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) == true {
        
        // Get profile pic from FB and store it locally (var) and on Parse
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + accessToken)
        let urlRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            // Set app image
            if data != nil {
                let image = UIImage(data: data!)
                profilePicture = image
            } else {
                profilePicture = UIImage(named: "profile.png")
            }
            
            // Download data in background queue
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                
                let user = PFUser.currentUser()
                let imageData = UIImagePNGRepresentation(profilePicture!)
                let picture = PFFile(name:"profilePicture.png", data: imageData!)
                user!.setObject(picture, forKey: "profilePicture")
                
                user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if error == nil {
                        
                        print("image saved successfully")
                        
                    } else {
                        
                        print("image not saved")
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
    
    let request = FBSDKGraphRequest(graphPath:"/me?fields=name,id,picture,first_name,last_name,email", parameters:nil)
    
    request.startWithCompletionHandler { (connection, result, error) in
        
        if error != nil {
            
            print("Error Getting User's FB infomation \(error)")
            
        } else if let userData = result as? [String:AnyObject] {
            
            let user = PFUser.currentUser()
        
            user!.setObject((userData["name"]! as? String)!, forKey: "name")
            user!.setObject((userData["email"]! as? String)!, forKey: "email")
            user!.setObject((userData["id"]! as? String)!, forKey: "facebookId")
            user!.setObject((userData["first_name"]! as? String)!, forKey: "firstName")
            user!.setObject((userData["last_name"]! as? String)!, forKey: "lastName")
            
            user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    print("User's data successfully stored to Parse")
                    
                } else {
                    
                    print("There was an error storing user's data to Parse")
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


func downloadMyQs(completion: (Bool) -> Void) {
    
    //        let qQueryLocal = PFQuery(className: "QJoin")
    //        qQueryLocal.fromLocalDatastore()
    //        qQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
    //        qQueryLocal.whereKey("asker", equalTo: PFUser.currentUser()!)
    //        qQueryLocal.orderByDescending("createdAt")
    //        qQueryLocal.whereKey("deleted", equalTo: false)
    //        qQueryLocal.includeKey("from")
    //        qQueryLocal.includeKey("question")
    //        qQueryLocal.includeKey("images")
    //        qQueryLocal.limit = 1000
    //
    //        qQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
    //
    //            if error == nil {
    //
    //                self.QJoinObjects = objects!
    //
    //                for temp in objects! {
    //                    if let tempId: String = temp.objectId {
    //                        self.alreadyRetrievedMyQs.append(tempId)
    //                    }
    //                }
    //
    //            } else {
    //
    //                print("There was an error loading Qs from local data store:")
    //                print(error)
    //            }
    
    // Get Qs that are not in localdata store
    let qQueryServer = PFQuery(className: "QJoin")
    qQueryServer.whereKey("to", equalTo: PFUser.currentUser()!)
    qQueryServer.whereKey("from", equalTo: PFUser.currentUser()!)
    if myAlreadyRetrieved.count > 0 {
        qQueryServer.whereKey("objectId", notContainedIn: myAlreadyRetrieved)
    }
    qQueryServer.orderByDescending("createdAt")
    qQueryServer.whereKey("deleted", equalTo: false)
    qQueryServer.includeKey("asker")
    qQueryServer.includeKey("question")
    qQueryServer.includeKey("images")
    qQueryServer.limit = 1000
    
    qQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
        
        if error == nil {
            
            myQJoinObjects.removeAll(keepCapacity: true)
            
            // Append to local array of PFObjects
            myQJoinObjects = myQJoinObjects + objects!
            
            //                    // Pin new Qs to local datastore
            //                    if let temp: [PFObject] = objects {
            //
            //                        for object in temp {
            //
            //                            object.pinInBackgroundWithBlock { (success, error) -> Void in
            //
            //                                if error == nil {
            //
            //                                    print("My Qs QJoin Object \(object.objectId!) pinned!")
            //                                }
            //
            //                                //                                    if let test = object.objectId {
            //                                //                                        self.alreadyRetrievedMyQs.append(test)
            //                                //                                    }
            //                            }
            //                        }
            //                    }
            
            completion(true)
            
            if myQJoinObjects.count < 1 {
                if noMyQJoinObjects != nil {
                    myQJoinObjects = [noMyQJoinObjects!]
                }
            }
            
            // Update badge
            updateBadge("my")
            //NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
            
        } else {
            
            print("There was an error retrieving new Qs from the database:")
            print(error)
            
            completion(false)
        }
    })
    //        }
}


func downloadTheirQs(completion: (Bool) -> Void) {
    
    //        let qJoinQueryLocal = PFQuery(className: "QJoin")
    //        qJoinQueryLocal.fromLocalDatastore()
    //        qJoinQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
    //        qJoinQueryLocal.whereKey("from", notEqualTo: PFUser.currentUser()!)
    //        qJoinQueryLocal.orderByDescending("createdAt")
    //        qJoinQueryLocal.whereKey("deleted", equalTo: false)
    //        qJoinQueryLocal.includeKey("from")
    //        qJoinQueryLocal.includeKey("question")
    //        qJoinQueryLocal.limit = 1000
    //
    //        qJoinQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
    //
    //            if error == nil {
    //
    //                self.QJoinObjects = objects!
    //
    //                for temp in objects! {
    //
    //                    if let tempId: String = temp.objectId {
    //
    //                        self.alreadyRetrieved.append(tempId)
    //                    }
    //                }
    //
    //            } else {
    //
    //                print("There was an error loading Qs from local data store:")
    //                print(error)
    //            }
    
    // Get Qs that are not in localdata store
    let qJoinQueryServer = PFQuery(className: "QJoin")
    qJoinQueryServer.whereKey("to", equalTo: PFUser.currentUser()!)
    qJoinQueryServer.whereKey("from", notEqualTo: PFUser.currentUser()!)
    if theirAlreadyRetrieved.count > 0 {
        qJoinQueryServer.whereKey("objectId", notContainedIn: myAlreadyRetrieved)
    }
    qJoinQueryServer.orderByDescending("createdAt")
    qJoinQueryServer.whereKey("deleted", equalTo: false)
    qJoinQueryServer.includeKey("from")
    qJoinQueryServer.includeKey("question")
    qJoinQueryServer.includeKey("question.imagesArray")
//    qJoinQueryServer.includeKey("imagesArray.fullResolution")
//    qJoinQueryServer.includeKey("imagesArray.thumbnail")
//    qJoinQueryServer.includeKey("imagesArray")
    qJoinQueryServer.limit = 1000
    
    qJoinQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
        
        if error == nil {
            
            if objects!.count > 0 {
                theirQJoinObjects.removeAll(keepCapacity: true)
            }
            
            // Append to local array of PFObjects
            theirQJoinObjects = theirQJoinObjects + objects!
            
//            // Pin new Qs to local datastore
//            if let temp: [PFObject] = objects!{
//                
//                for object in temp {
//                    
////                    let objId = object["question"].objectId!!
////                    let newChannel = "Question_\(objId)"
////                    let currentInstallation = PFInstallation.currentInstallation()
////                    
////                    // If user has current channels, check if this one is NOT there and add it
////                    if let channels = (PFInstallation.currentInstallation().channels as? [String]) {
////                        
////                        if !channels.contains(newChannel) {
////                            currentInstallation.addUniqueObject(newChannel, forKey: "channels")
////                            currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
////                                
////                                if error == nil {
////                                    
////                                    print("Subscribed to \(newChannel)")
////                                }
////                            })
////                        }
////                        
////                    } else { // else add it as the first
////                        
////                        currentInstallation.addUniqueObject(newChannel, forKey: "channels")
////                        currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
////                            
////                            if error == nil {
////                                
////                                print("Subscribed to \(newChannel)")
////                            }
////                        })
////                    }
//                    
//                    //                            object.pinInBackgroundWithBlock { (success, error) -> Void in
//                    //
//                    //                                if error == nil {
//                    //
//                    //                                    print("Their Qs QJoin Object \(object.objectId!) pinned!")
//                    //                                }
//                    //
//                    //                                //                                    if let test = object.objectId {
//                    //                                //                                        self.alreadyRetrieved.append(test)
//                    //                                //                                    }
//                    //                            }
//                }
//            }
            
            completion(true)
            
            if theirQJoinObjects.count < 1 {
                if noTheirQJoinObjects != nil {
                    theirQJoinObjects = [noTheirQJoinObjects!]
                }
            }
            
            // Update badge
            updateBadge("their")
            //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
            
        } else {
            
            print("There was an error retrieving new Qs from the database:")
            print(error)
            
            completion(false)
        }
    })
    //        }
}


func buildNoMyQsQuestion() {
    
    // Build a temp question when none are available
    myQJoinObjects.removeAll(keepCapacity: true)
    
    print("NO MYQS!!")
    
    let noQsJoinObject = PFObject(className: "QJoin")
    let noQsQuestionObject = PFObject(className: "SocialQs")
    //        var noQsPhotoJoinQObject = PFObject(className: "PhotoJoin")
    //        var noQsPhotoJoin1Object = PFObject(className: "PhotoJoin")
    //        var noQsPhotoJoin2Object = PFObject(className: "PhotoJoin")
    let noQsAskerObject = PFObject(className: "User")
    
    let profImageData = UIImagePNGRepresentation(UIImage(named: "arrowToAsk.png")!)
    let profImageFile: PFFile = PFFile(name: "arrowToAsk.png", data: profImageData!)
    noQsAskerObject.setObject(profImageFile, forKey: "profilePicture")
    noQsAskerObject.setObject("SocialQs Team", forKey: "name")
    
    noQsQuestionObject.setObject("Use the ASK button in the top left to create a Q!", forKey: "questionText")
    noQsQuestionObject.setObject("Tap any of the images to enlarge...", forKey: "option1Text")
    noQsQuestionObject.setObject("...or drag to the right to cast your vote!", forKey: "option2Text")
    noQsQuestionObject.setObject(noQsAskerObject, forKey: "asker")
    
    let qImageData = UIImagePNGRepresentation(UIImage(named: "scenery3.png")!)
    let qImageFile: PFFile = PFFile(name: "questionPicture.png", data: qImageData!)
    let o1ImageData = UIImagePNGRepresentation(UIImage(named: "scenery1.png")!)
    let o1ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o1ImageData!)
    let o2ImageData = UIImagePNGRepresentation(UIImage(named: "scenery2.png")!)
    let o2ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o2ImageData!)
    
    noQsQuestionObject.setObject(qImageFile, forKey: "questionImageThumb")
    noQsQuestionObject.setObject(qImageFile, forKey: "questionImageFull")
    noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageThumb")
    noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageFull")
    noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageThumb")
    noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageFull")
    
    //var images: [PFObject] = [noQsPhotoJoinQObject, noQsPhotoJoin1Object, noQsPhotoJoin2Object]
    
    //        noQsQuestionObject.setObject(noQsPhotoJoinQObject, forKey: "questionImages")
    //        noQsQuestionObject.setObject(noQsPhotoJoin1Object, forKey: "option1Images")
    //        noQsQuestionObject.setObject(noQsPhotoJoin2Object, forKey: "option2Images")
    noQsQuestionObject.setObject(0, forKey: "option1Stats")
    noQsQuestionObject.setObject(0, forKey: "option2Stats")
    
    noQsJoinObject.setObject(noQsQuestionObject, forKey: "question")
    noQsJoinObject.setObject(noQsAskerObject, forKey: "asker")
    
    noMyQJoinObjects = noQsJoinObject
    
    // Update badge
    updateBadge("my")
    //NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
}


func buildNoTheirQsQuestion() {
    
    // Build a temp question when none are available
    theirQJoinObjects.removeAll(keepCapacity: true)
    
    print("NO THEIRQS!!")
    
    let noQsJoinObject = PFObject(className: "QJoin")
    let noQsQuestionObject = PFObject(className: "SocialQs")
    let noQsAskerObject = PFObject(className: "User")
    
    let profImageData = UIImagePNGRepresentation(UIImage(named: "logo_square_blueS.png")!)
    let profImageFile: PFFile = PFFile(name: "logo_square_blueS.png", data: profImageData!)
    noQsAskerObject.setObject(profImageFile, forKey: "profilePicture")
    noQsAskerObject.setObject("SocialQs Team", forKey: "name")
    
    noQsQuestionObject.setObject("No Qs! Don't you have friends?", forKey: "questionText")
    noQsQuestionObject.setObject("I don't 😥 but I'll make some and invite them!", forKey: "option1Text")
    noQsQuestionObject.setObject("I do 😃 and I'll invite more!", forKey: "option2Text")
    noQsQuestionObject.setObject(noQsAskerObject, forKey: "asker")
    
    let qImageData = UIImagePNGRepresentation(UIImage(named: "scenery3.png")!)
    let qImageFile: PFFile = PFFile(name: "questionPicture.png", data: qImageData!)
    
    var o1ImageData = NSData()
    let randInt = arc4random_uniform(2)
    if randInt == 0 {
        o1ImageData = UIImagePNGRepresentation(UIImage(named: "sadNate.png")!)!
    } else {
        o1ImageData = UIImagePNGRepresentation(UIImage(named: "sadBrett.png")!)!
    }
    let o1ImageFile: PFFile = PFFile(name: "option1Picture.png", data: o1ImageData)
    
    var o2ImageData = NSData()
    if randInt != 0 {
        o2ImageData = UIImagePNGRepresentation(UIImage(named: "happyNate.png")!)!
    } else {
        o2ImageData = UIImagePNGRepresentation(UIImage(named: "happyBrett.png")!)!
    }
    let o2ImageFile: PFFile = PFFile(name: "option2Picture.png", data: o2ImageData)
    
    noQsQuestionObject.setObject(qImageFile, forKey: "questionImageThumb")
    noQsQuestionObject.setObject(qImageFile, forKey: "questionImageFull")
    noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageThumb")
    noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageFull")
    noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageThumb")
    noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageFull")
    
    noQsQuestionObject.setObject(0, forKey: "option1Stats")
    noQsQuestionObject.setObject(0, forKey: "option2Stats")
    noQsQuestionObject.setObject(noQsAskerObject, forKey: "asker")
    
    noQsJoinObject.setObject(noQsQuestionObject, forKey: "question")
    
    noTheirQJoinObjects = noQsJoinObject
    
    // Update badge
    updateBadge("their")
    //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
}


func updateBadge(tabNumber: String) {
    
    if tabNumber == "my" {
        
        myQsBadgeCount = 0
        
        for obj in myQJoinObjects {
            if let _ = obj["vote"] as? Int { } else {
                myQsBadgeCount++
            }
        }
        // Update badge
        NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
        
        
    } else if tabNumber == "their" {
        
        theirQsBadgeCount = 0
        
        for obj in theirQJoinObjects {
            //print(obj)
            if let _ = obj["vote"] as? Int { } else {
                theirQsBadgeCount++
            }
        }
        // Update badge
        NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
    }
    
    // Set home screen badge when closing app
    let countSum = theirQsBadgeCount + myQsBadgeCount + theirVotesBadgeCount// + myVotesBadgeCount
    UIApplication.sharedApplication().applicationIconBadgeNumber = countSum
    
    // If home screen badge == 0 update parse badge
    // We can use this later to send period reminders that a user has activities waiting to be seen
    if countSum == 0 {
        PFInstallation.currentInstallation().badge = 0
    }
}


//func updateMainBadge(delta: Int) {
//    
//    print("Updating Main Badge")
//    
//    let currentInstallation = PFInstallation.currentInstallation()
//    if currentInstallation.badge + delta >= 0 {
//        currentInstallation.badge = currentInstallation.badge + delta
//    } else {
//        currentInstallation.badge = 0
//    }
//    currentInstallation.saveInBackground()
//}


// Sets globals, changes to custom NSUserDefault keys and fills that data in
// - Creates installation if user isNew (notifications)
func storeUserInfo(usernameToStore: String, isNew: Bool, completion: (Bool) -> Void) {
    
    // Store login information in globals
    username = usernameToStore.lowercaseString
//    uId = PFUser.currentUser()!.objectId!
    if let temp = PFUser.currentUser()!["name"] as? String {
        name = temp
    }
    
    // Set NSUserDefault storage keys
    usernameStorageKey  = username + "username"
    nameStorageKey      = username + "name"
    uIdStorageKey       = username + "uId"
//    myVoted1StorageKey  = username + "votedOn1Ids"
//    myVoted2StorageKey  = username + "votedOn2Ids"
//    myFriendsStorageKey = username + "myFriends"
    
    // Store user info on the phone
    NSUserDefaults.standardUserDefaults().setObject(username, forKey: usernameStorageKey)
    NSUserDefaults.standardUserDefaults().setObject(uId, forKey: uIdStorageKey)
    
    if isNew {
        
        // Set PFInstallation pointer to user table
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                print("New user data stored!")
                
            } else {
                
                print("Error storing new user data:")
                print(error)
                
            }
            
            completion(true)
        })
        
    } else {
        
        // If has name set, store it
        if name != "" {
            
            NSUserDefaults.standardUserDefaults().setObject(name, forKey: nameStorageKey)
        }
        
        print("Returning user data has been stored")
        completion(true)
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

