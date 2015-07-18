//
//  UserActivites.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/17/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import Foundation

func displayAlert(title: String, message: String, sender: UIViewController) {
    
    var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }))
    
    // Delay view of ViewController until next loop to prevent:
    // "Warning: Attempt to present UIALertController on xViewController
    //           whose view is not in the window hierarchy!"
    dispatch_async(dispatch_get_main_queue(), {
        
        sender.presentViewController(alert, animated: true, completion: nil)
        warningSeen = true
    })
}

func getProfilePicture() -> UIImage {
    
    //var profilePicture = UIImage()// moved to globals
    
    // PULL IMAGE FROM PARSE IF EXISTS
    if let userPicture = PFUser.currentUser()?["profilePic"] as? PFFile {
        
        println("Retrieving image from Parse")
        
        userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            
            if ((error) == nil) {
                
                profilePicture = UIImage(data:imageData!)!
            }
        }
        
    } else {
        
        // Get image from FB
        var accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        var url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + accessToken)
        let urlRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            // Set app iamge
            profilePicture = UIImage(data: data)!
            
            // Store image in Parse
            var user = PFUser.currentUser()
            let imageData = UIImagePNGRepresentation(profilePicture)
            let parseProfilePicture = PFFile(name:"profilePicture.png", data: imageData)
            user!.setObject(parseProfilePicture, forKey: "profilePicture")
            
            user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    
                    println("image saved successfully")
                    
                } else {
                    
                    println("image not saved")
                }
            })
        }
    }
    
    return profilePicture
}

/*
func storeLocal() { // Currently has no inputs, uses globals
    
    // NSUserDefaults Storage Keys
    let myVoted1StorageKey = myName + "votedOn1Ids"
    let myVoted2StorageKey = myName + "votedOn2Ids"
    var myVotesStorageKey = myName + "votes"
    var profilePictureKey = myName + "profilePicture"
    
    // Store actual data - during: login, signup, loginSkip (from welcomeViewController)
    //if...
    
    //if...
    //.
    //.
    //.
    
    
}
*/




