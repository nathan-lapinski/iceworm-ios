//
// Copyright 2015 Brett Wiesman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class SettingsNEWViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    let picker = UIImagePickerController()
    
    var boxView = UIView()
    var blurView = globalBlurView()
    
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var appInfo: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var profilePictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
        if let username = PFUser.currentUser()!["username"] as? String {
            handleLabel.text = "@\(username)"
        }
        
        view.backgroundColor = mainColorBlue.colorWithAlphaComponent(0.85)
        
        profilePictureImageView.image = profilePicture
        profilePictureImageView.layer.cornerRadius = 4.0
        profilePictureImageView.layer.masksToBounds = true
        
        picker.delegate = self
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
        
        backgroundImage.layer.cornerRadius = 20.0
        backgroundImage.layer.masksToBounds = true
        
        logoutButton.setTitle("Log Out", forState: UIControlState.Normal)
        formatButton(logoutButton)
        logoutButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        // Format view
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0, 0)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
    }
    
    @IBAction func handleDismissedPressed(sender: AnyObject) {
        
        let endCenter = presentingViewController!.view.center
        //var containerFrame = presentingViewController!.view.frame
        
        UIView.animateWithDuration(0.8,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [],
            animations: {
                
                self.view.center.x = endCenter.x + self.view.frame.width
                self.view.center.y = endCenter.y
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                
            }, completion: {
                _ in
        })
    }
    
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        launchLogoutPopover()
        
//        popErrorMessage = "...if you're leaving us already 😕 We hope you come back soon!"
//        popDirection = "top"
//        let overlayVC = self.storyboard?.instantiateViewControllerWithIdentifier("errorOverlayViewController") as! UIViewController
//        self.prepareOverlayVC(overlayVC)
//        self.presentViewController(overlayVC, animated: true, completion: nil)
//    }
//    private func prepareOverlayVC(overlayVC: UIViewController) {
//        overlayVC.transitioningDelegate = overlayTransitioningDelegate
//        overlayVC.modalPresentationStyle = .Custom
    }
    
    
    
    func logOut() -> Void {
        
        displaySpinnerView(spinnerActive: true, UIBlock: true, _boxView: boxView, _blurView: blurView, progressText: "Logging Out", sender: self.presentingViewController!)
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            print("(&*%^( TEH FUQ O*&&^(")
            //self.generateAPILoginDetails()
        }
        
        // Clear all local values so they don't bleed into next user
        username = ""
        name = ""
        uId = ""
        profilePicture = nil
        groupiesGroups = []
        friendsDictionary = []
        friendsPhotoDictionary = [:]
        friendsDictionaryFiltered = []
        isGroupieName = []
        groupiesDictionary = []
        myGroups = [] // Stores strings of group names
        myFriends = [] // Stores usernames of socialQs-typed users
        
        // Logout PFUser
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            if error == nil {
                
                // Switch back to welcome screen
                print("Logout complete, performing segue to welcome view")
                self.performSegueWithIdentifier("logout", sender: self)
            }
            
            displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.boxView, _blurView: self.blurView, progressText: nil, sender: self.presentingViewController!)
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



