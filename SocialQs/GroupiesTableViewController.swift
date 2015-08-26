//
//  GroupiesTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesTableViewController: UITableViewController, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, GroupiesSettingsTableViewControllerDelegate {
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    var viewWillAppearCount = 0
    
    var textView = UITextView()
    var groupEntry: UITextField!
    
    let tableFontSize = CGFloat(16)
    var keyboardSize = CGFloat()
    let section1: String = ""
    let objs1: [String] = ["All Users"]
    let section2: String = ""//"sQs Friends"//Facebook and sQs Friends"
    var objs2: [String] = [String]()
    let section3: String = "sQs Users"
    var searchCancelled = false
    
    var objectsArray = [Objects]()
    var fbAndSQNames = [String]()
    var sqOnlyNames = [String]()
    var selectedUsers = String() // matches isGroupieName but is not sorted
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBAction func addGroupButtonAction(sender: AnyObject) { }
    @IBAction func clearButtonAction(sender: AnyObject) { }
    
    @IBAction func optionsPressed(sender: AnyObject) { }
    
    @IBAction func inviteButtonAction(sender: AnyObject) { }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        buildGroupiesDictionary()
        
        //
        //
        // Build Friends join table entries
        //
        //
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func createGroup () {
        
        buildGroupiesDictionary()
        
        func configurationTextField(textField: UITextField!) {
            
            textField.placeholder = ""
            groupEntry = textField
        }
        
        func handleCancel(alertView: UIAlertAction!) {
            
            println("Cancelled !!")
        }
        
        var alert = UIAlertController(title: "Enter group name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        alert.addAction(UIAlertAction(title: "Create Group", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
            
            self.resignFirstResponder()
            
            var groupName = "New Group"
            
            if self.groupEntry.text != "" {
                
                groupName = self.groupEntry.text
            }
            
        
            println(groupiesDictionary)
            
            var groupObjects: [PFObject] = []
            
            for groupie in self. {
                
                var qJoin = PFObject(className: "QJoin")
                qJoin.setObject(PFUser.currentUser()!, forKey: "asker")
                qJoin.setObject(sQsGroupie, forKey: "to")
                qJoin.setObject(PFUser.currentUser()!, forKey: "from")
                qJoin.setObject(false, forKey: "askeeDeleted")
                qJoin.setObject(socialQ, forKey: "question")
                
                sQsGroupieObjects.append(qJoin)
                
            }
            //
            //
            // Create Group join table entry
            //
            //
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            
            println("completion block")
        })
        
        //
        //
        // CLOUD SHITS
        //
        //
        
        
    }
    
    
    func buildGroupiesDictionary() {
        
        // Trim friendsDictionary to selectedFriendsDictionary2 before switching back
        isGroupieName.removeAll(keepCapacity: true)
        groupiesDictionary.removeAll(keepCapacity: true)
        
        for temp in friendsDictionary {
            if temp["isSelected"] as! Bool == true {
                groupiesDictionary.append(temp)
                isGroupieName.append(temp["name"] as! String)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()// Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveSettingsSavedNotification:", name: "SettingsSavedNotification", object: nil)
        
        if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            
            var alert = UIAlertController(title: "Find Your Friends!", message: "Send this Q to your Facebook friends by linking your account in the SocialQs settings page!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
            
            alert.addAction(UIAlertAction(title: "Link With Facebook", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                linkUserWithFacebook({ (success, message) -> Void in
                    
                    if success == true {
                        
                        println(message)
                        
                        // User is now linked, download their friends for groupies use
                        downloadFacebookFriends({ (isFinished) -> Void in
                            
                            println("downloading friends")
                            
                            if isFinished {
                                
                                println("finished downloading friends")
                                
                                self.viewDidLoad()
                                
                            } else {
                                
                                // ********************************************************************
                                //
                                //
                                // HOW TO HANDLE? Try again? Unlink and have them manually retry?
                                //
                                //
                                // ********************************************************************
                            }
                        })
                        
                    } else {
                        
                        displayAlert("Error", "Please verify that the Facebook user currently logged in on this device is not associated with another SocialQs account and try again later", self)
                    }
                })
            }))
            
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
        // get myFriends and add to dictionary
        addFriends(nil)
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.showsCancelButton = true
        
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
        //allSelected = false
        
        // Keyboard open/closed notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func addFriends(newUser: String?) {
        
        var usernameTest = ""
        
        if newUser != nil {
            usernameTest = newUser!
        }
        
        var alreadyAdded = [String]()
        
        for friend in friendsDictionary {
            if friend["type"] as! String == "socialQs" {
                alreadyAdded.append(friend["name"] as! String)
            }
        }
        
        var toAdd = Set(myFriends).subtract(Set(alreadyAdded))
        
        var socialQsUsersQuery = PFQuery(className: "_User")
        socialQsUsersQuery.whereKey("username", notEqualTo: username) // omit current user
        socialQsUsersQuery.whereKey("username", containedIn: Array(toAdd)) // No users that are already myFriends
        socialQsUsersQuery.whereKeyDoesNotExist("authData") // No users linked to FB
        
        socialQsUsersQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error == nil {
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        var tempDict = Dictionary<String, AnyObject>()
                        
                        tempDict["name"] = object.username!!
                        //tempDict["username"] = object.username!!
                        tempDict["type"] = "socialQs"
                        tempDict["id"] = object.objectId!!
                        if tempDict["name"] as! String == usernameTest as String {
                            tempDict["isSelected"] = true
                        } else {
                            tempDict["isSelected"] = false
                        }
                        
                        friendsDictionary.append(tempDict)
                    }
                }
                
                self.loadUsers("")
            }
        })
    }
    
    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        keyboardSize = ((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()).height
//    }
    func keyboardWillAppear(notification: NSNotification) {
//        var searchBarSize = CGFloat(64)
//        self.tableView.contentInset = UIEdgeInsetsMake(searchBarSize,0,keyboardSize,0)
    }
    func keyboardWillDisappear(notification: NSNotification) {
//        var searchBarSize = CGFloat(64)
//        self.tableView.contentInset = UIEdgeInsetsMake(searchBarSize,0,0,0)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        topOffset = 64
        
        tableView.reloadData()
    }
    
    
    func clearSelectedGroupies() {
        
        isGroupieName.removeAll(keepCapacity: true)
        
        for var i = 0; i < friendsDictionary.count; i++ {
            friendsDictionary[i]["isSelected"] = false
            friendsDictionaryFiltered[i]["isSelected"] = false
        }
        
        // Update separately for smooth animation
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
    }
    
    
    func loadUsers(searchName: String) {
        
        self.buildUserStrings(searchName)
    }
    
    
    func buildUserStrings(name: String) {
        
        //:::::::::::::::::::::::::::::::::::::::::::
        // Sort dictionaries
        friendsDictionary.sort { (item1, item2) -> Bool in
            
            let t1 = (item1["name"] as! String).lowercaseString
            let t2 = (item2["name"] as! String).lowercaseString
            
            return t1 < t2
        }
        nonFriendsDictionary.sort { (item1, item2) -> Bool in
            
            let t1 = (item1["name"] as! String).lowercaseString
            let t2 = (item2["name"] as! String).lowercaseString
            
            return t1 < t2
        }
        
        // Fill display strings
        fbAndSQNames.removeAll(keepCapacity: true)
        for temp in friendsDictionary {
            
            self.fbAndSQNames.append(temp["name"] as! String)
        }
        sqOnlyNames.removeAll(keepCapacity: true)
        for temp in nonFriendsDictionary {
            
            self.sqOnlyNames.append(temp["name"] as! String)
        }
        
        // reset all entries in filtered users
        friendsDictionaryFiltered.removeAll(keepCapacity: true)
        nonFriendsDictionaryFiltered.removeAll(keepCapacity: true)
        
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
                friendsDictionaryFiltered.append(friendsDictionary[index])
            }
            for name in sqOnlyNamesFiltered {
                var index = find(self.sqOnlyNames, name)!
                nonFriendsDictionaryFiltered.append(nonFriendsDictionary[index])
            }
            
            sectionTwoItems = fbAndSQNamesFiltered
            sectionThreeItems = sqOnlyNamesFiltered
            
        } else {
            
            friendsDictionaryFiltered = friendsDictionary
            nonFriendsDictionaryFiltered = nonFriendsDictionary
            
            sectionTwoItems = self.fbAndSQNames
            sectionThreeItems = self.sqOnlyNames
        }
        
        // Fill object to populate table
        self.objectsArray = [
            Objects(sectionName: self.section1, sectionObjects: [""]),
            Objects(sectionName: self.section2, sectionObjects: sectionTwoItems)
            ,Objects(sectionName: self.section3, sectionObjects: sectionThreeItems)
        ]
        
        self.tableView.reloadData()
        //:::::::::::::::::::::::::::::::::::::::::::
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        loadUsers(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        println("test")
        searchCancelled = true
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
        
        if searchCancelled == true {
        
            searchBar.resignFirstResponder()
            searchCancelled = false
        }
        
        var cell = GroupiesCell()
        
        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("groupiesHeaderCell", forIndexPath: indexPath) as! GroupiesCell
            
//            // Configure the cell...
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.groupiesLabel.textColor = UIColor.darkTextColor() //UIColor.whiteColor()
//            cell.groupiesLabel.backgroundColor = UIColor.clearColor()
//            
//            if isGroupieName.count > 0 {
//                // Build display string
//                selectedUsers = ", ".join(isGroupieName)
//                cell.groupiesLabel.text = selectedUsers
//                cell.groupiesLabel.textColor = UIColor.darkTextColor()
//                cell.clearButton.hidden = false
//                cell.addGroupButton.hidden = false
//                cell.addGroupButton.layer.borderWidth = 1
//                cell.addGroupButton.layer.borderColor = mainColorBlue.CGColor!
//                cell.addGroupButton.layer.cornerRadius = CGFloat(4)
//            } else {
//                cell.groupiesLabel.text = ""//"Selected Groupies"
//                cell.groupiesLabel.textColor = UIColor.grayColor()
//                cell.clearButton.hidden = true
//                cell.addGroupButton.hidden = true
//            }
//            
//            cell.backgroundColor = UIColor.clearColor()
//            cell.groupiesLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            
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
            
            if let url = friendsDictionaryFiltered[indexPath.row]["picURL"] as? String {
            
                if let image: UIImage = friendsPhotoDictionary[url] {
                    
                    cell.profilePictureImageView.image = image
                    
                } else {
                    
                    cell.profilePictureImageView.image = UIImage(named: "profile.png")
                }
                
            } else {
                
                cell.profilePictureImageView.image = UIImage(named: "profile.png")
            }
            
//            if let image: UIImage = friendsDictionaryFiltered[indexPath.row]["profilePicture"] as? UIImage {
//                
//                cell.profilePictureImageView.image = image
//                
//            } else {
//                
//                if let url = (friendsDictionaryFiltered[indexPath.row]["picURL"]) as? String {
//                    
//                    let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
//                    
//                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
//                        
//                        friendsDictionaryFiltered[indexPath.row]["profilePicture"] = UIImage(data: data)!
//                        friendsDictionary[indexPath.row]["profilePicture"] = UIImage(data: data)!
//                        cell.profilePictureImageView.image = UIImage(data: data)!
//                    }
//                    
//                } else {
//                    
//                    cell.profilePictureImageView.image = UIImage(named: "profile.png")!
//                }
//            }
            
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
            
            // Tag and format invite button
            cell.inviteButton.tag = indexPath.row
            cell.inviteButton.backgroundColor = UIColor.clearColor()
            
            if friendsDictionaryFiltered[indexPath.row]["isSelected"] as! Bool && friendsDictionaryFiltered[indexPath.row]["type"] as! String == "facebookWithoutApp" {
                
                cell.inviteButton.hidden = false
                
            } else {
                
                cell.inviteButton.hidden = true
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
            
            // Hide invite button
            cell.inviteButton.hidden = true
        }
    
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println(friendsDictionaryFiltered[indexPath.row])
        
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        cell.resignFirstResponder()
        
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
            
            
            
            
            // Collapse header if no groupies selectionized
            tableView.beginUpdates()
            if isGroupieName.count < 2 {
                
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
            }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
            
            
            // Fill in selected users - must be after section header refreshing (above)
            textView.text = ", ".join(isGroupieName)
            
            if isGroupieName.count > 0 {
                let text = textView.text
                let textRange = text.startIndex..<text.endIndex
                let attributedString = NSMutableAttributedString(string: text)
                var range: NSRange? = nil
                
                text.enumerateSubstringsInRange(textRange, options: NSStringEnumerationOptions.ByWords, { (substring, substringRange, enclosingRange, stop) -> () in
                    let start = distance(text.startIndex, substringRange.startIndex)
                    let length = distance(substringRange.startIndex, substringRange.endIndex)
                    range = NSMakeRange(start, length)
                })
                textView.scrollRangeToVisible(range!)
            }
                
        } else { // section 2
            
            println(indexPath.row)
            println(nonFriendsDictionaryFiltered)
            
            // Move this user from non-friends to friends dictionary
            // - add to myFriends for whereKey usage in update query
            // - add to isGroupieName to ensure it is selected when moving to section 1
            if !contains(myFriends, nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String) {
                
                var tempDict = nonFriendsDictionaryFiltered[indexPath.row]
                tempDict["isSelected"] = true
                friendsDictionary.append(tempDict)
                myFriends.append(nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String)
                isGroupieName.append(nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String)
                
                for var i = 0; i < nonFriendsDictionary.count; i++ {
                    if nonFriendsDictionary[i]["name"] as! String == nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String {
                        nonFriendsDictionary.removeAtIndex(i)
                        break
                    }
                }
                for var i = 0; i < nonFriendsDictionaryFiltered.count; i++ {
                    if nonFriendsDictionaryFiltered[i]["name"] as! String == nonFriendsDictionaryFiltered[indexPath.row]["name"] as! String {
                        nonFriendsDictionaryFiltered.removeAtIndex(i)
                        buildUserStrings("") // update strings for table display and reload sections
                        break
                    }
                }
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
//            if isGroupieName.count < 1 {
//                return 0 // no users in isSelected display string
//            } else {
//                return 44 // users present in isSelected display string
//            }
            return 0
        } else {
            return 44
        }
    }
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 1 {
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor() // UIColor.whiteColor()
            
            textView = UITextView(frame: CGRectMake(0, -5, self.view.frame.size.width - 92, 68))
            textView.editable = false
            textView.text = ", ".join(isGroupieName)
            textView.backgroundColor = UIColor.clearColor() // mainColorBlue
            textView.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(12))!
            textView.textAlignment = NSTextAlignment.Left
            textView.textColor = UIColor.darkTextColor()
            
            var clearButton = UIButton(frame: CGRectMake(self.tableView.frame.size.width - 28, 22, 20, 20))
            clearButton.setImage(UIImage(named: "clear.png"), forState: UIControlState.Normal)
            clearButton.addTarget(self, action: "clearSelectedGroupies", forControlEvents: .TouchUpInside)
            
            var groupButton = UIButton(frame: CGRectMake(self.tableView.frame.size.width - 88, 17, 52, 30))
            groupButton.layer.borderWidth = 1
            groupButton.layer.borderColor = mainColorBlue.CGColor
            groupButton.layer.cornerRadius = 4
            groupButton.setTitle("+Group", forState: UIControlState.Normal)
            groupButton.setTitleColor(mainColorBlue, forState: UIControlState.Normal)
            groupButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: CGFloat(12))!
            groupButton.addTarget(self, action: "createGroup", forControlEvents: .TouchUpInside)
            
            // Add the shits to the view
            header.addSubview(textView)
            header.addSubview(clearButton)
            header.addSubview(groupButton)
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            
            var ret: CGFloat = 0
                
                if isGroupieName.count < 1 {
                    
                    ret = CGFloat(0)
                    
                } else {
                    
                    ret = CGFloat(64)
                }
            
            return ret
            
        } else {
            
            return CGFloat(0)
        }
    }
    
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
    
    // POPOVER SETTINGS FUNCTIONS
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "optionsFloat" {
            
            let popoverViewController = segue.destinationViewController as! GroupiesSettingsTableViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            //popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.delegate = self
            //
            //
            popoverViewController.strSaveText = "TEST ABC" // Pass data TO popover
            //
            //
            popoverViewController.popoverPresentationController?.backgroundColor = UIColor.darkGrayColor()
            //popoverViewController.preferredContentSize = CGSize(width: 320, height: 186)
            
            // fix view length if number of items below a threshold...
            let numberOfOptions = 1 // "find user" (+group to be removed)
            if (groupiesGroups.count + numberOfOptions) < 10 {
                
                popoverViewController.preferredContentSize.height = CGFloat((groupiesGroups.count + numberOfOptions) * 44)
                
            } else { // ... else make it scroll
                
                popoverViewController.preferredContentSize.height = CGFloat(9.5 * 44)
            }
        }
    }
    func saveText(selectedUser: AnyObject) {
        
        addFriends(selectedUser["userObject"]!!["username"] as? String)
        
        println(isGroupieName)
        //textView.text = ", ".join(isGroupieName)
    }
//    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
//        
//        // return from tap off popover
//        println("RETURNED!!")
//    }
    func didReceiveSettingsSavedNotification(notification: NSNotification) {
        
        //viewDidLoad()
    }
    // POPOVER SETTINGS FUNCTIONS
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


