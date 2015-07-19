//
//  MainNavigationController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FUNCTION ***************************************************************
        // Navigation bar settings
        //self.navigationItem.title = "SocialQs"
        self.navigationBar.barTintColor = winColor
        self.navigationBar.tintColor = UIColor.whiteColor()
        //self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        /*//let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo_square.png")
        imageView.image = image
        navigationItem.titleView = imageView // tried adding self.
        // FUNCTION ***************************************************************
        */
        
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
