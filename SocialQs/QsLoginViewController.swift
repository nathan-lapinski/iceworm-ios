//
//  QsLoginViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/16/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class QsLoginViewController: UIViewController {
    
    var loginSpinner = UIActivityIndicatorView()
    var loginBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginFacebookButton: UIButton!
    @IBOutlet var logoVerticalSpace: NSLayoutConstraint!
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        performSegueWithIdentifier("cancelLogIn", sender: self)
    }
    
    @IBAction func loginFacebookButtonPressed(sender: AnyObject) {
        
        blockUI(true, loginSpinner, loginBlurView, self)
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {(user: PFUser?, error: NSError?) -> Void in
            
            if let user = user { // facebook login successful
                
                //Store user information locally
                storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in })
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    
                } else {
                    
                    println("User logged in through Facebook!")
                }
            
                getPersonalInfoFromFacebook() { (isFinished) -> Void in
                    
                    if isFinished {
                        
                        self.performSegueWithIdentifier("signedIn", sender: self)
                        
                        blockUI(false, self.loginSpinner, self.loginBlurView, self)
                        
                    } else {
                        
                        println("Could not gather FB info - logInViewController")
                    }
                }
                
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                
                self.navigationController?.navigationBarHidden = false
                
                blockUI(false, self.loginSpinner, self.loginBlurView, self)
            }
        }
    }
    
    // This function processes the login procedure
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // Error out with pop-up if username and/or password are missing
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert("Way to go Rain Man", "I think you forgot something. Please enter a username and password.", self)
            
        } else {
            
            blockUI(true, self.loginSpinner, self.loginBlurView, self)
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            // Run Parse.com login procedure
            PFUser.logInWithUsernameInBackground(usernameTextField.text.lowercaseString, password: passwordTextField.text, block: { (user, error) -> Void in
                
                if user != nil { // standard login successful
                    
                    self.performSegueWithIdentifier("signedIn", sender: self)
                    
                    //Store user information locally
                    storeUserInfo(self.usernameTextField.text, false, { (isFinished) -> Void in })
                    
                } else {
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    displayAlert("Failed Login", errorMessage, self)
                }
                
                blockUI(false, self.loginSpinner, self.loginBlurView, self)
            })
        }
    }
    
    
//    func storeUserInfo(username: String) {
//        
//        // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
//        // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
//        myName = username.lowercaseString
//        uId = PFUser.currentUser()!.objectId!
//        uQId = PFUser.currentUser()?["uQId"]! as! String
//        
//        // Store username locally
//        NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
//        NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
//        NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
//        
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
//            }
//        })
//        
//        // Set PFInstallation pointer to user table
//        let installation = PFInstallation.currentInstallation()
//        installation["user"] = PFUser.currentUser()
//        installation.saveInBackground()
//        // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
//        // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = cornerRadius
        
        // Hide nav bar when keyboard present
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = true
        navigationController?.hidesBarsWhenKeyboardAppears = true
        
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Recall myName if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey(usernameStorageKey) != nil {
            
            username = NSUserDefaults.standardUserDefaults().objectForKey(usernameStorageKey)! as! String
        }
        
        // Recall name if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey(nameStorageKey) != nil {
            
            name = NSUserDefaults.standardUserDefaults().objectForKey(nameStorageKey)! as! String
        }
        
        // Recall uId if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey(uIdStorageKey) != nil {
            
            uId = NSUserDefaults.standardUserDefaults().objectForKey(uIdStorageKey)! as! String
        }
        
        // Recall uQId if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey(uQIdStorageKey) != nil {
            
            uQId = NSUserDefaults.standardUserDefaults().objectForKey(uQIdStorageKey)! as! String
        }
        
        // Recall votedOnIds if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey) != nil {
            
            votedOn1Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey)! as! [String]
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey) != nil {
            
            votedOn2Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey)! as! [String]
        }
        
//        // Recall myVotes if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey("myVotes") != nil {
//            
//            myVotes = NSUserDefaults.standardUserDefaults().objectForKey("myVotesStorageKey")! as! Dictionary
//            
//        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
    }
    
    // Hide keyboard when touching outside keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
