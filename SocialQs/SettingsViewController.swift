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
            
            let permissions = ["public_profile", "email", "user_friends"]
            
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: permissions, block: { (succeeded, error) -> Void in
                
                if succeeded {
                    
                    println("User is linked with Facebook")
                    
                    // MAKE FUNCTION -----------------------------------------------------
                    // repeats in signup
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
                        // CHECK IF ALREADY EXISTS
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
                        
                        self.updateImageAndButton(true)
                    }
                    // MAKE FUNCTION -----------------------------------------------------
                    // repeats in signup
                    // MAKE FUNCTION -----------------------------------------------------
                    
                } else {
                    
                    println("Facebook Link error")
                    println(error)
                    
                    self.updateImageAndButton(false)
                    
                    displayAlert("Error", "The Facebook user currently logged in on this device is associated with another SocialQs account", self)
                }
            })
            
        } else { // UNLINK FACEBOOK
            
            //
            //
            // TEST IF REGULAR PARSE ACCOUNT IS SETUP - REQUIRE SETUP IF NO
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
            handleLabel.text = "@\(myName)"
            profilePictureImageView.image = profilePicture
            linkWithFacebook.setTitle("Unlink Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = true
            linkWithFacebook.hidden = true
            
        } else {
            
            nameLabel.text = ""
            handleLabel.text = "@\(myName)"
            //profilePictureImageView.image = UIImage(named: "profile.png")
            linkWithFacebook.setTitle("Link Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = false
            linkWithFacebook.hidden = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update image and button based on FB link status
        updateImageAndButton(PFFacebookUtils.isLinkedWithUser(user))
        
        println(PFFacebookUtils.isLinkedWithUser(user))
        
        logout.layer.cornerRadius = cornerRadius
        logout.backgroundColor = buttonBackgroundColor
        logout.titleLabel?.textColor = buttonTextColor
        linkWithFacebook.layer.cornerRadius = cornerRadius
        linkWithFacebook.backgroundColor = buttonBackgroundColor
        linkWithFacebook.titleLabel?.textColor = buttonTextColor
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        logout.setTitle("Log Out " + myName, forState: UIControlState.Normal)
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        returningFromSettings = true
        topOffset = 0
    }
    
    
    func logOut() -> Void {
        
        myName = ""
        uId = ""
        uQId = ""
        
        // Logout PFUser
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            if error == nil {
                
                // Clear username, uId and uQId locally
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "myName")
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "uId")
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "uQId")
                
                // Switch back to welcome screen
                self.performSegueWithIdentifier("logout", sender: self)
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
