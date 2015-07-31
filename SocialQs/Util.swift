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
    
    //var activityIndicator = UIActivityIndicatorView()
    
    // Blur screen while Q upload is processing
    //let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    //var blurView = UIVisualEffectView(effect: blurEffect)
    
    if block == true {
        
        println("Blocking UI")
        
        // Add blur view
        _blurView.frame = sender.view.frame
        sender.view.addSubview(_blurView)
        
        // Setup and start spinner
        //_activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
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
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }))
    
    // Delay view of ViewController until next loop to prevent:
    // "Warning: Attempt to present UIALertController on xViewController
    //           whose view is not in the window hierarchy!"
    
    
    
    //dispatch_async(dispatch_get_main_queue(), {
        
        sender.presentViewController(alert, animated: true, completion: nil)
    //})
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
        
        // Set app iamge
        let image = UIImage(data: data)
        profilePicture = image!
        
        // Download data in background queue
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            var user = PFUser.currentUser()
            let imageData = UIImagePNGRepresentation(image)
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




