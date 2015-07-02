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
    
    @IBAction func logoutButton(sender: AnyObject) {
        
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

    }
    
    override func viewWillAppear(animated: Bool) {
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        logout.setTitle("Logout " + myName, forState: UIControlState.Normal)
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
        
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
