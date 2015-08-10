//
//  WelcomeViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var welcomeSpinner = UIActivityIndicatorView()
    var welcomeBlurView = globalBlurView()
    
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
            
            blockUI(true, self.welcomeSpinner, self.welcomeBlurView, self)
            
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
    
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    // MAKE GLOBAL - repeats in loginController with DIFFERENT SEGUE
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
                    
                    self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                    
                    blockUI(false, self.welcomeSpinner, self.welcomeBlurView, self)
                
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
                            
                            self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                            
                            blockUI(false, self.welcomeSpinner, self.welcomeBlurView, self)
                        
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
                
                self.performSegueWithIdentifier("alreadySignedIn", sender: self)
                
                blockUI(false, self.welcomeSpinner, self.welcomeBlurView, self)
            })
        }
    }
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
