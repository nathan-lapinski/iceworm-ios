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
    
    var activityIndicator = UIActivityIndicatorView()
    //var signUpActive = false
    
    //@IBOutlet var logoImageView: UIImageView!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordConfirm: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    
    // This function processes the login procedure
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        // Error out with pop-up if username and/or password are missing
        if username.text == "" || password.text == "" || passwordConfirm.text == "" || emailAddress.text == "" {
            
            displayAlert("WTF, mate", message: "It's not that hard. Just enter a username, password and email address!")
            
        } else if isValidEmail(emailAddress.text!) == false {
            
            displayAlert("Don't be a tool.", message: "Please enter a valid email address (hint: this will allow you to find your friends)")
            
        } else if password.text != passwordConfirm.text {
            
            displayAlert("Way to go, fat fingers.", message: "Maybe try typing the same password twice")
            
            // ALREADY IN PLACE THROUGH PARSE ------
            //} else if EMAIL ALREADY USED {
            //} else if USERNAME ALREADY USED {
            // ALREADY IN PLACE THROUGH PARSE ------
            
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
            
            // Create user account on Parse.com
            var user = PFUser()
            
            user.username = username.text.lowercaseString
            user.password = password.text
            user.email = emailAddress.text.lowercaseString
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil { // Signup successful!
                    
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
                                    
                                    //println("User table successfully updated")
                                    
                                    // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                                    // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                                    myName = self.username.text.lowercaseString
                                    uId = user!.objectId!
                                    uQId = userQ.objectId!
                                    
                                    // Store username locally
                                    NSUserDefaults.standardUserDefaults().setObject(myName, forKey: "myName")
                                    NSUserDefaults.standardUserDefaults().setObject(uId, forKey: "uId")
                                    NSUserDefaults.standardUserDefaults().setObject(uQId, forKey: "uQId")
                                    // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                                    // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                                    
                                    // Stop animation - hides when stopped (above) hides spinner automatically
                                    self.activityIndicator.stopAnimating()
                                    
                                    // Release app input block
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                                                        
                                    let installation = PFInstallation.currentInstallation()
                                    installation["user"] = PFUser.currentUser()
                                    installation.saveInBackground()
                                    
                                    // Segue "ask" tab
                                    self.performSegueWithIdentifier("signedUp", sender: self)
                                    
                                } else {
                                    
                                }
                                
                            })
                            
                        } else {
                            
                            println(error)
                            
                        }
                    })
                    
                } else { // Signup failed
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                        
                    }
                    
                    
                    // Stop animation - hides when stopped (above) hides spinner automatically
                    self.activityIndicator.stopAnimating()
                    
                    // Release app input block
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    self.displayAlert("Failed Signup", message: errorMessage)
                    
                }
            })
        }
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
        
        signUpButton.layer.cornerRadius = cornerRadius
        cancelButton.layer.cornerRadius = cornerRadius
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Hide keyboard when touching outside keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
