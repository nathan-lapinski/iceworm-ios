//
//  GroupiesTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesTableViewController: UITableViewController, UISearchBarDelegate, UIPopoverPresentationControllerDelegate  {
    
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
    let section2: String = "Facebook and sQs Friends"
    var objs2: [String] = [String]()
    let section3: String = "sQs Users"
    var allSelected = Bool()
    
    var friendEntry: UITextField!
    
    var facebookNames = [""]
    var facebookIds = [friendStruct]()
    var socialQsNames = [""]
    var socialQsIds = [""]
    var users = [String]()
    var objectsArray = [Objects]()
    //    var allFriendsDictionary = Dictionary<String, friendStruct>()
    //    var allFriendsDictionarySorted = Dictionary<String, String>()
//    var allFriendsDictionary2 = [Dictionary<String, AnyObject>]()
//    var allFriendsDictionary2Filtered = [Dictionary<String, AnyObject>]()
    var filteredFriends = [String]()
//    var filteredFriendsIds = [friendStruct]()
    var fbAndSQNames = [String]()
    var sqOnlyNames = [String]()
//    var tempIds = [friendStruct]()
    var selectedUsers = String() // matches isGroupieName but is not sorted
    
    var friendsDictionary = [Dictionary<String, AnyObject>]()
    var friendsDictionaryFiltered = [Dictionary<String, AnyObject>]()
    var nonFriendsDictionary = [Dictionary<String, AnyObject>]()
    var nonFriendsDictionaryFiltered = [Dictionary<String, AnyObject>]()
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBAction func optionsPressed(sender: AnyObject) {
        
//        func configurationTextField(textField: UITextField!) {
//            
//            textField.placeholder = ""
//            friendEntry = textField
//        }
//        
//        func handleCancel(alertView: UIAlertAction!) {
//            
//            println("Cancelled !!")
//        }
//        
//        var alert = UIAlertController(title: "Enter a SocialQs handle", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addTextFieldWithConfigurationHandler(configurationTextField)
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
//        
//        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
//            
//            self.addUser(self.friendEntry.text)
//            
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: {
//            
//            println("completion block")
//        })
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBAction func dismissPressed(sender: AnyObject) {
        
        // ---------------------------------------------------------------------------------
        // Trim allFriendsDictionary2 to selectedFriendsDictionary2 before switching back
        isGroupieName.removeAll(keepCapacity: true)
        groupiesDictionary.removeAll(keepCapacity: true)
        
        for temp in friendsDictionary {
            if temp["isSelected"] as! Bool == true {
                groupiesDictionary.append(temp)
                isGroupieName.append(temp["name"] as! String)
            }
        }
        // ---------------------------------------------------------------------------------
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()// Do any additional setup after loading the view.
        
        if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            
            var alert = UIAlertController(title: "Find Your Friends!", message: "Send this Q to your Facebook friends by linking your account in the SocialQs settings page!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
            
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("toSettingsFromGroupies", sender: self)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        searchBar.delegate = self
        
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
        
        friendsDictionary.removeAll(keepCapacity: true)
        
        // Get List Of All Friends
        //var friendsRequest = FBSDKGraphRequest(graphPath:"/me/taggable_friends?fields=name,id&limit=1000", parameters: nil);
        // Get List Of Friends who have SOCIALQS
        var friendsRequest = FBSDKGraphRequest(graphPath:"/me/friends?fields=name,id,picture&limit=1000", parameters: nil);
        
        friendsRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                var temp: AnyObject = result["data"]!!
                
                var tempDict = Dictionary<String, AnyObject>()
                
                for var i = 0; i < temp.count; i++ {
                    
                    tempDict.removeAll(keepCapacity: true)
                    
                    tempDict["name"] = temp[i]["name"]!! as! String
                    tempDict["type"] = "facebookWithApp"
                    tempDict["id"] = temp[i]["id"]!! as! String
                    tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
                    tempDict["isSelected"] = false
                    
                    if contains(isGroupieName, temp[i]["name"]!! as! String) {
                        
                        tempDict["isSelected"] = true
                    }
                    
                    self.friendsDictionary.append(tempDict)
                    
                }
                
                // get myFriends and add to dictionary
                var socialQsUsersQuery = PFQuery(className: "_User")
                socialQsUsersQuery.whereKey("username", notEqualTo: username) // omit current user
                socialQsUsersQuery.whereKey("username", containedIn: myFriends) // No users that are already myFriends
                socialQsUsersQuery.whereKeyDoesNotExist("authData") // No users linked to FB
                
                socialQsUsersQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        
                        if let temp = objects {
                            
                            for object in temp {
                                
                                var tempDict = Dictionary<String, AnyObject>()
                                
                                tempDict["name"] = object.username!!
                                tempDict["type"] = "socialQs"
                                tempDict["id"] = object.objectId!!
                                tempDict["isSelected"] = false
                                //tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
                                
                                self.friendsDictionary.append(tempDict)
                            }
                        }
                        
                        self.loadUsers("")
                    }
                })
                
            } else {
                
                println("Error retrieving Facebook and sQs Users")
                println(error)
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
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // GET sQs users for search purposes
        // must load each time for search functionality to work
        //// Pull SocialQs Users (omit anyone who is FB linked) and include in additional section under FB/myFriends
        var socialQsUsersQuery = PFQuery(className: "_User")
        socialQsUsersQuery.whereKey("username", containsString: name) // all users with search string in username
        socialQsUsersQuery.whereKey("username", notEqualTo: username) // omit current user
        socialQsUsersQuery.whereKey("username", notContainedIn: myFriends) // No users that are already myFriends
        socialQsUsersQuery.whereKeyDoesNotExist("authData") // No users linked to FB
        
        socialQsUsersQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                self.nonFriendsDictionary.removeAll(keepCapacity: true)
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        var tempDict = Dictionary<String, AnyObject>()
                        
                        tempDict["name"] = object.username!!
                        tempDict["type"] = "socialQs"
                        tempDict["id"] = object.objectId!!
                        tempDict["isSelected"] = false
                        //tempDict["picURL"] = temp[i]!["picture"]!!["data"]!!["url"]!!
                        
                        self.nonFriendsDictionary.append(tempDict)
                    }
                }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                // Sort dictionaries
                self.friendsDictionary.sort { (item1, item2) -> Bool in
                    
                    let t1 = (item1["name"] as! String).lowercaseString
                    let t2 = (item2["name"] as! String).lowercaseString
                    
                    return t1 < t2
                }
                self.nonFriendsDictionary.sort { (item1, item2) -> Bool in
                    
                    let t1 = (item1["name"] as! String).lowercaseString
                    let t2 = (item2["name"] as! String).lowercaseString
                    
                    return t1 < t2
                }
                
                // Fill display strings
                self.fbAndSQNames.removeAll(keepCapacity: true)
                for temp in self.friendsDictionary {
                    
                    self.fbAndSQNames.append(temp["name"] as! String)
                }
                self.sqOnlyNames.removeAll(keepCapacity: true)
                for temp in self.nonFriendsDictionary {
                    
                    self.sqOnlyNames.append(temp["name"] as! String)
                }
                
                // reset all entries in filtered users
                self.friendsDictionaryFiltered.removeAll(keepCapacity: true)
                self.nonFriendsDictionaryFiltered.removeAll(keepCapacity: true)
                
                var sectionTwoItems = [String]()
                var sectionThreeItems = [String]()
                
                // Fill filtered dictionaries from full dict and search key
                if !name.isEmpty {
                    
                    // Filter users by searchBar input
                    var fbAndSQNamesFiltered = self.fbAndSQNames.filter({(item: String) -> Bool in
                        
                        var stringMatch = item.lowercaseString.rangeOfString(name.lowercaseString)
                        return stringMatch != nil ? true : false
                    })
                    var sqOnlyNamesFiltered = self.sqOnlyNames.filter({(item: String) -> Bool in
                        
                        var stringMatch = item.lowercaseString.rangeOfString(name.lowercaseString)
                        return stringMatch != nil ? true : false
                    })
                    
                    // Fill filtered dictionaries
                    for name in fbAndSQNamesFiltered {
                        var index = find(self.fbAndSQNames, name)!
                        self.friendsDictionaryFiltered.append(self.friendsDictionary[index])
                    }
                    for name in sqOnlyNamesFiltered {
                        var index = find(self.sqOnlyNames, name)!
                        self.nonFriendsDictionaryFiltered.append(self.nonFriendsDictionary[index])
                    }
                    
                    sectionTwoItems = fbAndSQNamesFiltered
                    sectionThreeItems = sqOnlyNamesFiltered
                    
                } else {
                    
                    self.friendsDictionaryFiltered = self.friendsDictionary
                    self.nonFriendsDictionaryFiltered = self.nonFriendsDictionary
                    
                    sectionTwoItems = self.fbAndSQNames
                    sectionThreeItems = self.sqOnlyNames
                    
                }
                
                // Fill object to populate table
                self.objectsArray = [Objects(sectionName: self.section1, sectionObjects: [""]), Objects(sectionName: self.section2, sectionObjects: sectionTwoItems), Objects(sectionName: self.section3, sectionObjects: sectionThreeItems)]
                
                self.tableView.reloadData()
                
            } else {
                
                println("Error pulling non-friends")
                println(error)
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
        
        var cell = GroupiesCell()
        
        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("groupiesHeaderCell", forIndexPath: indexPath) as! GroupiesCell
            
            // Configure the cell...
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.groupiesLabel.textColor = UIColor.darkTextColor() //UIColor.whiteColor()
            cell.groupiesLabel.backgroundColor = UIColor.clearColor()
            
            if isGroupieName.count > 0 {
                // Build display string
                selectedUsers = ", ".join(isGroupieName)
                cell.groupiesLabel.text = selectedUsers
                cell.groupiesLabel.textColor = UIColor.darkTextColor()
            } else {
                cell.groupiesLabel.text = ""//"Selected Groupies"
                cell.groupiesLabel.textColor = UIColor.grayColor()
            }
            
            cell.backgroundColor = UIColor.clearColor()
            cell.groupiesLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            
        } else if indexPath.section == 1 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("groupiesCell", forIndexPath: indexPath) as! GroupiesCell
            
            // Configure the cell...
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Format cell
            cell.backgroundColor = UIColor.clearColor()
            cell.usernameLabel.textColor = UIColor.darkTextColor() //UIColor.whiteColor()
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)
            cell.usernameLabel.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
            
            // Add profile pics
            if let image: UIImage = self.friendsDictionaryFiltered[indexPath.row]["profilePicture"] as? UIImage {
                println("1")
                cell.profilePictureImageView.image = image
            } else {
                
                if let url = (friendsDictionaryFiltered[indexPath.row]["picURL"]) as? String {
                    println("2")
                    let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
                    
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                        
                        self.friendsDictionaryFiltered[indexPath.row]["profilePicture"] = UIImage(data: data)!
                        self.friendsDictionary[indexPath.row]["profilePicture"] = UIImage(data: data)!
                        cell.profilePictureImageView.image = self.friendsDictionaryFiltered[indexPath.row]["profilePicture"] as? UIImage
                    }
                    
                } else {
                    println("3")
                    friendsDictionaryFiltered[indexPath.row]["profilePicture"] = UIImage(named: "profile.png")!
                    friendsDictionary[indexPath.row]["profilePicture"] = UIImage(named: "profile.png")!
                    cell.profilePictureImageView.image = friendsDictionaryFiltered[indexPath.row]["profilePicture"] as? UIImage
                }
                
            }
            
            cell.profilePictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.profilePictureImageView.clipsToBounds = true
            
            // add account-type pics
            if friendsDictionaryFiltered[indexPath.row]["type"] as! String == "facebookWithApp" {
                
                cell.accountTypeImageView.image = UIImage(named: "share_facebook.png")
                
            } else if friendsDictionaryFiltered[indexPath.row]["type"] as! String == "socialQs" {
                
                cell.accountTypeImageView.image = UIImage(named: "logo_square.png")
            }
            cell.accountTypeImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.accountTypeImageView.clipsToBounds = true
            cell.accountTypeImageView.backgroundColor = mainColorBlue
            
            if friendsDictionaryFiltered[indexPath.row]["isSelected"] as! Bool == true {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.accountTypeImageView.alpha = 0.2
                
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.accountTypeImageView.alpha = 1.0
            }
            
        } else { // section 2
            
            cell = tableView.dequeueReusableCellWithIdentifier("groupiesCell", forIndexPath: indexPath) as! GroupiesCell
            
            // Configure the cell...
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Format cell
            cell.backgroundColor = UIColor.clearColor()
            cell.usernameLabel.textColor = UIColor.darkTextColor() //UIColor.whiteColor()
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)
            cell.usernameLabel.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
            
            // Add profile pics
            cell.profilePictureImageView.image = UIImage(named: "profile.png")
            cell.profilePictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.profilePictureImageView.clipsToBounds = true
            
            // add account-type pics
            cell.accountTypeImageView.image = UIImage(named: "logo_square.png")
            cell.accountTypeImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.accountTypeImageView.clipsToBounds = true
            cell.accountTypeImageView.backgroundColor = mainColorBlue
        }
    
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Resign keyboard when tapping on a row
        self.tableView.endEditing(true)
        
        // Get cell that has been tapped on
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            
            friendsDictionary[indexPath.row]["isSelected"] = !(friendsDictionary[indexPath.row]["isSelected"] as! Bool)
            friendsDictionaryFiltered[indexPath.row]["isSelected"] = !(friendsDictionaryFiltered[indexPath.row]["isSelected"] as! Bool)
            
            if (friendsDictionary[indexPath.row]["isSelected"] as! Bool) == true {
                if !contains(isGroupieName, friendsDictionary[indexPath.row]["name"] as! String) {
                    isGroupieName.append(friendsDictionary[indexPath.row]["name"] as! String)
                }
            } else {
                let index = find(isGroupieName, friendsDictionary[indexPath.row]["name"] as! String)
                if index != nil {
                    isGroupieName.removeAtIndex(index!)
                }
            }
            
            var count = 0
            for var i = 0; i < friendsDictionary.count; i++ {
                
                if friendsDictionary[i]["isSelected"] as! Bool == true {
                    count++
                }
            }
            
        } else { // section 2
            
            println(indexPath.row)
            println(nonFriendsDictionaryFiltered)
            
            if !contains(myFriends, nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String) {
                
                myFriends.append(nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String)
            }
            
            tableView.reloadData()
            
        }
        
        selectedUsers = ", ".join(isGroupieName)
        
        // refresh applicable rows
        let sectionZeroIndex = NSIndexPath(forRow: 0, inSection: 0)
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        //tableView.reloadRowsAtIndexPaths([sectionZeroIndex], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    
    
    // POPOVER SETTINGS FUNCTIONS
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "optionsFloat" {
            let popoverViewController = segue.destinationViewController as! UIViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    // POPOVER SETTINGS FUNCTIONS
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}






