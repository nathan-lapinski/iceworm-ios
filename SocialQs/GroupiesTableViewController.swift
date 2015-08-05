//
//  GroupiesTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesTableViewController: UITableViewController, UISearchBarDelegate {
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    struct friendStruct {
        var type: String
        var id: String
    }
    
    var viewWillAppearCount = 0
    
    let tableFontSize = CGFloat(16)
    let section1: String = ""
    let objs1: [String] = ["All Users"]
    let section2: String = ""//"Facebook Friends"
    var objs2: [String] = [String]()
    let section3: String = "SocialQs Friends"
    var allSelected = Bool()
    
    var friendEntry: UITextField!
    
    var facebookNames = [""]
    var facebookIds = [friendStruct]()
    var socialQsNames = [""]
    var socialQsIds = [""]
    var users = [String]()
    var objectsArray = [Objects]()
    var allFriendsDictionary = Dictionary<String, friendStruct>()
    var allFriendsDictionary2 = [Dictionary<String, AnyObject>]()
    var allFriendsDictionary2Filtered = [Dictionary<String, AnyObject>]()
    var allFriendsDictionarySorted = Dictionary<String, String>()
    var filteredFriends = [String]()
    var filteredFriendsIds = [friendStruct]()
    var tempNames = [String]()
    var tempIds = [friendStruct]()
    
    @IBOutlet var searchBar: UISearchBar!
    @IBAction func optionsPressed(sender: AnyObject) {
        
        func configurationTextField(textField: UITextField!) {
            
            textField.placeholder = "Enter an item"
            friendEntry = textField
        }
        
        func handleCancel(alertView: UIAlertAction!) {
            
            println("Cancelled !!")
        }
        
        var alert = UIAlertController(title: "Enter Input", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
            
            // Check for SocialQs username of \(friendEntry)
            var friendQuery = PFQuery(className: "_User")
            friendQuery.whereKey("username", equalTo: self.friendEntry.text)
            
            friendQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error == nil {
                    
                    if objects!.count > 0 {
                            
                        // Add this user to current users permanent friends AND ensure this friend is automatically a groupie for this Q
                        mySocialQsFriends.append(objects![0]["username"] as! String)
                        
                        // Query for User info for mySocialQsFriends
                        var socialQsFriendQuery = PFUser.query()!
                        socialQsFriendQuery.whereKey("username", equalTo: self.friendEntry.text)
                        
                        socialQsFriendQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            
                            if error == nil {
                                
                                self.allFriendsDictionary[objects![0].username!!] = friendStruct(type: "socialQs", id: objects![0].objectId!!)
                                self.allFriendsDictionary2.append(["name": objects![0].username!!, "type": "socialQs", "id": objects![0].objectId!!])//, "pic": UIImagePNGRepresentation(UIImage(named: "camera.png"))])
                            }
                            
                            self.loadUsers("")
                        })
                        
                    } else {
                    
                        displayAlert("Oops!", "The SocialQs handle \(self.friendEntry.text) could not be found. Please check the spelling and try again!", self)
                    }
                }
            })
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            
            println("completion block")
        })
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()// Do any additional setup after loading the view.
        
        searchBar.delegate = self
        
        if username == "" { println("myName is empty!") }
        
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
        
        tempNames.removeAll(keepCapacity: true)
        tempIds.removeAll(keepCapacity: true)
        
        // Get List Of Friends who have SOCIALQS
        var friendsRequest = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
        // Get List Of All Friends
        //var friendsRequest = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id&limit=1000", parameters: nil);
        
        friendsRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                var temp: AnyObject = result["data"]!!
                
                for var i = 0; i < temp.count; i++ {
                    
                    //println(temp[i]!["picture"]!!["data"]!!["url"]!!)
                    
                    //self.allFriendsDictionary[temp[i]["id"]!! as! String] = temp[i]["name"]!! as? String
                    self.allFriendsDictionary[temp[i]["name"]!! as! String] = friendStruct(type: "facebookWithApp", id: temp[i]["id"]!! as! String)
                    
                    self.allFriendsDictionary2.append(["name": temp[i]["name"]!! as! String, "type": "facebookWithApp", "id": temp[i]["id"]!! as! String])//, "picURL": temp[i]!["picture"]!!["data"]!!["url"]!!])
                }
                
                // Manually call refresh upon loading to get most up to datest datas
                self.loadUsers("")
                
            } else {
                
                println("Error Getting Friends \(error)")
                
                if self.viewWillAppearCount > 3 {
                    
                    self.viewWillAppearCount = 0
                    
                    displayAlert("Sorry", "There was an error retrieving your friends. Please try again shortly!", self)
                    
                } else {
                    
                    self.viewWillAppearCount++
                    
                    self.viewWillAppear(true)
                }
            }
        }
    }
    
    
    func loadUsers(name: String) {
        
//        self.allFriendsDictionary2.sort { (item1, item2) -> Bool in
//            
//            let t1 = (item1["name"] as! String).lowercaseString
//            let t2 = (item2["name"] as! String).lowercaseString
//            
//            return t1 < t2
//        }
        
        tempNames.removeAll(keepCapacity: true)
        //tempIds.removeAll(keepCapacity: true)
        
        for temp in allFriendsDictionary2 {
            
            tempNames.append(temp["name"] as! String)
            //tempIds.append(temp["id"] as! String)
        }
        
        if !name.isEmpty {
            
            // Filter users by searchBar input
            var filteredStrings = self.tempNames.filter({(item: String) -> Bool in
                
                var stringMatch = item.lowercaseString.rangeOfString(name.lowercaseString)
                return stringMatch != nil ? true : false
            })
            
            
            
            // reset all entries in filtered users
            //self.filteredFriendsIds.removeAll(keepCapacity: true)
            self.allFriendsDictionary2Filtered.removeAll(keepCapacity: true)
            
            // Fill FB userIds
            for name in filteredStrings {
                var index = find(self.tempNames, name)!
                //self.filteredFriendsIds.append(self.tempIds[index])
                self.allFriendsDictionary2Filtered.append(self.allFriendsDictionary2[index])
            }
            
            // Set arrays to fill table
            self.facebookNames = filteredStrings
            //self.facebookIds = self.filteredFriendsIds
            
            self.allFriendsDictionary2Filtered.sort { (item1, item2) -> Bool in
                
                let t1 = (item1["name"] as! String).lowercaseString
                let t2 = (item2["name"] as! String).lowercaseString
                
                return t1 < t2
            }
            
            println(allFriendsDictionary2Filtered)
            
            tempNames.removeAll(keepCapacity: true)
            //tempIds.removeAll(keepCapacity: true)
            
            for temp in allFriendsDictionary2Filtered {
                
                tempNames.append(temp["name"] as! String)
                //tempIds.append(temp["id"] as! String)
            }
            
        } else {
            
            self.allFriendsDictionary2.sort { (item1, item2) -> Bool in
                
                let t1 = (item1["name"] as! String).lowercaseString
                let t2 = (item2["name"] as! String).lowercaseString
                
                return t1 < t2
            }
            
            tempNames.removeAll(keepCapacity: true)
            //tempIds.removeAll(keepCapacity: true)
            
            for temp in allFriendsDictionary2 {
                
                tempNames.append(temp["name"] as! String)
                //tempIds.append(temp["id"] as! String)
            }
            
            // else keep all users in view
            self.facebookNames = self.tempNames
            //self.facebookIds = self.tempIds
        }
        
        self.objectsArray = [Objects(sectionName: self.section1, sectionObjects: self.objs1), Objects(sectionName: self.section2, sectionObjects: self.facebookNames)]//, Objects(sectionName: self.section3, sectionObjects: self.socialQsNames)]
        
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
            
            let followedObjectName = facebookNames[indexPath.row] as String
            let followedObjectId = facebookIds[indexPath.row].id as String
            
            // Check if already following and UNFOLLOW instead
            if contains(isGroupieName, followedObjectName) {
                
                // Remove user from isGroupieName
                if var removeIndex = find(isGroupieName, followedObjectName) {
                    
                    isGroupieName.removeAtIndex(removeIndex)
                }
                
                // Remove user from isGroupieQId
                if var removeIndex = find(isGroupieQId, followedObjectId) {
                    
                    isGroupieQId.removeAtIndex(removeIndex)
                }
                
            } else {
                
                // Add user to isGroupieName
                isGroupieName.append(followedObjectName)
                
                // Add user to isGroupieQId
                isGroupieQId.append(followedObjectId)
                
            }
            
            // Set allSelected checkmark if all users are manually selected
            if isGroupieName.count == facebookNames.count && allSelected == false {
                
                allSelected = true
                
                var indexPathOther = NSIndexPath(forRow: 0, inSection: 0)
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
            }
            
            if isGroupieName.count != facebookNames.count && allSelected == true {
                
                allSelected = false
                
                tableView.beginUpdates()
                let reload = NSIndexSet(index: 0) // Reload other section
                tableView.reloadSections(reload, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
            }
            
        } else { // section == 0
            
            if allSelected == false {
                
                allSelected = true
                isGroupieName = facebookNames
//                isGroupieQId = facebookIds
                
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
    }
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section != 0 {
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            
            header.contentView.backgroundColor = UIColor.whiteColor() // mainColorBlue
            header.contentView.alpha = 0.6
            
            header.textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            header.textLabel.textAlignment = NSTextAlignment.Right
            header.textLabel.textColor = UIColor.darkTextColor()
            header.textLabel.text = objectsArray[section].sectionName
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            
            return CGFloat(18)
            
        } else {
            
            return CGFloat(0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}






