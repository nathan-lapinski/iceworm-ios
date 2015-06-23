//
//  TestActiveViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/19/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class TestActiveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // CHECK TEST ENVIRONMENT -------------------------------------------------
        println("Checking for active test environment")
        let query = PFQuery(className: "Message")
        var expired = false
        query.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if let temp = object {
                for objectb in temp {
                    expired = objectb["expired"] as! Bool
                    if expired == true {
                        let title = "Thank you for you participation!"
                        let message = "This test has expired. Please contact developer at booksixav@gmail.com"
                        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.performSegueWithIdentifier("testActive", sender: self)
                    }
                }
            }
        }
        // CHECK TEST ENVIRONMENT -------------------------------------------------
        
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
