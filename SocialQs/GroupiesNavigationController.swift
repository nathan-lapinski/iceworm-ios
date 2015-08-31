//
//  GroupiesNavigationController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 8/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = winColor
        //self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor() ]
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
