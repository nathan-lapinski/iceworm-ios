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
    
    @IBAction func signInButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signIn", sender: self)
        
    }
    
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = cornerRadius
        createAccountButton.layer.cornerRadius = cornerRadius
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Skip login procedure if user is already logged in
        if PFUser.currentUser() != nil {
            
            myName = (PFUser.currentUser()!.username!)
            uId = PFUser.currentUser()!.objectId!
            
            self.performSegueWithIdentifier("alreadySignedIn", sender: self)
            
        }
        
        // ANIMATION STUFFS -------------------------------------------------------------
        /*
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
        */
        // ANIMATION STUFFS -------------------------------------------------------------
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
