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
    var newUsername = ""
    
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
                
                // Setup spinner and block application input
                self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
                self.activityIndicator.center = self.view.center
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
                self.view.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                // Blur screen while account processing
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                let blurView = UIVisualEffectView(effect: blurEffect)
                blurView.frame = self.view.frame
                self.view.addSubview(blurView)
                
                if user.isNew {
                    
                    println("User signed up and logged in through Facebook!")
                    
                    // MAKE FUNCTION -----------------------------------------------------
                    // repeats in setting
                    // MAKE FUNCTION -----------------------------------------------------
                    // Get profile pic from FB and store it locally (var) and on Parse
                    var accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    var url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + accessToken)
                    let urlRequest = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                        
                        // Set app iamge
                        let image = UIImage(data: data)
                        profilePicture = image!
                        
                        // Store image in Parse DB
                        //
                        // CHECK IF ALREADY EXISTS ON PARSE
                        //
                        var user = PFUser.currentUser()
                        let imageData = UIImagePNGRepresentation(image)
                        let picture = PFFile(name:"profilePicture.png", data: imageData)
                        user!.setObject(picture, forKey: "profilePicture")
                        
                        user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                
                                println("image saved successfully")
                                
                            } else {
                                
                                println("image not saved")
                            }
                        })
                    }
                    // MAKE FUNCTION -----------------------------------------------------
                    // repeats in settings
                    // MAKE FUNCTION -----------------------------------------------------
                    
                    // Create entry in UserQs table
                    self.createUserQs(self.username.text)
                    
                    // Do this in a completion handler once the above is global
                    self.performSegueWithIdentifier("signedUp", sender: self)
                
                    // End spinner/UI block/unblur
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    blurView.removeFromSuperview()
                    
                } else {
                    
                    println("User logged in through Facebook!")
                    
                    self.performSegueWithIdentifier("signedUp", sender: self)
                    
                    // End spinner/UI block/unblur
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    blurView.removeFromSuperview()
                }
                
            } else {
                
                println("Uh oh. The user cancelled the Facebook login.")
                self.navigationController?.navigationBarHidden = false
            }
        }
        
        // Stop animation - hides when stopped (above) hides spinner automatically
        self.activityIndicator.stopAnimating()
        // Release lock on app input
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
                    
                    // Create entry in UserQs table
                    self.createUserQs(self.username.text)
                    
                } else { // Signup failed
                    
                    if let errorString = error!.userInfo?["error"] as? String {
                        
                        errorMessage = errorString
                        
                    }
                    
                    // Stop animation - hides when stopped (above) hides spinner automatically
                    self.activityIndicator.stopAnimating()
                    
                    // Release app input block
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
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
                        
                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                        // MAKE GLOBAL FUNCTION (repeats in QsLoginViewController ------------
                        myName = username.lowercaseString
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
        
        signUpButton.layer.cornerRadius = cornerRadius
        
        // Hide nav bar when keyboard present
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = true
        navigationController?.hidesBarsWhenKeyboardAppears = true
        
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
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
    

}
