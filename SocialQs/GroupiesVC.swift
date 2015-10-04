//
//  GroupiesVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 10/3/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var groupiesTable: UITableView!
    
    @IBAction func handleDismissedPressed(sender: AnyObject) {
        
        var endCenter = presentingViewController!.view.center
        var containerFrame = presentingViewController!.view.frame
        
        UIView.animateWithDuration(0.8,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: nil,
            animations: {
                
                self.view.center.x = endCenter.x + self.view.frame.width
                self.view.center.y = endCenter.y
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                
            }, completion: {
                _ in
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Format View
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0, 0)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        
        groupiesTable.layer.cornerRadius = 20.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(askTable: UITableView) -> Int { return 1 }
    
    func tableView(askTable: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    func tableView(askTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
//
//        switch indexPath.row {
//        case 0://QUESTION
//            
//            cell = askTable.dequeueReusableCellWithIdentifier("qCell", forIndexPath: indexPath) as! AskTableViewCell
//            
//            cell.questionImageView.contentMode = .ScaleAspectFit
//            cell.addQPhoto.setTitle("", forState: UIControlState.Normal)
//            cell.questionImageView.backgroundColor = UIColor.clearColor()
//            
//            if clear == false {
//                
//                // Fill question text
//                if cell.questionTextField.text != "" { question = cell.questionTextField.text }
//                if chosenImageHighRes[0] == nil {
//                    cell.questionImageView.image = UIImage(named: "camera.png")
//                } else {
//                    cell.questionImageView.image = chosenImageHighRes[0]//indexPath.row]
//                }
//                
//            } else {
//                
//                cell.questionImageView.image = UIImage(named: "camera.png")
//                cell.questionTextField.text = ""
//            }
//            
//        case 1://OPTIONS
//            
//            cell = askTable.dequeueReusableCellWithIdentifier("oCell", forIndexPath: indexPath) as! AskTableViewCell
//            
//            cell.option1ImageView.contentMode = .ScaleAspectFit
//            cell.option2ImageView.contentMode = .ScaleAspectFit
//            cell.addO1Photo.setTitle("", forState: UIControlState.Normal)
//            cell.addO2Photo.setTitle("", forState: UIControlState.Normal)
//            cell.option1ImageView.backgroundColor = UIColor.clearColor()
//            cell.option2ImageView.backgroundColor = UIColor.clearColor()
//            
//            if clear == false {
//                
//                if cell.option1TextField.text != "" || cell.option2TextField.text != "" {
//                    option1 = cell.option1TextField.text
//                    option2 = cell.option2TextField.text
//                }
//                
//                if chosenImageHighRes[1] == nil {
//                    cell.option1ImageView.image = UIImage(named: "camera.png")
//                } else {
//                    cell.option1ImageView.image = chosenImageHighRes[1]
//                }
//                
//                if chosenImageHighRes[2] == nil {
//                    cell.option2ImageView.image = UIImage(named: "camera.png")
//                } else {
//                    cell.option2ImageView.image = chosenImageHighRes[2]
//                }
//                
//            } else {
//                
//                cell.option1TextField.text = ""
//                cell.option2TextField.text = ""
//            }
//            
//        case 2: // Buttons
//            
//            cell = askTable.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! AskTableViewCell
//            
//            // FORMAT BUTTONS
//            formatButton(cell.groupies)
//            formatButton(cell.privacy)
//            formatButton(cell.clear)
//            formatButton(cell.submit)
//            
//            self.clear = false
//            
//        default: cell = askTable.dequeueReusableCellWithIdentifier("oCell", forIndexPath: indexPath) as! AskTableViewCell
//            
//        }
//        
//        // Set separator color
//        askTable.separatorColor = UIColor.clearColor()
//        
//        // Make cells non-selectable, visually
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        
//        // Set cell background color
//        cell.backgroundColor = tableBackgroundColor
//        
        return cell
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
