//
//  LoginViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/16/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
//    var loginSpinner = UIActivityIndicatorView()
//    var loginBlurView = globalBlurView()
    var loginSpinner = UIView()
    var loginBlurView = globalBlurView()
    
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
        
        displaySpinnerView(spinnerActive: true, UIBlock: true, self.loginSpinner, self.loginBlurView, "Logging In", self)
        
        //blockUI(true, self.loginSpinner, self.loginBlurView, self)
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {(user: PFUser?, error: NSError?) -> Void in
            
            if let user = user {
                
                // Download FB data in background - backgrounding built into FBSDK methods (?)
                downloadFacebookFriends({ (isFinished) -> Void in
                    
                    if isFinished { println("FB Download completion handler executed") }
                })
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                        
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    getUsersFacebookInfo({ (isFinished) -> Void in // desired to complete before storing info
                        
                        self.performSegueWithIdentifier("signedIn", sender: self)
                        
                        displaySpinnerView(spinnerActive: false, UIBlock: false, self.loginSpinner, self.loginBlurView, nil, self)
                        
                        //blockUI(false, self.loginSpinner, self.loginBlurView, self)
                        
                        storeUserInfo(PFUser.currentUser()!.username!, true, { (isFinished) -> Void in })
                        
                        // USE IN SIGNUP ONLY FOR PRODUCTION APP
                        // USE IN SIGNUP ONLY FOR PRODUCTION APP
                        getUsersFacebookInfo({ (isFinished) -> Void in })
                        // USE IN SIGNUP ONLY FOR PRODUCTION APP
                        // USE IN SIGNUP ONLY FOR PRODUCTION APP
                    })
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    self.performSegueWithIdentifier("signedIn", sender: self)
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, self.loginSpinner, self.loginBlurView, nil, self)
                    
                    //blockUI(false, self.loginSpinner, self.loginBlurView, self)
                    
                    storeUserInfo(PFUser.currentUser()!.username!, true, { (isFinished) -> Void in })
                    
                    // USE IN SIGNUP ONLY FOR PRODUCTION APP
                    // USE IN SIGNUP ONLY FOR PRODUCTION APP
                    getUsersFacebookInfo({ (isFinished) -> Void in })
                    // USE IN SIGNUP ONLY FOR PRODUCTION APP
                    // USE IN SIGNUP ONLY FOR PRODUCTION APP
                }
                
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                
                displaySpinnerView(spinnerActive: false, UIBlock: false, self.loginSpinner, self.loginBlurView, nil, self)
                
                //blockUI(false, self.loginSpinner, self.loginBlurView, self)
                
                self.navigationController?.navigationBarHidden = false
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
            
            displaySpinnerView(spinnerActive: true, UIBlock: true, self.loginSpinner, self.loginBlurView, "Logging In", self)
            
            //blockUI(true, self.loginSpinner, self.loginBlurView, self)
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            // Run Parse.com login procedure
            PFUser.logInWithUsernameInBackground(usernameTextField.text.lowercaseString, password: passwordTextField.text, block: { (user, error) -> Void in
                
                if user != nil { // standard login successful
                    
                    if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                        
                        // Download FB data in background - backgrounding built into FBSDK methods (?)
                        downloadFacebookFriends({ (isFinished) -> Void in
                            
                            if isFinished { println("FB Download completion handler executed") }
                        })
                    }
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    //Store user information locally
                    storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in
                        
                        self.performSegueWithIdentifier("signedIn", sender: self)
                        
                        displaySpinnerView(spinnerActive: false, UIBlock: false, self.loginSpinner, self.loginBlurView, nil, self)
                        
                        //blockUI(false, self.loginSpinner, self.loginBlurView, self)
                        
                    })
                    
                } else {
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    displayAlert("Failed Login", errorMessage, self)
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, self.loginSpinner, self.loginBlurView, nil, self)
                    
                    //blockUI(false, self.loginSpinner, self.loginBlurView, self)
                }
            })
        }
    }
    
    
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
        
//        // Recall myName if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(usernameStorageKey) != nil {
//            
//            username = NSUserDefaults.standardUserDefaults().objectForKey(usernameStorageKey)! as! String
//        }
//        
//        // Recall name if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(nameStorageKey) != nil {
//            println(nameStorageKey)
//            name = NSUserDefaults.standardUserDefaults().objectForKey(nameStorageKey)! as! String
//        }
//        
//        // Recall uId if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(uIdStorageKey) != nil {
//            
//            uId = NSUserDefaults.standardUserDefaults().objectForKey(uIdStorageKey)! as! String
//        }
//        
//        // Recall uQId if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(uQIdStorageKey) != nil {
//            
//            uQId = NSUserDefaults.standardUserDefaults().objectForKey(uQIdStorageKey)! as! String
//        }
//        
//        // Recall votedOnIds if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey) != nil {
//            
//            votedOn1Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey)! as! [String]
//        }
//        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey) != nil {
//            
//            votedOn2Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey)! as! [String]
//        }
//        
//        // Recall myFriends if applicable
//        if NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey) != nil {
//            
//            myFriends = NSUserDefaults.standardUserDefaults().objectForKey(myFriendsStorageKey)! as! [String]
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
