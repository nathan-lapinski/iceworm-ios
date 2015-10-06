//
//  WelcomeVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 8/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    var signupSpinner = UIView()
    var signupBlurView = globalBlurView()
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var backgroundImageViewTopSpace: NSLayoutConstraint!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var logoImageViewTopSpace: NSLayoutConstraint!
    @IBOutlet var facebookSignInButton: UIButton!
    @IBOutlet var facebookSignInButtonTopSpace: NSLayoutConstraint!
    @IBOutlet var facebookLogo: UIImageView!
    @IBOutlet var postWarningTextView: UILabel!
    @IBOutlet var postWarningTextViewTopSpace: NSLayoutConstraint!
    @IBOutlet var orTextView: UILabel!
    @IBOutlet var orTextViewTopSpace: NSLayoutConstraint!
    @IBOutlet var leftBar: UILabel!
    @IBOutlet var rightBar: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var usernameTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signInButtonTopSpace: NSLayoutConstraint!
    @IBOutlet var logo2ImageView: UIImageView!
    @IBOutlet var logo2ImageViewTopSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "onProfileUpdated:", name:FBSDKProfileDidChangeNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        //print(FBSDKAccessToken.currentAccessToken()) //prints nil
        
        animateWelcome()
        
    }
    
    
    @IBAction func facebookButtonAction(sender: AnyObject) {
        
        displaySpinnerView(spinnerActive: true, UIBlock: true, _boxView: self.signupSpinner, _blurView: self.signupBlurView, progressText: "Logging In", sender: self)
        
        print("0")
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        // Ensure that PFUser == nil
        PFUser.logOut()
        PFFacebookUtils.logInWithPermissions(permissions) { (user, error) -> Void in
            
            if let user = user {
                
                // Download groups
                downloadGroups({ (isFinished) -> Void in })
                
                // Download FB data in background - backgrounding built into FBSDK methods (?)
                downloadFacebookFriends({ (isFinished) -> Void in
                    
                    if isFinished { print("FB Download completion handler executed") }
                })
                
                if user.isNew {
                    
                    print("User signed up and logged in through Facebook!")
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    getUsersFacebookInfo({ (isFinished) -> Void in // desired to complete before storing info
                        
                        self.performSegueWithIdentifier("signedUp", sender: self)
                        
                        displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.signupSpinner, _blurView: self.signupBlurView, progressText: nil, sender: self)
                        
                        storeUserInfo(PFUser.currentUser()!.username!, isNew: true, completion: { (isFinished) -> Void in })
                        
                        getUsersFacebookInfo({ (isFinished) -> Void in })
                    })
                    
                } else {
                    
                    print("3")
                    
                    print("User logged in through Facebook!")
                    
                    getUserPhoto({ (isFinished) -> Void in })
                    
                    self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                    
                    if let groups = PFUser.currentUser()!["myGroups"] as? [String] {
                        myGroups = groups
                    }
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.signupSpinner, _blurView: self.signupBlurView, progressText: nil, sender: self)
                    
                    //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                    
                    storeUserInfo(PFUser.currentUser()!.username!, isNew: true, completion: { (isFinished) -> Void in })
                    
                    getUsersFacebookInfo({ (isFinished) -> Void in })
                }
                
            } else {
                
                print("Uh oh. The user cancelled the Facebook login.")
                
                displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.signupSpinner, _blurView: self.signupBlurView, progressText: nil, sender: self)
                
                //blockUI(false, self.signupSpinner, self.signupBlurView, self)
                
                self.navigationController?.navigationBarHidden = false
            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            if let groups = PFUser.currentUser()!["myGroups"] as? [String] {
                myGroups = groups
            }
            
            // No need to store data, pull photo etc... because user is
            // already logged in and data exists in proper locations
            performSegueWithIdentifier("alreadySignedIn", sender: self)
            
            getUserPhoto({ (isFinished) -> Void in
            })
            
            storeUserInfo(PFUser.currentUser()!.username!, isNew: false, completion: { (isFinished) -> Void in
                
                // Download FB data in background - backgrounding built into FBSDK methods (?)
                downloadFacebookFriends({ (isFinished) -> Void in
                                        
                    if isFinished { print("FBFriends Download completion handler executed") }
                })
            })
            
            // Download groups
            downloadGroups({ (isFinished) -> Void in })
        } else {
            print("No active PFUser - must log in")
        }
    }

    
    func animateWelcome() {
        
        let spacingMultiplier: CGFloat = 10
        
        backgroundImageViewTopSpace.constant = 0
        backgroundImageView.layoutIfNeeded()
        
        logoImageViewTopSpace.constant = 0
        logoImageView.layoutIfNeeded()
        
        facebookSignInButtonTopSpace.constant = self.view.frame.size.height
        facebookSignInButton.layoutIfNeeded()
        facebookLogo.layoutIfNeeded()
        
        postWarningTextViewTopSpace.constant = 10 * spacingMultiplier
        postWarningTextView.layoutIfNeeded()
        
//        orTextViewTopSpace.constant = 12 * spacingMultiplier
//        orTextView.layoutIfNeeded()
//        leftBar.layoutIfNeeded()
//        rightBar.layoutIfNeeded()
//        
//        usernameTextFieldTopSpace.constant = 19 * spacingMultiplier
//        usernameTextField.layoutIfNeeded()
//        
//        passwordTextFieldTopSpace.constant = 8 * spacingMultiplier
//        passwordTextField.layoutIfNeeded()
//        
//        emailTextFieldTopSpace.constant = 8 * spacingMultiplier
//        emailTextField.layoutIfNeeded()
//        
//        signInButtonTopSpace.constant = 8 * spacingMultiplier
//        signInButton.layoutIfNeeded()
//        
//        //logo2ImageViewTopSpace.constant = 500
//        logo2ImageView.alpha = 0.0
//        logo2ImageView.layoutIfNeeded()
        
        UIView.animateWithDuration(3.0, delay: 1.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3, options: [], animations: { () -> Void in
            
            self.backgroundImageViewTopSpace.constant = -150
            self.logoImageViewTopSpace.constant = -100
            
            self.backgroundImageView.layoutIfNeeded()
            self.logoImageView.layoutIfNeeded()
            
            self.facebookSignInButtonTopSpace.constant = 300
            self.facebookSignInButton.layoutIfNeeded()
            self.facebookLogo.layoutIfNeeded()
            
            self.postWarningTextViewTopSpace.constant = 3
            self.postWarningTextView.layoutIfNeeded()
            
            self.view.layoutIfNeeded()
            
//            self.orTextViewTopSpace.constant = 12
//            self.orTextView.layoutIfNeeded()
//            self.leftBar.layoutIfNeeded()
//            self.rightBar.layoutIfNeeded()
//            
//            self.usernameTextFieldTopSpace.constant = 19
//            self.usernameTextField.layoutIfNeeded()
//            
//            self.passwordTextFieldTopSpace.constant = 8
//            self.passwordTextField.layoutIfNeeded()
//            
//            self.emailTextFieldTopSpace.constant = 8
//            self.emailTextField.layoutIfNeeded()
//            
//            self.signInButtonTopSpace.constant = 8
//            self.signInButton.layoutIfNeeded()
            
            }, completion: { (isFinished) -> Void in
                
                //self.signInButton.enabled = true
                //self.createAccountButton.enabled = true
        })
        
//        UIView.animateWithDuration(4.0, delay: 3.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3, options: nil, animations: { () -> Void in
//            
//            //self.logo2ImageViewTopSpace.constant = 220
//            self.logo2ImageView.alpha = 1.0
//            self.logo2ImageView.layoutIfNeeded()
//            
//            }, completion: { (isFinished) -> Void in
//        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
