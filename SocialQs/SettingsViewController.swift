//
//  SettingsViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/13/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user = PFUser.currentUser()!
    
    let picker = UIImagePickerController()
    
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
    @IBOutlet var changeProfilePictureButton: UIButton!
    
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
//                println("<><><><><><><><>")
//                println("No password")
//            }
            
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
    
    
    @IBAction func changeProfilePicture(sender: AnyObject) {
        
        launchImagePickerPopover()
    }
    
    
    func updateImageAndButton(linked: Bool) -> Void {
        
        nameLabel.text = "@\(username)"
        
        if linked {
            
            linkWithFacebook.setTitle("Unlink Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = true
            linkWithFacebook.hidden = false
            
        } else {
            
            linkWithFacebook.setTitle("Link Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = false
            linkWithFacebook.hidden = false
        }
        
        if name != "" {
            
            handleLabel.text = name
        } else {
            
            handleLabel.text = ""
        }
        
        profilePictureImageView.image = profilePicture
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
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
        //storeUserInfo(username, false) { (isFinished) -> Void in
            
        username = ""
        name = ""
        uId = ""
        uQId = ""
        profilePicture = nil
        
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
        //}
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
    
    
    //MARK: Image Picker Shits
    func launchImagePickerPopover() -> Void {
        
        var titleMessage = "Please choose image source"
        
        let alert = UIAlertController(title: titleMessage, message: nil, preferredStyle:
            .ActionSheet) // Can also set to .Alert if you prefer
        
        let cameraAction = UIAlertAction(title: "Take Picture", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false
            self.picker.sourceType = .PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alert.addAction(libraryAction)
        
        let facebookAction = UIAlertAction(title: "Facebook Photos", style: .Default) { (action) -> Void in
            //
            // LOAD FACEBOOK PHOTOS HERE
            //
        }
        alert.addAction(facebookAction)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) -> Void in
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        profilePicture = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: 200, height: 200))
        profilePictureImageView.image = profilePicture
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("cancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func showPhotoPicker(source: UIImagePickerControllerSourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
