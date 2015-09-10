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
    
    var settingsSpinner = UIActivityIndicatorView()
    var settingsBlurView = globalBlurView()
    var boxView = UIView()
    var blurView = globalBlurView()
    
    
    
    
    @IBAction func spinnerButtonAction(sender: AnyObject) {
        
        displaySpinnerView(spinnerActive: true, UIBlock: true, self.boxView, self.blurView, "Testing Spinner", self)
        
        backgroundThread(delay: 4.0, completion: {
            // Your delayed function here to be run in the foreground
            
            displaySpinnerView(spinnerActive: false, UIBlock: false, self.boxView, self.blurView, nil, self)
        })
    }
    
    
    
    
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
        
        displaySpinnerView(spinnerActive: true, UIBlock: true, boxView, blurView, "Linking with Facebook", self)
        
        //blockUI(true, self.settingsSpinner, self.settingsBlurView, self)
        
        linkUserWithFacebook({ (success, message) -> Void in
            
            if success == true {
                
                displaySpinnerView(spinnerActive: false, UIBlock: false, self.boxView, self.blurView, nil, self)
                
                //blockUI(false, self.settingsSpinner, self.settingsBlurView, self)
                
                self.updateImageAndButton(true)
                
            } else {
                
                displaySpinnerView(spinnerActive: false, UIBlock: false, self.boxView, self.blurView, nil, self)
                
                //blockUI(false, self.settingsSpinner, self.settingsBlurView, self)
                
                self.updateImageAndButton(false)
                
                displayAlert("Error", "Please verify that the Facebook user currently logged in on this device is not associated with another SocialQs account and try again later", self)
            }
        })
        //                // UNLINK
        //                self.updateImageAndButton(false)
        //
        //                let title = "SocialQs has unlinked from Facebook!"
        //                let message = "Please remember that Facebook linking allows you to easily find and Q your friends!"
        //                displayAlert(title, message, self)
    }
    
    
    @IBAction func changeProfilePicture(sender: AnyObject) {
        
        launchImagePickerPopover()
    }
    
    
    func updateImageAndButton(linked: Bool) -> Void {
        
        nameLabel.text = "@\(username)"
        
        if linked {
            
            linkWithFacebook.setTitle("Unlink Facebook Account", forState: UIControlState.Normal)
            facebookLogo.hidden = true
            linkWithFacebook.hidden = true
            
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
        
        //PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()!)
        
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
            
        username = ""
        name = ""
        uId = ""
        uQId = ""
        profilePicture = nil
        
        // Logout PFUser
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            if error == nil {
                
                // Switch back to welcome screen
                println("Logout complete, performing segue to welcome view")
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
        
        // Store image on parse to pull for Q display
        let imageData = UIImagePNGRepresentation(profilePicture)
        var imageFile: PFFile = PFFile(name: "profilePicture.png", data: imageData)
        PFUser.currentUser()!.setObject(imageFile, forKey: "profilePicture")
        
        PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                println("image saved successfully")
                
            } else {
                
                println("image not saved")
            }
        })
        
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
