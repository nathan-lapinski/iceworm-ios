//
//  WelcomeViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var logoTopConstraint: NSLayoutConstraint!
    
    @IBAction func signInButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signIn", sender: self)
    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        
        /*
        if warningSeen == false {
            
            let title = "DATA USAGE"
            let message = "SocialQs has not yet been optimized for data usage and it is unclear how much data the app will transfer with the implementation of images. If your data plan is limited you may wish to limit your SocialQs usage to Wi-Fi only until this issue is investigated."
            displayAlert(title, message, self)
        }
        */
        
        signInButton.layer.cornerRadius = cornerRadius
        createAccountButton.layer.cornerRadius = cornerRadius
        
        //signInButton.hidden = true
        //createAccountButton.hidden = true
        
        // ANIMATION STUFFS -------------------------------------------------------------
        logoTopConstraint.constant = 0
        logoImageView.layoutIfNeeded()
        signInButton.alpha = 0.0
        createAccountButton.alpha = 0.0
        
        UIView.animateWithDuration(1.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            println("animating")
            
            self.logoTopConstraint.constant = -70
            self.logoImageView.layoutIfNeeded()
            
            }, completion: { finished in
                
        })
        
        UIView.animateWithDuration(1.5, delay: 1.0, options: nil, animations: { () -> Void in
            
            self.signInButton.alpha = 1.0
            self.createAccountButton.alpha = 1.0
            
            }, completion: { finished in
                
        })
        // ANIMATION STUFFS -------------------------------------------------------------
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            //
            //
            // **** Only this this if these are not already stored for the CURRENT USER ****
            //
            //
            // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
            // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
            // login successful
            myName = PFUser.currentUser()!.username!
            uId = PFUser.currentUser()!.objectId!
            uQId = PFUser.currentUser()?["uQId"]! as! String
            
            
            // PUT IN GLOBAL FUNCTION ------------------------------
            // Get My Info facebook info and set my name
            var meRequest = FBSDKGraphRequest(graphPath:"/me", parameters: nil);
            
            meRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                if error == nil {
                    name = result["name"]!! as! String
                } else {
                    println("Error Getting Friends \(error)");
                }
            }
            // PUT IN GLOBAL FUNCTION ------------------------------
            
            
            // Get profile picture
            if let userPicture = PFUser.currentUser()?["profilePicture"] as? PFFile {
                
                println("Retrieving image from Parse")
                
                userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error) == nil) {
                        
                        println("Retrieving profile picture")
                        profilePicture = UIImage(data:imageData!)!
                    }
                }
            }
            
            // Store username locally
            NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
            NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
            NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
            //NSUserDefaults.standardUserDefaults().setObject(profilePicture, forKey: profilePictureKey)
            
            // Set PFInstallation pointer to user table
            let installation = PFInstallation.currentInstallation()
            installation["user"] = PFUser.currentUser()
            installation.saveInBackground()
            // Add user-specific channel to installation
            //installation.addUniqueObject(myName, forKey: "channels")
            //installation.saveInBackground()
            
            // **** ALWAYS do this in case these have been updated by another device
            // Store votedOnIds locally
            votedOn1Ids.removeAll(keepCapacity: true)
            votedOn2Ids.removeAll(keepCapacity: true)
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
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    
                    
                    self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                }
            })
            
        } else {
            
            signInButton.hidden = false
            createAccountButton.hidden = false
        }
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
