//
//  WelcomeViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet var logInButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet var logInButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet var createAccountButtonRightContraint: NSLayoutConstraint!
    @IBOutlet var createAccountButtonLeftContraint: NSLayoutConstraint!
    @IBOutlet var logInButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var bgTopConstraint: NSLayoutConstraint!
    
    @IBAction func signInButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signIn", sender: self)
    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.hidden = true
        createAccountButton.hidden = true
        
        //let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        
        //signInButton.layer.cornerRadius = cornerRadius
        //createAccountButton.layer.cornerRadius = cornerRadius
        
        //signInButton.hidden = true
        //createAccountButton.hidden = true
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            signInCurrentUser()
            
        } else {
            
            signInButton.hidden = false
            createAccountButton.hidden = false
            
            // ANIMATION STUFFS -------------------------------------------------------------
            bgTopConstraint.constant = 0
            bgImageView.layoutIfNeeded()
            
            logoTopConstraint.constant = 0
            logoImageView.layoutIfNeeded()
            
            self.buttonSpacingConstraint.constant = 120
            self.logInButtonTopConstraint.constant = self.view.frame.height + 5//670
            signInButton.enabled = false
            signInButton.layoutIfNeeded()
            
            createAccountButton.enabled = false
            createAccountButton.layoutIfNeeded()
            
            UIView.animateWithDuration(2.5, delay: 1.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3, options: nil, animations: { () -> Void in
                
                self.bgTopConstraint.constant = -80
                self.logoTopConstraint.constant = -130
                self.logInButtonTopConstraint.constant = 178
                self.buttonSpacingConstraint.constant = 8
                self.bgImageView.layoutIfNeeded()
                self.logoImageView.layoutIfNeeded()
                self.createAccountButton.layoutIfNeeded()
                self.signInButton.layoutIfNeeded()
                
                }, completion: { (isFinished) -> Void in
                    
                    self.signInButton.enabled = true
                    self.createAccountButton.enabled = true
            })
            // ANIMATION STUFFS -------------------------------------------------------------
        }
    }
    
    
    func signInCurrentUser() {
        
        getPersonalInfoFromFacebook() { (isFinished) -> Void in
            
            if isFinished {
                
                storeUserInfo(PFUser.currentUser()!.username!, false) {
                    
                    (isFinished) -> Void in
                    
                    self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                }
                
            } else {
                
                println("Could not gather FB info - logInViewController")
            }
        }
        
        //
        //
        // **** Only this this if these are not already stored for the CURRENT USER ****
        //
        //
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
