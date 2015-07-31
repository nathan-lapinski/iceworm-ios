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
    @IBOutlet var logInButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet var logInButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet var createAccountButtonRightContraint: NSLayoutConstraint!
    @IBOutlet var createAccountButtonLeftContraint: NSLayoutConstraint!
    
    @IBAction func signInButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signIn", sender: self)
    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.hidden = true
        createAccountButton.hidden = true
        
        //let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        
        //signInButton.layer.cornerRadius = cornerRadius
        //createAccountButton.layer.cornerRadius = cornerRadius
        
        //signInButton.hidden = true
        //createAccountButton.hidden = true
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            signInCurrentUser()
            
        } else {
            
            signInButton.hidden = false
            createAccountButton.hidden = false
            
            // ANIMATION STUFFS -------------------------------------------------------------
            logoTopConstraint.constant = 0
            logoImageView.layoutIfNeeded()
            
            signInButton.alpha = 0.0
            createAccountButton.alpha = 0.0
            logInButtonRightConstraint.constant = self.view.frame.width / 2 - 10
            logInButtonLeftConstraint.constant = self.view.frame.width / 2 - 10
            signInButton.enabled = false
            signInButton.layoutIfNeeded()
            
            createAccountButtonRightContraint.constant = self.view.frame.width / 2 - 10
            createAccountButtonLeftContraint.constant = self.view.frame.width / 2 - 10
            createAccountButton.enabled = false
            createAccountButton.layoutIfNeeded()
            
            UIView.animateWithDuration(2.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.logoTopConstraint.constant = -70
                self.logoImageView.layoutIfNeeded()
                
                }, completion: { finished in
            })
            
            UIView.animateWithDuration(1.8, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.createAccountButtonRightContraint.constant = 22
                self.createAccountButtonLeftContraint.constant = 21
                self.createAccountButton.layoutIfNeeded()
                self.createAccountButton.alpha = 1.0
                
                }, completion: { finished in
                    
                    self.createAccountButton.enabled = true
            })
            
            UIView.animateWithDuration(1.8, delay: 0.9, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.logInButtonRightConstraint.constant = 22
                self.logInButtonLeftConstraint.constant = 21
                self.signInButton.layoutIfNeeded()
                self.signInButton.alpha = 1.0
                
                }, completion: { finished in
                    
                    self.signInButton.enabled = true
            })
            // ANIMATION STUFFS -------------------------------------------------------------
        }
    }
    
    
    func signInCurrentUser() {
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
      
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            
            getPersonalInfoFromFacebook() { (isFinished) -> Void in
                
                if isFinished {
                    
                } else {
                    
                    println("Could not gather FB info - welcomeViewController")
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
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
