//
//  VotesTheirTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/30/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class VotesTheirTableViewController: UITableViewController {
    
    var objectsArray = [Objects]()
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissPressed:")
        
        // Format Done button
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
        
        //objectsArray = [Objects(sectionName: "Section 1 Section 1 Section 1 Section 1 Section 1 Section 1 Section 1 Section 1 Section 1", sectionObjects: ["1", "2", "3"]), Objects(sectionName: "Section 2", sectionObjects: ["a", "b", "c"])]
        
        
        var votesId = ""
        var option1Text = ""
        var option2Text = ""
        // PARSE ----------------------------------------------------
        var query = PFQuery(className: "SocialQs")
        query.whereKey("objectId", equalTo: requestedQId)
        query.getFirstObjectInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                votesId = objects!["votesId"] as! String
                option1Text = objects!["option1"] as! String
                option2Text = objects!["option2"] as! String
                
                // CHANGE TO LOOK UP USERNAME FROM OBJECTID!!!
                //
                //
                //
                query = PFQuery(className: "Votes")
                query.getObjectInBackgroundWithId(votesId, block: { (objects, error) -> Void in
                    
                    if objects!["vote"] != nil {
                        if error == nil {
                            var votes = objects!["vote"] as! [Int]
                            var voters = objects!["voterName"] as! [String]
                            println(voters)
                            var voter1s = [""]
                            var voter2s = [""]
                            voter1s.removeAll(keepCapacity: true)
                            voter2s.removeAll(keepCapacity: true)
                            
                            // Build arrays of names for each voteId (1 and 2)
                            for var ii = 0; ii < votes.count; ii++ {
                                if votes[ii] == 1 {
                                    voter1s.append(voters[ii])
                                } else {
                                    voter2s.append(voters[ii])
                                }
                            }
                            
                            self.objectsArray = [Objects(sectionName: option1Text, sectionObjects: voter1s), Objects(sectionName: option2Text, sectionObjects: voter2s)]
                            
                            self.tableView.reloadData()
                            self.tableView.reloadInputViews()
                            
                        } else {
                            println("Voter retreival error")
                            println(error)
                        }
                    } else {
                        
                        let title = "Sorry!"
                        let message = "No one has voted on your Q yet."
                        self.displayAlert(title, message: message)
                    }
                })
            }
        }
    }
    
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    
    
    override func viewWillAppear(animated: Bool) {
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return objectsArray.count
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsArray[section].sectionObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("votesTheirCell", forIndexPath: indexPath) as! VotesTheirCell

        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]

        return cell
    }
    
    /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 80))
        
        headerView.backgroundColor = mainColorBlue
        
        let headerLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, 20))
        headerLabel.text = "Test"
        headerLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    */

    
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        
        return objectsArray[section].sectionName
    }
    */
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = mainColorBlue
        header.textLabel.textColor = UIColor.whiteColor()
        //header.alpha = bgAlpha //make the header transparent
        
        header.textLabel.textAlignment = NSTextAlignment.Left
        header.textLabel.numberOfLines = 10 // Dynamic number of lines
        header.textLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        header.textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)!
        header.textLabel.text = objectsArray[section].sectionName

    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat(60)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
