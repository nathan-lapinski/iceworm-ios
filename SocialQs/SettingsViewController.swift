//
//  SettingsViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/13/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
    
    var user = PFUser.currentUser()!
    
    //var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    var settingsSpinner = UIActivityIndicatorView()
    var settingsBlurView = globalBlurView()
    
    @IBOutlet var linkWithFacebook: UIButton!
    @IBOutlet var logout: UIButton!
    @IBOutlet var appInfo: UILabel!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var facebookLogo: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    
    @IBAction func logoutButton(sender: AnyObject) { launchLogoutPopover() }
    
    @IBAction func linkWithFacebookAction(sender: AnyObject) {
        
        if !PFFacebookUtils.isLinkedWithUser(user) {
            
            blockUI(true, settingsSpinner, settingsBlurView, self)
            
            let permissions = ["public_profile", "email", "user_friends"]
            
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: permissions, block: { (succeeded, error) -> Void in
                
                if succeeded {
                    
                    println("User is linked with Facebook")
                    
                    getPersonalInfoFromFacebook() { (isFinished) -> Void in
                        
                        if isFinished {
                            
                            println("!!!!!!!!!!!!!!!!")
                            
                            blockUI(false, self.settingsSpinner, self.settingsBlurView, self)
                            
                            self.updateImageAndButton(true)
                            
                        } else {
                            
                            println("Could not gather FB info - settingsViewController")
                            
                            blockUI(false, self.settingsSpinner, self.settingsBlurView, self)
                        }
                    }
                    
                } else {
                    
                    println("Facebook Link error")
                    println(error)
                    
                    self.updateImageAndButton(false)
                    
                    displayAlert("Error", "Please verify that the Facebook user currently logged in on this device is not associated with another SocialQs account and try again later", self)
                    
                    blockUI(false, self.settingsSpinner, self.settingsBlurView, self)
                }
            })
            
        } else { // UNLINK FACEBOOK
            
//            if let pwTest = PFUser.currentUser()!["password"] as? String {
//                
//                println("<><><><><><><><>")
//                println(pwTest)
//                println("<><><><><><><><>")
//            } else {
//                
//                
//                println("<><><><><><><><>")
//                println("No password")
//            }
            
            //
            //
            // TEST IF REGULAR PARSE ACCOUNT IS SETUP - REQUIRE SETUP IF NO
            //
            //
            //
            //
            //
            //
            //
            //
            
            PFFacebookUtils.unlinkUserInBackground(user, block: { (succeeded, error) -> Void in
                
                if error == nil {
                    
                    println("User is no longer associated with their Facebook account.")
                    self.updateImageAndButton(false)
                    
                    let title = "SocialQs has unlinked from Facebook!"
                    let message = "Please remember that Facebook linking allows you to easily find and Q your friends!"
                    displayAlert(title, message, self)
                }
            })
        }
    }
    
    
    func updateImageAndButton(linked: Bool) -> Void {
        
        if linked {
            
            nameLabel.text = name
            handleLabel.text = "@\(username)"
            linkWithFacebook.setTitle("Unlink Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = true
            linkWithFacebook.hidden = true
            
        } else {
            
            //nameLabel.text = ""
            //handleLabel.text = "@\(myName)"
            nameLabel.text = "@\(username)"
            handleLabel.text = "@\(username)"
            //profilePictureImageView.image = UIImage(named: "profile.png")
            linkWithFacebook.setTitle("Link Facebook Account", forState: UIControlState.Normal)
            //facebookLogo.hidden = false
            //linkWithFacebook.hidden = false
        }
        
        profilePictureImageView.image = profilePicture
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update image and button based on FB link status
        updateImageAndButton(PFFacebookUtils.isLinkedWithUser(user))
        
        println(PFFacebookUtils.isLinkedWithUser(user))
        
        formatButton(logout)
        formatButton(linkWithFacebook)
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        logout.setTitle("Log Out " + username, forState: UIControlState.Normal)
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        returningFromSettings = true
        topOffset = 0
    }
    
    
    func logOut() -> Void {
        
        // Store all data for loading next time
        storeUserInfo(username, false) { (isFinished) -> Void in
            
            //myName = ""
            //name = ""
            //uId = ""
            //uQId = ""
            
            // Logout PFUser
            PFUser.logOutInBackgroundWithBlock { (error) -> Void in
                
                if error == nil {
                    
                    //                // Clear username, uId and uQId locally
                    //                NSUserDefaults.standardUserDefaults().setObject("", forKey: "myName")
                    //                NSUserDefaults.standardUserDefaults().setObject("", forKey: "name")
                    //                NSUserDefaults.standardUserDefaults().setObject("", forKey: "uId")
                    //                NSUserDefaults.standardUserDefaults().setObject("", forKey: "uQId")
                    
                    
                    // Switch back to welcome screen
                    println("Logout complete, performing segue to welcome view")
                    self.performSegueWithIdentifier("logout", sender: self)
                }
            }
        }
    }
    
    
    func launchLogoutPopover() -> Void {
        
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle:
            .ActionSheet) // Can also set to .Alert if you prefer
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (action) -> Void in
            self.logOut()
        }
        alert.addAction(logOutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
