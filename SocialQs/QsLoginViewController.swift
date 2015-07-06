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
    //var signUpActive = false
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    //@IBOutlet var registeredTextField: UILabel!
    @IBOutlet var logoVerticalSpace: NSLayoutConstraint!
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        username.text = ""
        password.text = ""
        
        username.resignFirstResponder()
        password.resignFirstResponder()
        
        performSegueWithIdentifier("cancelLogIn", sender: self)
        
    }
    
    
    // This function processes the login procedure
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        // Error out with pop-up if username and/or password are missing
        if username.text == "" || password.text == "" {
            
            displayAlert("Way to go Rain Man", message: "I think you forgot something. Please enter a username and password.")
            
        } else {
            
            // Setup spinner and block application input
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // Generic error - this will be changed below based on error returned from Parse.com
            var errorMessage = "Please try again later"
            
            // Run Parse.com login procedure
            PFUser.logInWithUsernameInBackground(username.text.lowercaseString, password: password.text, block: { (user, error) -> Void in
                
                // Stop animation - hides when stopped (above) hides spinner automatically
                self.activityIndicator.stopAnimating()
                
                // Release lock on app input
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                    
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    // login successful
                    myName = self.username.text.lowercaseString
                    uId = PFUser.currentUser()!.objectId!
                    uQId = PFUser.currentUser()?["uQId"]! as! String
                    
                    // Store username locally
                    NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
                    NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
                    NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    // MAKE GLOBAL FUNCTION (repeats in QsSignUpViewController ------------
                    
                    let installation = PFInstallation.currentInstallation()
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackground()
                    
                    self.performSegueWithIdentifier("signedIn", sender: self)
                    
                } else {
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                        
                    }
                    
                    self.displayAlert("Failed Login", message: errorMessage)
                    
                }
            })
        }
    }
    
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = cornerRadius
        cancelButton.layer.cornerRadius = cornerRadius
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Recal myName if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey("myName") != nil {
            
            myName = NSUserDefaults.standardUserDefaults().objectForKey("myName")! as! String
            
        }
        
        // Recal uId if applicable
        if NSUserDefaults.standardUserDefaults().objectForKey("uId") != nil {
            
            myName = NSUserDefaults.standardUserDefaults().objectForKey("uId")! as! String
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        /*
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil && myName != "" {
            
            // Not part of test env
            myName = (PFUser.currentUser()!.username!)
            //println("Welcome " + myName)
            
            self.performSegueWithIdentifier("signedIn", sender: self)
            
        }
        */
        
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
