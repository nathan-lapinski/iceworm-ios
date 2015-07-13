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
    
    @IBAction func signInButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signIn", sender: self)
        
    }
    
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        
        if warningSeen == false {
            
            let title = "DATA USAGE"
            let message = "SocialQs has not yet been optimized for data usage and it is unclear how much data the app will transfer with the implementation of images. If your data plan is limited you may wish to limit your SocialQs usage to Wi-Fi only until this issue is investigated."
            self.displayAlert(title, message: message)
        }
        
        
        signInButton.layer.cornerRadius = cornerRadius
        createAccountButton.layer.cornerRadius = cornerRadius
        
    }
    
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        // Delay view of ViewController until next loop to prevent:
        // "Warning: Attempt to present UIALertController on xViewController 
        //           whose view is not in the window hierarchy!"
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
            warningSeen = true
        })
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
            // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
            // login successful
            myName = PFUser.currentUser()!.username!
            uId = PFUser.currentUser()!.objectId!
            uQId = PFUser.currentUser()?["uQId"]! as! String
            
            // Store username locally
            NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
            NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
            NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
            
            // Store votedOnIds locally
            votedOn1Ids.removeAll(keepCapacity: true)
            votedOn2Ids.removeAll(keepCapacity: true)
            
            var userQsQuery = PFQuery(className: "UserQs")
            
            userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
                
                if error != nil {
                    
                    println("Error loading UserQs/votedOnId")
                    println(error)
                    
                } else {
                    
                    println("%%%%%%%%%%%")
                    println(userQsObjects)
                    println("%%%%%%%%%%%")
                    
                    if let votedOn1Id = userQsObjects!["votedOn1Id"] as? [String] {
                        
                        votedOn1Ids = votedOn1Id
                        
                        NSUserDefaults.standardUserDefaults().setObject(votedOn1Ids, forKey: myVoted1StorageKey)
                    }
                    
                    if let votedOn2Id = userQsObjects!["votedOn2Id"] as? [String] {
                        
                        votedOn2Ids = votedOn2Id
                        
                        NSUserDefaults.standardUserDefaults().setObject(votedOn2Ids, forKey: myVoted2StorageKey)
                    }
                    
                    
                    // Set PFInstallation pointer to user table
                    let installation = PFInstallation.currentInstallation()
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackground()
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    
                    // Add user-specific channel to installation
                    //installation.addUniqueObject(myName, forKey: "channels")
                    //installation.saveInBackground()
                    
                    self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                }
            })
        }
        
        // ANIMATION STUFFS -------------------------------------------------------------
        /*
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            //self.logoVerticalSpace.constant = -100
            //self.logoImageView.layoutIfNeeded()
            
            //self.logoImageView.center = CGPointMake(self.logoImageView.center.x, self.logoImageView.center.y - 75)
            
            //self.username.center = CGPointMake(self.username.center.x+self.view.bounds.width, self.username.center.y)
            //self.password.center = CGPointMake(self.password.center.x-self.view.bounds.width, self.password.center.y)
            
            }, completion: { finished in
                
                UIView.animateWithDuration(1.5, delay: 1.0, options: nil, animations: { () -> Void in
                    
                    //self.loginButton.alpha = 1.0
                    //self.registeredTextField.alpha = 1.0
                    //self.signupButton.alpha = 1.0
                    
                    }, completion: { finished in
                        
                        println("Animation finished")
                        //self.loginButton.alpha = 1.0
                        
                })
        })
        */
        // ANIMATION STUFFS -------------------------------------------------------------
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
