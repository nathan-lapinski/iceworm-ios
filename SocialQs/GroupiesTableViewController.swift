//
//  GroupiesTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesTableViewController: UITableViewController {
    
    //var refresher: UIRefreshControl!
    var usernames = [""]
    var userids = [""]
    var isGroupie = ["":false]
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
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
    

    override func viewDidLoad() {
        super.viewDidLoad()// Do any additional setup after loading the view.
        
        if myName == "" { println("myName is empty!") }
        
        
        let title = "Warning:"
        let message = "This page is for testing only. Selecting users will not currently filter by whom your Q is seen."
        displayAlert(title, message: message)
        
        
        // Title table controller
        self.title = "Select Groupies"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissPressed:")
    
        // Format Done button
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "splash_no_logo.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func refresh() {
        
        var query = PFUser.query()
        
        query?.whereKey("objectId", notEqualTo: uId)
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isGroupie.removeAll(keepCapacity: true)
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        self.isGroupie[user.objectId!] = false
                        
                        // Do check to make sure these exist!!!!!!!!!!!!!!!!!!!!!!!!!!
                        //
                        self.usernames.append(user.username!)
                        self.userids.append(user.objectId!)
                        
                        
                        self.tableView.reloadData()
                        
                        
                        // SEND DATA BACK ----------------------------------------------------------
                        // SEND DATA BACK ----------------------------------------------------------
                        
                        
                        
                        
                        /*
                        // Check if this user is being following by the current user
                        var query = PFQuery(className: "Follow")
                        
                        // Set query keys
                        // Error here was from the login check not functioning properly, so
                        // we reached this point even though we weren't logged in
                        query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                        query.whereKey("following", equalTo: user.objectId!)
                        
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            
                            // if objects = objects it must be the case that this user is being followed
                            if let temp = objects {
                                
                                if temp.count > 0 {
                                    
                                    self.isFollowing[user.objectId!] = true
                                    
                                } else {
                                    
                                    self.isFollowing[user.objectId!] = false
                                    
                                }
                            }
                            
                            // The way this check is done doesn't make sense....???
                            // Check to ensure following query has completed before refreshing table (or breaks)
                            if self.isFollowing.count == self.usernames.count {
                        
                                
                                // End refreshing following table reload
                                self.refresher.endRefreshing()
                                
                            }
                        })*/
                    }
                }
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupiesCell", forIndexPath: indexPath) as! GroupiesCell
        
        // Configure the cell...
        cell.usernameLabel.text = usernames[indexPath.row]
        cell.usernameLabel.textColor = UIColor.whiteColor()

        // Make cells non-selectable (visually)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let followedObjectId = userids[indexPath.row]
        
        if isGroupie[followedObjectId] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        }
        
        // Format cell backgrounds
        if indexPath.row % 2 == 0 {
            
            cell.backgroundColor = UIColor.clearColor()
            
        } else {
            
            cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            
        }

        return cell
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Manually call refresh upon loading to get most up to datest datas
        refresh()
        
    }
    
    
    // Interaction when tapping on row (ie: follower user)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get cell that has been tapped on
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let followedObjectId = userids[indexPath.row]
        
        // Check if already following and UNFOLLOW instead
        if isGroupie[followedObjectId] == false {
            
            isGroupie[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            /*
            var follow = PFObject(className: "Follow")
            follow["following"] = userids[indexPath.row]
            follow["follower"] = PFUser.currentUser()?.objectId
            
            // This has to be here or the "delete" section creates an empty entry in the DB
            follow.saveInBackground()
            */
            
        } else {
            
            isGroupie[followedObjectId] = false
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            /*
            // Check if this user is being following by the current user
            var query = PFQuery(className: "Follow")
            
            // Set query keys
            // Error here was from the login check not functioning properly, so
            // we reached this point even though we weren't logged in
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            // This happen in random order, so we can't guarantee the results will
            // match the local arrays that determine who is following whom! (username/userids)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                // if objects = objects it must be the case that this user is being followed
                if let temp = objects {
                    
                    for object in temp {
                        
                        object.deleteInBackground()
                        
                    }
                }
            })
            */
        }
        
        // SEND DATA BACK -------------------------------------------------------------------------
        // SEND DATA BACK -------------------------------------------------------------------------
        
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
