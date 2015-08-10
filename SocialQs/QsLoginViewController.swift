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
        
        blockUI(true, loginSpinner, loginBlurView, self)
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {(user: PFUser?, error: NSError?) -> Void in
            
            if let user = user { // facebook login successful
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    
                    getPersonalInfoFromFacebook() { (isFinished) -> Void in
                        
                        if isFinished {
                            
                            //Store user information locally
                            storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in
                                
                                self.performSegueWithIdentifier("signedIn", sender: self)
                                
                                blockUI(false, self.loginSpinner, self.loginBlurView, self)
                            })
                            
                            
                        } else {
                            
                            println("Could not gather FB info - logInViewController")
                        }
                    }
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    
                    self.signInCurrentUser()
                    
//                    ////////////////////////////////////////////////////////////////////////////
//                    //// GLOBAL FUNCTION - need to know how to use error handling before making
//                    // - Repeats in welcomeViewController
//                    // Get photo from parse
//                    if let pic = PFUser.currentUser()!["profilePicture"] as? PFFile {
//                        
//                        pic.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                            
//                            if error != nil {
//                                
//                                println("There was an error retrieving the users profile picture - loginController")
//                                println(error)
//                                
//                                profilePicture = UIImage(named: "profile.png")
//                                
//                            } else {
//                                
//                                if let downloadedImage = UIImage(data: data!) {
//                                    
//                                    profilePicture = downloadedImage
//                                    
//                                } else {
//                                    
//                                    profilePicture = UIImage(named: "profile.png")
//                                }
//                            }
//                            
//                            //Store user information locally
//                            storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in })
//                            
//                            self.performSegueWithIdentifier("signedIn", sender: self)
//                            
//                            blockUI(false, self.loginSpinner, self.loginBlurView, self)
//                        })
//                    }
//                    ////////////////////////////////////////////////////////////////////////////
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
                    
                    self.signInCurrentUser()
                    
                } else {
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    displayAlert("Failed Login", errorMessage, self)
                    
                    blockUI(false, self.loginSpinner, self.loginBlurView, self)
                }
            })
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    // MAKE GLOBAL - repeats in welcomeController with DIFFERENT SEGUE
    func signInCurrentUser() { // gets photo and stores username, uId, uQId, etc...
        
        // Check if profilePicture exists on Parse: if not, get from FB and upload to parse
        if let tempPic = PFUser.currentUser()!["profilePicture"] as? PFFile {
            
            println("1")
            
            tempPic.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    
                    println("NO ERROR")
                    
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
                
                //Store user information locally
                storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in
                    
                    self.performSegueWithIdentifier("signedIn", sender: self)
                    
                    blockUI(false, self.loginSpinner, self.loginBlurView, self)
                    
                })
            })
            
        } else if (PFUser.currentUser()!["profilePicture"] as? PFFile == nil) && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) == true {
            
            println("2")
            
            getPersonalInfoFromFacebook() { (isFinished) -> Void in
                
                if isFinished {
                    
                    storeUserInfo(PFUser.currentUser()!.username!, false) {
                        
                        (isFinished) -> Void in
                        
                        //Store user information locally
                        storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in
                            
                            self.performSegueWithIdentifier("signedIn", sender: self)
                            
                            blockUI(false, self.loginSpinner, self.loginBlurView, self)
                            
                        })
                    }
                    
                } else {
                    
                    println("Could not gather FB info - logInViewController")
                }
            }
            
        } else { // no image to be loaded
            println("3")
            
            profilePicture = UIImage(named: "profile.png")
            
            //Store user information locally
            storeUserInfo(PFUser.currentUser()!.username!, false, { (isFinished) -> Void in
                
                self.performSegueWithIdentifier("signedIn", sender: self)
                
                blockUI(false, self.loginSpinner, self.loginBlurView, self)
            })
        }
    }
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    
    
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
