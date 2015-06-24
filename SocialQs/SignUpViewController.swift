//
//  SignUpViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/22/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var standardSignUpText = ["USERNAME","EMAIL","PASSWORD"]
    var standardSignUpPlaceholderText = ["Your desired username", "Your email address", "Your desired password"]
    //var standardSignUpUserText = ["", "", ""]
    
    @IBOutlet var facebookSignUp: UITableView!
    @IBOutlet var standardSignUp: UITableView!
    //@IBOutlet var standardTextField: UITextField!
    
    @IBAction func standardSignUpButton(sender: AnyObject) {
        
        
        
    }
    
    @IBAction func facebookSignUpButton(sender: AnyObject) {
        
        //self.loginCancelled.hidden = true
        
        var permissions = ["public_profile", "email", "user_friends"]
        
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
                //self.loginCancelled.hidden = false
                
            }
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookSignUp.delegate = self
        facebookSignUp.dataSource = self
        standardSignUp.delegate = self
        standardSignUp.dataSource = self
        
        self.view.addSubview(facebookSignUp)
        self.view.addSubview(standardSignUp)
        
        //self.facebookSignUp.registerClass(UITableViewCell.self, forCellReuseIdentifier: "facebookSignUp")
        //self.standardSignUp.registerClass(UITableViewCell.self, forCellReuseIdentifier: "standardSignUp")
        
        //self.tableView.registerNIB(UINib(nibName: "FacebookSignUpCell", bundle: nil), forCellReuseIdentifier: "facebookSignUp")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == facebookSignUp {
            
            return 1
            
        } else {
            
            return 3
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == facebookSignUp {
            
            var cell1 = tableView.dequeueReusableCellWithIdentifier("facebookSignUp", forIndexPath: indexPath) as! FacebookSignUpCell
            
            cell1.facebookTextField.text = "Sign up with Facebook"
            cell1.facebookImage.image = UIImage(named: "share_facebook.png")
            
            return cell1
            
        } else {
            
            var cell2 = tableView.dequeueReusableCellWithIdentifier("standardSignUp", forIndexPath: indexPath) as! StandardSignUpCell
                        
            cell2.standardTextField.textColor = UIColor.lightGrayColor()
            cell2.standardTextLabel.text = standardSignUpText[indexPath.row]
            cell2.standardTextField.text = standardSignUpPlaceholderText[indexPath.row]
            cell2.standardTextField.tag = indexPath.row
            //cell2.standardTextField.delegate = self
            
            return cell2
        }
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
