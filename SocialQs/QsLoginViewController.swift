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
    
    var activityIndicator = UIActivityIndicatorView()
    var signUpActive = false
    
    @IBOutlet var loginCancelled: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var registeredTextField: UILabel!
    
    @IBOutlet var logoVerticalSpace: NSLayoutConstraint!
    
    @IBAction func facebookLoginButton(sender: AnyObject) {
        
        self.loginCancelled.hidden = true
        
        var permissions = ["public_profile", "email"]//, "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let user = user {
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("signUp", sender: self)
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    // Pre-existing user
                    self.performSegueWithIdentifier("signUp", sender: self)
                    
                }
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                self.loginCancelled.hidden = false
                
            }
        }

        
    }
    
    // This function switches the login page between "login" and "signup"
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        if signUpActive == true {
            
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredTextField.text = "Not Registered?"
            signUpActive = false
            
        } else {
            
            signupButton.setTitle("Login", forState: UIControlState.Normal)
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredTextField.text = "Already Registered?"
            signUpActive = true
            
        }
        
    }
    
    // This function processes the login procedure
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        // Error out with pop-up if username and/or password are missing
        if username.text == "" || password.text == "" {
            
            displayAlert("Error", message: "Please enter a username and password")
            
        } else {
            
            // Setup spinner and block application input
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 200, 200))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            if signUpActive == true { // this means the signup was actually function as SIGNUP
                
                // Create user account on Parse.com
                var user = PFUser()
                user.username = username.text.lowercaseString
                user.password = password.text
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    // Stop animation - hides when stopped (above) hides spinner automatically
                    self.activityIndicator.stopAnimating()
                    
                    // Release app input block
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // Signup successful!
                        myName = self.username.text.lowercaseString
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        
                        // Signup failed
                        if let errorString = error!.userInfo?["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("Failed Signup", message: errorMessage)
                        
                    }
                    
                })
                
            } else { // This means "signupButton" is functioning as login
                
                // Run Parse.com login procedure
                PFUser.logInWithUsernameInBackground(username.text.lowercaseString, password: password.text, block: { (user, error) -> Void in
                    
                    // Stop animation - hides when stopped (above) hides spinner automatically
                    self.activityIndicator.stopAnimating()
                    
                    // Release app input
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        // login successful
                        myName = self.username.text.lowercaseString
                        println("Welcome " + myName)
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        
                        if let errorString = error!.userInfo?["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("Failed Login", message: errorMessage)
                        
                    }
                })
            }
        }
    }
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            // idk why this was in teh tutorial... causes a revert to previous view controller
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        var push = PFPush()
        push.setMessage("This is a test Push")
        push.sendPushInBackgroundWithBlock { (isSuccessful, error) -> Void in
            println("Successful Push")
        }
        */
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Format buttons
        loginButton.layer.cornerRadius = cornerRadius
        loginButton.backgroundColor = bgColor
        signupButton.layer.cornerRadius = cornerRadius
        signupButton.backgroundColor = bgColor
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        //self.logoVerticalSpace.constant = 0
        //self.logoImageView.layoutIfNeeded()
        
        /*
        logoImageView.center = CGPointMake(view.bounds.width/2, logoImageView.center.y)
        username.center = CGPointMake(username.center.x-view.bounds.width, username.center.y)
        password.center = CGPointMake(password.center.x+view.bounds.width, password.center.y)
        
        registeredTextField.alpha = 0.0
        signupButton.alpha = 0.0
        */
        //loginButton.alpha = 0.0
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil && myName != "" {
            
            // Not part of test env
            myName = (PFUser.currentUser()!.username!)
            println("Welcome " + myName)
            self.performSegueWithIdentifier("login", sender: self)
            
        }
        
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
    }
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        // Dispose of any resources that can be recreated.
    }

}
