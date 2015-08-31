//
//  SignupViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    
    var newUsername = ""
    
//    var signupSpinner = UIActivityIndicatorView()
//    var signupBlurView = globalBlurView()
    var signupSpinner = UIView()
    var signupBlurView = globalBlurView()
    
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
                
                displaySpinnerView(spinnerActive: true, UIBlock: true, self.signupSpinner, self.signupBlurView, "Logging In", self)
                
                //blockUI(true, self.signupSpinner, self.signupBlurView, self)
                
                // Download socialQs friends
                downloadSocialQsFriends({ (isFinished) -> Void in })
                
                // Download groups
                downloadGroups({ (isFinished) -> Void in })
                
                // Download FB data in background - backgrounding built into FBSDK methods (?)
                downloadFacebookFriends({ (isFinished) -> Void in
                    
                    if isFinished { println("FB Download completion handler executed") }
                })
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
//                    // Create entry in UserQs table
//                    createUserQs(PFUser.currentUser()!.username!, { (isFinished) -> Void in // desired to complete before storing info
//                        
//                        if isFinished {
//                            
//                        } else {
//                            
//                            displayAlert("Unable to create account", "Please check your internet connection and try again!", self)
//                        }
//                    })
                    
                    getUsersFacebookInfo({ (isFinished) -> Void in // desired to complete before storing info
                        
                        self.performSegueWithIdentifier("signedUp", sender: self)
                        
                        displaySpinnerView(spinnerActive: false, UIBlock: false, self.signupSpinner, self.signupBlurView, nil, self)
                        
                        //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                        
                        storeUserInfo(PFUser.currentUser()!.username!, true, { (isFinished) -> Void in })
                        
                        getUsersFacebookInfo({ (isFinished) -> Void in })
                    })
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    self.performSegueWithIdentifier("signedUp", sender: self)
                    
                    if let groups = PFUser.currentUser()!["myGroups"] as? [String] {
                        myGroups = groups
                    }
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, self.signupSpinner, self.signupBlurView, nil, self)
                    
                    //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                    
                    storeUserInfo(PFUser.currentUser()!.username!, true, { (isFinished) -> Void in })
                    
                    getUsersFacebookInfo({ (isFinished) -> Void in })
                }
                
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                
                displaySpinnerView(spinnerActive: false, UIBlock: false, self.signupSpinner, self.signupBlurView, nil, self)
                
                //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                
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
            
            displaySpinnerView(spinnerActive: true, UIBlock: true, self.signupSpinner, self.signupBlurView, "Logging In", self)
            
            //blockUI(true, self.signupSpinner, self.signupBlurView, self)
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            // Create user account on Parse.com
            var user = PFUser()
            
            user.username = username.text.lowercaseString
            user.password = password.text
            user.email = emailAddress.text.lowercaseString
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil { // Signup successful!
                    
//                    // This is run on the background queue //
//                    // Create entry in UserQs table
//                    createUserQs(self.username.text, { (isFinished) -> Void in
//                        
//                        if isFinished {
//                            
//                        } else {
//                            
//                            displayAlert("Unable to create account", "Please check your internet connection and try again!", self)
//                        }
//                    })
                    
                    storeUserInfo(self.username.text.lowercaseString, true, { (isFinished) -> Void in
                        
                        self.performSegueWithIdentifier("signedUpWithoutFacebook", sender: self)
                        
                        displaySpinnerView(spinnerActive: false, UIBlock: false, self.signupSpinner, self.signupBlurView, "Signing Up", self)
                        
                        //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                    })
                    
                } else { // Signup failed
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, self.signupSpinner, self.signupBlurView, nil, self)
                    
                    //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                    
                    displayAlert("Failed Signup", errorMessage, self)
                }
            })
        }
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
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
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
