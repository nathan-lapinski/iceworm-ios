//
//  SignUpViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/22/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var facebookSignUp: UITableView!
    @IBOutlet var standardSignUp: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookSignUp.delegate = self
        facebookSignUp.dataSource = self
        standardSignUp.delegate = self
        standardSignUp.dataSource = self
        
        self.view.addSubview(facebookSignUp)
        self.view.addSubview(standardSignUp)
        
        //self.facebookSignUp.registerClass(UITableViewCell.self, forCellReuseIdentifier: "facebookSignUp")
        //self.standardSignUp.registerClass(UITableViewCell.self, forCellReuseIdentifier: "standardSignUp")
        
        //self.tableView.registerNIB(UINib(nibName: "FacebookSignUpCell", bundle: nil), forCellReuseIdentifier: "facebookSignUp")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == facebookSignUp {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("facebookSignUp", forIndexPath: indexPath) as! FacebookSignUpCell
            
            println("cell1")
            
            cell.facebookText.text = "Sign up with Facebook"
            cell.facebookImage.image = UIImage(named: "share_facebook.png")
            
            return cell
            
        } else {
            
            var cell2 = tableView.dequeueReusableCellWithIdentifier("standardSignUp", forIndexPath: indexPath) as! StandardSignUpCell
            
            println("cell2")
            
            return cell2
        }
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
