//
//  GroupiesTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesTableViewController: UITableViewController, UISearchBarDelegate {
    
    let tableFontSize = CGFloat(16)
    let section1: String = ""
    let objs1: [String] = ["All Users"]
    let section2: String = ""
    var objs2: [String] = [String]()
    var allSelected = Bool()
    
    var usernames = [""]
    var userids = [""]
    var users = [String]()
    var objectsArray = [Objects]()
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var searchBar: UISearchBar!
    
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
        
        searchBar.delegate = self
        
        if myName == "" { println("myName is empty!") }
        
        // Title table controller
        self.title = "Select Groupies"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissPressed:")
    
        // Format Done button
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue", size: tableFontSize)!], forState: UIControlState.Normal)
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "splash_no_logo.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Initialize allSelected var the first time the controller is presented
        allSelected = false

    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Manually call refresh upon loading to get most up to datest datas
        loadUsers("")
        
    }
    
    
    func loadUsers(name: String) {
        
        var findUsers = PFUser.query()
        
        if !name.isEmpty {
            findUsers?.whereKey("username", containsString: name)
        }
        
        findUsers?.whereKey("username", notEqualTo: myName)
        
        findUsers?.findObjectsInBackgroundWithBlock({ (userObjects, error) -> Void in
            
            if error == nil {
                
                if let users = userObjects {
                    
                    self.usernames.removeAll(keepCapacity: true)
                    self.userids.removeAll(keepCapacity: true)
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            self.usernames.append(user.username!)
                            self.userids.append(user["uQId"]! as! String)
                            
                        }
                    }
                }
                
                self.objectsArray = [Objects(sectionName: self.section1, sectionObjects: self.objs1), Objects(sectionName: self.section2, sectionObjects: self.usernames)]
                
                self.tableView.reloadData()
                
            }
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        loadUsers(searchText)
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        loadUsers("")
        
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectsArray.count
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray[section].sectionObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupiesCell", forIndexPath: indexPath) as! GroupiesCell
    
        // Configure the cell...
        cell.usernameLabel.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        cell.usernameLabel.textColor = UIColor.whiteColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0 {
            
            cell.backgroundColor = UIColor.clearColor()
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: tableFontSize)!
            
            if allSelected == false {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            } else if allSelected == true {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            }
            
        } else {
            
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue", size: tableFontSize)
            
            let followedObjectName = objectsArray[indexPath.section].sectionObjects[indexPath.row] as String
            
            if contains(isGroupieName, followedObjectName) {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            }
            
            // Format cell backgrounds
            //if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.clearColor()
            //} else {
            //    cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            //}
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get cell that has been tapped on
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if indexPath.section == 1 {
            
            let followedObjectName = usernames[indexPath.row] as String
            let followedObjectId = userids[indexPath.row] as String
            
            // Check if already following and UNFOLLOW instead
            if contains(isGroupieName, followedObjectName) {
                
                //println("\(followedObjectName) is no longer being followed")
                
                // Remove user from isGroupieName
                if var removeIndex = find(isGroupieName, followedObjectName) {
                    
                    isGroupieName.removeAtIndex(removeIndex)
                    
                }
                
                // Remove user from isGroupieQId
                if var removeIndex = find(isGroupieQId, followedObjectId) {
                    
                    isGroupieQId.removeAtIndex(removeIndex)
                    
                }
                
            } else {
                
                //println("\(followedObjectName) is now being followed")
                
                // Add user to isGroupieName
                isGroupieName.append(followedObjectName)
                
                // Add user to isGroupieQId
                isGroupieQId.append(followedObjectId)
                
            }
            
            // Set allSelected checkmark if all users are manually selected
            if isGroupieName.count == usernames.count && allSelected == false {
                
                allSelected = true
                
                var indexPathOther = NSIndexPath(forRow: 0, inSection: 0)
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
                
            }
            
            if isGroupieName.count != usernames.count && allSelected == true {
                
                allSelected = false
                
                tableView.beginUpdates()
                let reload = NSIndexSet(index: 0) // Reload other section
                tableView.reloadSections(reload, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
                
            }
            
        } else { // section == 0
            
            if allSelected == false {
                
                allSelected = true
                isGroupieName = usernames
                isGroupieQId = userids
                
            } else if allSelected == true {
                
                allSelected = false
                isGroupieName.removeAll(keepCapacity: true)
                isGroupieQId.removeAll(keepCapacity: true)
                
            }
            
            tableView.beginUpdates()
            let reload = NSIndexSet(index: 1) // Reload other section
            tableView.reloadSections(reload, withRowAnimation: UITableViewRowAnimation.None)
            tableView.endUpdates()
            
        }
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        tableView.endUpdates()
        
        println(isGroupieName)
        println(isGroupieQId)
        
        // SEND DATA BACK -------------------------------------------------------------------------
        // SEND DATA BACK -------------------------------------------------------------------------
    }
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section != 0 {
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            
            header.contentView.backgroundColor = mainColorBlue
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            
            return CGFloat(5)
            
        } else {
            
            return CGFloat(0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    
    
    
    /*
    func refreshXX() {
    
    var query = PFUser.query()
    
    query?.whereKey("objectId", notEqualTo: uId)
    
    query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    
    if let users = objects {
    
    self.usernames.removeAll(keepCapacity: true)
    //self.userids.removeAll(keepCapacity: true)
    self.isGroupie.removeAll(keepCapacity: true)
    
    for object in users {
    
    if let user = object as? PFUser {
    
    self.isGroupie[user.objectId!] = false
    
    // Do check to make sure these exist!!!!!!!!!!!!!!!!!!!!!!!!!!
    //
    self.usernames.append(user.username!)
    //self.userids.append(user.objectId!)
    
    
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
    */

}
