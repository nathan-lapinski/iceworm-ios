//
//  QsSignupViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class QsSignupViewController: UIViewController {
    
    var newUsername = ""
    
    var signupSpinner = UIActivityIndicatorView()
    var signupBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordConfirm: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signUpFacebookButton: UIButton!
    
    @IBAction func signUpFacebookButtonPressed(sender: AnyObject) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {(user: PFUser?, error: NSError?) -> Void in
            
            if let user = user {
                
                blockUI(true, self.signupSpinner, self.signupBlurView, self)
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    
                    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
                    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                    
                    dispatch_async(backgroundQueue, {
                        
                        // This is run on the background queue //
                        // Create entry in UserQs table
                        self.createUserQs(self.username.text)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // This is run on the main queue, after the previous code in outer block //
                            
                            self.performSegueWithIdentifier("signedUp", sender: self)
                            
                            blockUI(false, self.signupSpinner, self.signupBlurView, self)
                        })
                    })
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    
                    self.performSegueWithIdentifier("signedUpWithoutFacebook", sender: self)
                    
                    blockUI(false, self.signupSpinner, self.signupBlurView, self)
                }
                
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                
                blockUI(false, self.signupSpinner, self.signupBlurView, self)
                
                self.navigationController?.navigationBarHidden = false
            }
        }
    }
    
    
    // This function processes the login procedure
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        // Error out with pop-up if username and/or password are missing
        if username.text == "" || password.text == "" || passwordConfirm.text == "" || emailAddress.text == "" {
            
            displayAlert("WTF, mate", "It's not that hard. Just enter a username, password and email address!", self)
            
        } else if isValidEmail(emailAddress.text!) == false {
            
            displayAlert("Don't be a tool.", "Please enter a valid email address (hint: this will allow you to find your friends)", self)
            
        } else if password.text != passwordConfirm.text {
            
            displayAlert("Way to go, fat fingers.", "Maybe try typing the same password twice", self)
            
        } else {
            
            blockUI(true, self.signupSpinner, self.signupBlurView, self)
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            // Create user account on Parse.com
            var user = PFUser()
            
            user.username = username.text.lowercaseString
            user.password = password.text
            user.email = emailAddress.text.lowercaseString
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil { // Signup successful!
                    
                    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
                    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                    
                    dispatch_async(backgroundQueue, {
                        
                        // This is run on the background queue //
                        // Create entry in UserQs table
                        self.createUserQs(self.username.text)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // This is run on the main queue, after the previous code in outer block //
                            
                            // Segue "ask" tab
                            self.performSegueWithIdentifier("signedUpWithoutFacebook", sender: self)
                        })
                    })
                    
                } else { // Signup failed
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    blockUI(false, self.signupSpinner, self.signupBlurView, self)
                    
                    displayAlert("Failed Signup", errorMessage, self)
                }
            })
        }
    }
    
    
    func createUserQs(username: String) {
        
        // Create UsersQs entry
        var userQ = PFObject(className: "UserQs")
        userQ.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                var userQId = userQ.objectId!
                
                // Store userQ enrty identifier back in Users table
                var user = PFUser.currentUser()
                user!.setObject(userQId, forKey: "uQId")
                user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if error == nil {
                        
//                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
//                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
//                        myName = username.lowercaseString
//                        uId = user!.objectId!
//                        uQId = userQ.objectId!
//                        
//                        // Store username locally
//                        NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
//                        NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
//                        NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
//                        
//                        let installation = PFInstallation.currentInstallation()
//                        installation["user"] = PFUser.currentUser()
//                        installation.saveInBackground()
//                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
//                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                        
                        storeUserInfo(username.lowercaseString, true, { (isFinished) -> Void in
                            
                            blockUI(false, self.signupSpinner, self.signupBlurView, self)
                        })
                        
                        
                    } else {
                        
                        println("Error storing uQId to UserQs table")
                        println(error)
                    }
                })
                
            } else {
                
                println("Error creating UserQs entry for new user")
                println(error)
            }
        })
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        username.text = ""
        password.text = ""
        passwordConfirm.text = ""
        emailAddress.text = ""
        
        username.resignFirstResponder()
        password.resignFirstResponder()
        passwordConfirm.resignFirstResponder()
        emailAddress.resignFirstResponder()
        
        performSegueWithIdentifier("cancelSignUp", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatButton(signUpButton)
        //signUpButton.layer.cornerRadius = cornerRadius
        
        // Hide nav bar when keyboard present
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = true
        navigationController?.hidesBarsWhenKeyboardAppears = true
        
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Hide keyboard when touching outside keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
