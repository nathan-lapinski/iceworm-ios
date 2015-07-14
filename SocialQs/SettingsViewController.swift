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
    
    @IBOutlet var logout: UIButton!
    @IBOutlet var appInfo: UILabel!
    
    @IBAction func logoutButton(sender: AnyObject) { launchImagePickerPopover() }
    
    func launchImagePickerPopover() -> Void {
        
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
    
    
    func logOut() -> Void {
        
        myName = ""
        uId = ""
        uQId = ""
        
        // Logout PFUser
        PFUser.logOut()
        
        // Clear username, uId and uQId locally
        //NSUserDefaults.standardUserDefaults().setObject("", forKey: "myName")
        //NSUserDefaults.standardUserDefaults().setObject("", forKey: "uId")
        //NSUserDefaults.standardUserDefaults().setObject("", forKey: "uQId")
        
        // Switch back to welcome screen
        performSegueWithIdentifier("logout", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logout.layer.cornerRadius = cornerRadius
        logout.backgroundColor = buttonBackgroundColor
        logout.titleLabel?.textColor = buttonTextColor
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        logout.setTitle("Logout " + myName, forState: UIControlState.Normal)
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
