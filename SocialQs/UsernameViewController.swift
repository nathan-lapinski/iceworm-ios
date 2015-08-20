//
//  UsernameViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/24/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController {
    
//    var usernameSpinner = UIActivityIndicatorView()
//    var usernameBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    var usernameSpinner = UIView()
    var usernameBlurView = globalBlurView()
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBAction func submitUsernameButtonPressed(sender: AnyObject) {
        
        usernameTextField.resignFirstResponder()
        
        checkIfUserExists(usernameTextField.text) { (isUser) -> Void in
            
            if isUser == true {
                
                displayAlert("That username is already taken!", "Please select a new one", self)
                
                self.usernameTextField.text = ""
                
            } else {
                
                displaySpinnerView(spinnerActive: true, UIBlock: true, self.usernameSpinner, self.usernameBlurView, "Setting Username", self)
                
                //blockUI(true, self.usernameSpinner, self.usernameBlurView, self)
                
                // save username to Parse
                let query = PFUser.currentUser()
                query?.username = self.usernameTextField.text
                query?.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if success {
                        
                        username = self.usernameTextField.text
                        
                        //displayAlert("Welcome to SocialQs", "", self)
                        self.performSegueWithIdentifier("signedUp2", sender: self)
                        
                    } else {
                        
                        println("Error saving new username")
                        println(error)
                    }
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, self.usernameSpinner, self.usernameBlurView, nil, self)
                    
                    //blockUI(false, self.usernameSpinner, self.usernameBlurView, self)
                })
            }
        }
    }
    
    
    func checkIfUserExists(usernameToCheck: String, completion: ((isUser: Bool?) -> Void)!) {
        
        var isPresent: Bool = false;
        
        let query: PFQuery = PFQuery(className: "_User")
        query.whereKey("username", equalTo: usernameToCheck)
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
