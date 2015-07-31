//
//  UsernameViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/24/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController {
    
    var usernameSpinner = UIActivityIndicatorView()
    var usernameBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    @IBOutlet var username: UITextField!
    
    @IBAction func submitUsernameButtonPressed(sender: AnyObject) {
        
        username.resignFirstResponder()
        
        checkIfUserExists(username.text) { (isUser) -> Void in
            
            if isUser == true {
                
                displayAlert("That username is already taken!", "Please select a new one.", self)
                
                self.username.text = ""
                
            } else {
                
                blockUI(true, self.usernameSpinner, self.usernameBlurView, self)
                
                // save username to Parse
                let query = PFUser.currentUser()
                query?.username = self.username.text
                query?.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if success {
                        
                        myName = self.username.text
                        
                        displayAlert("Welcome to SocialQs", "", self)
                        self.performSegueWithIdentifier("signedUp2", sender: self)
                        
                    } else {
                        
                        println("Error saving new username")
                        println(error)
                    }
                    
                    blockUI(false, self.usernameSpinner, self.usernameBlurView, self)
                })
            }
        }
    }
    
    
    func checkIfUserExists(username: String, completion: ((isUser: Bool?) -> Void)!) {
        
        var isPresent: Bool = false;
        
        let query: PFQuery = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if (objects!.count > 0) { isPresent = true }
                
            } else {
                
                // Log details of the failure
                println("Error: \(error) \(error!.userInfo!)")
            }
            
            completion(isUser: isPresent);
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        // Call submit routine to cause switch to results page
        submitUsernameButtonPressed(textField)
        
        return true
    }
    

}
