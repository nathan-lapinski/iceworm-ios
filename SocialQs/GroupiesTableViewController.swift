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
    var allFriends = [String]()
    var allFriendsIds = [String]()
    var filteredFriends = [String]()
    var filteredFriendsIds = [String]()
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

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
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg4.png"))
        self.tableView.backgroundView?.alpha = 0.4
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Initialize allSelected var the first time the controller is presented
        allSelected = false

    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        topOffset = 64
        
        // Get List Of Friends using SOCIALQS
        //var socialQsFriendsRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        // Get List Of All Friends
        var allFriendsRequest = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id&limit=1000", parameters: nil);
        
        allFriendsRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                
                var temp: AnyObject = result["data"]!!
                
                for var i = 0; i < temp.count; i++ {
                    //println(temp[i]["name"]!! as! String)
                    //println(temp[i]["id"]!! as! String)
                    self.allFriends.append(temp[i]["name"]!! as! String)
                    self.allFriendsIds.append(temp[i]["id"]!! as! String)
                }
                
                // Manually call refresh upon loading to get most up to datest datas
                self.loadUsers("")
                
            } else {
                println("Error Getting Friends \(error)");
            }
        }
    }
    
    
    func loadUsers(name: String) {
        
        if !name.isEmpty {
            
            // Filter users by serachBar input
            var filteredStrings = self.allFriends.filter({(item: String) -> Bool in
                
                var stringMatch = item.lowercaseString.rangeOfString(name.lowercaseString)
                return stringMatch != nil ? true : false
            })
            
            // reset all entries in filtered users
            filteredFriendsIds.removeAll(keepCapacity: true)
            
            // Fill FB userIds
            for name in filteredStrings {
                var index = find(allFriends, name)!
                filteredFriendsIds.append(allFriendsIds[index])
            }
            
            // Set arrays to fill table
            usernames = filteredStrings
            userids = filteredFriendsIds
            
        } else {
            
            // else keep all users in view
            usernames = allFriends
            userids = allFriendsIds
        }
        
        
        
        
        
        self.objectsArray = [Objects(sectionName: self.section1, sectionObjects: self.objs1), Objects(sectionName: self.section2, sectionObjects: self.usernames)]
        
        self.tableView.reloadData()
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
        cell.usernameLabel.textColor = UIColor.darkTextColor() //UIColor.whiteColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0 {
            
            cell.backgroundColor = UIColor.clearColor()
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue", size: tableFontSize)!
            
            if allSelected == false {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            } else if allSelected == true {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            }
            
        } else {
            
            // Format cell backgrounds
            cell.backgroundColor = UIColor.clearColor()
            //if indexPath.row % 2 == 0 { cell.backgroundColor = UIColor.clearColor() }
            //else { cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4) }
            
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)
            
            let followedObjectName = objectsArray[indexPath.section].sectionObjects[indexPath.row] as String
            
            if contains(isGroupieName, followedObjectName) {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            }
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
        
        // SEND DATA BACK -------------------------------------------------------------------------
        // SEND DATA BACK -------------------------------------------------------------------------
    }
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section != 0 {
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            
            header.contentView.backgroundColor = UIColor.whiteColor() // mainColorBlue
            header.contentView.alpha = 0.7
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            
            return CGFloat(2)
            
        } else {
            
            return CGFloat(0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
