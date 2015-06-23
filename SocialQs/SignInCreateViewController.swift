//
//  SignInCreateViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/23/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class SignInCreateViewController: UIViewController {
    
    @IBAction func signInButton(sender: AnyObject) {
        
    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
        
        performSegueWithIdentifier("signUp", sender: self)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
