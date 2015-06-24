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
        PFUser.logOut()
        performSegueWithIdentifier("logout", sender: self)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logout.layer.cornerRadius = cornerRadius
        logout.backgroundColor = bgColor

    }
    
    override func viewWillAppear(animated: Bool) {
        
        println(myName)
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        appInfo.text = "Version: " + version! + "\nBuild: (" + build! + ")"
        
        logout.setTitle("Logout " + myName, forState: UIControlState.Normal)
        
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
