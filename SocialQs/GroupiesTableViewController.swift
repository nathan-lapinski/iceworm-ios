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
    
    var textView = UITextView()
    
    var viewWillAppearCount = 0
    
    var direction = Int()
    var shakes = Int()
    
    let tableFontSize = CGFloat(16)
    var keyboardSize = CGFloat()
//    let section1: String = ""
//    let objs1: [String] = ["All Users"]
    let section1: String = ""//"sQs Friends"//Facebook and sQs Friends"
    var objs1: [String] = [String]()
//    let section3: String = "sQs Users"
    var searchCancelled = false
    
    var friendEntry: UITextField!
    
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
        
        var groupEntry: UITextField!
        
        buildGroupiesDictionary()
        
        func configurationTextField(textField: UITextField!) {
            
            textField.placeholder = ""
            groupEntry = textField
        }
        
        func handleCancel(alertView: UIAlertAction!) {
            
            print("Cancelled !!")
        }
        
        let alert = UIAlertController(title: "Enter group name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        
        alert.addAction(UIAlertAction(title: "Create Group", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            
            self.resignFirstResponder()
            
            // First, check that a name is entered and it doesn't conflict with pre-existing groups
            if groupEntry.text == "" {
                
                // MUST ENTER A NAME!!!
                //
                //
                
            } else if myGroups.contains(groupEntry.text!) {
                
                // GROUP NAME ALREADY EXISTS! 
                //
                // OVERWRITE??
                
            } else {
                
                let groupName = groupEntry.text
                
                // Add group name to array of group names in the phone and on Parse
                myGroups.append(groupName!)
                PFUser.currentUser()!.addUniqueObject(groupName!, forKey: "myGroups")
                PFUser.currentUser()!.saveEventually({ (success, error) -> Void in
                    
                    if error == nil {
                        
                        print("Group added to user's account")
                    
                    } else {
                        
                        print("There was an error adding group to users account: \n\(error)")
                    }
                })
                
                // Create entry in GroupJoin table
                var groupObjects: [PFObject] = []
                for groupie in groupiesDictionary {
                    
                    var group = PFObject(className: "GroupJoin")
                    group.setObject(groupName!, forKey: "groupName")
                    group.setObject(PFUser.currentUser()!, forKey: "owner")
                    group.setObject(groupie["name"]!, forKey: "name")
                    //group.setObject(groupie["type"]!, forKey: "type")
                    group.setObject(groupie["id"]!, forKey: "facebookId")
                    //if let url = groupie["picURL"] as? String { group.setObject(url, forKey: "picURL") }
                    
                    // Pin new GroupJoin object to LDS
                    group.pinInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if error == nil {
                            print("New GroupJoin pinned")
                        } else {
                            print("There was an error pinning GroupJoin \n\(error)")
                        }
                    })
                    
                    groupObjects.append(group)
                }
                
                // ***************************************************
                // ***************************************************
                // **** NEEDS NETWORK CHECK + RETRY FUNCTIONALITY ****
                // ***************************************************
                // ***************************************************
                PFObject.saveAllInBackground(groupObjects, block: { (success, error) -> Void in
                    
                    if error == nil {
                        
                        print("GroupJoin entries created")
                        
                    } else {
                        
                        print("There was an error creating GroupJoin entries: \n\(error)")
                    }
                })
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            
            print("completion block")
        })
        
    }
    
    
    func buildGroupiesDictionary() {
        
        // Trim friendsDictionary to selectedFriendsDictionary2 before switching back
        isGroupieName.removeAll(keepCapacity: true)
        groupiesDictionary.removeAll(keepCapacity: true)
        
        for temp in friendsDictionaryFiltered {
            if temp["isSelected"] as! Bool == true {
                groupiesDictionary.append(temp)
                isGroupieName.append(temp["name"] as! String)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()// Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveSettingsSavedNotification:", name: "SettingsSavedNotification", object: nil)
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.showsCancelButton = true
        
        // Load all users (no filter from searchbar
        self.loadUsers("")
        
        if let addNavigationButton = self.navigationItem.rightBarButtonItem {
            addNavigationButton.tintColor = UIColor.whiteColor()
        }
        
        // Format Done button
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue", size: tableFontSize)!], forState: UIControlState.Normal)
        
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg3.png"))
        self.tableView.backgroundView?.alpha = 0.4
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Keyboard open/closed notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
        
        
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
        
        downloadFacebookFriends { (success) -> Void in
            print(friendsDictionary)
        }
        
        //topOffset = 64
        
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
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
    }
    
    
    func loadUsers(searchName: String) {
        
        //:::::::::::::::::::::::::::::::::::::::::::
        // Sort dictionaries
        friendsDictionary.sortInPlace { (item1, item2) -> Bool in
            
            let t1 = (item1["name"] as! String).lowercaseString
            let t2 = (item2["name"] as! String).lowercaseString
            
            return t1 < t2
        }
        
        // Fill display strings
        fbAndSQNames.removeAll(keepCapacity: true)
        for temp in friendsDictionary {
            
            self.fbAndSQNames.append(temp["name"] as! String)
        }
        
        // reset all entries in filtered users
        friendsDictionaryFiltered.removeAll(keepCapacity: true)
        
        var sectionOneItems = [String]()
        
        // Fill filtered dictionaries from full dict and search key
        if !searchName.isEmpty {
            
            // Filter users by searchBar input
            let fbAndSQNamesFiltered = self.fbAndSQNames.filter({(item: String) -> Bool in
                
                let stringMatch = item.lowercaseString.rangeOfString(searchName.lowercaseString)
                return stringMatch != nil ? true : false
            })
            
            // Fill filtered dictionaries
            for name in fbAndSQNamesFiltered {
                let index = self.fbAndSQNames.indexOf(name)!
                friendsDictionaryFiltered.append(friendsDictionary[index])
            }
            
            sectionOneItems = fbAndSQNamesFiltered
            
        } else {
            
            friendsDictionaryFiltered = friendsDictionary
            
            sectionOneItems = self.fbAndSQNames
        }
        
        // Fill object to populate table
        self.objectsArray = [
            Objects(sectionName: self.section1, sectionObjects: sectionOneItems)
        ]
        
        self.tableView.reloadData()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        loadUsers(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
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
        
        print("\(indexPath.row): \(friendsDictionaryFiltered[indexPath.row])")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupiesCell", forIndexPath: indexPath) as! GroupiesCell
        
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
        
        cell.profilePictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.profilePictureImageView.clipsToBounds = true
        
        if friendsDictionaryFiltered[indexPath.row]["isSelected"] as! Bool == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        cell.resignFirstResponder()
        
        friendsDictionaryFiltered[indexPath.row]["isSelected"] = !(friendsDictionaryFiltered[indexPath.row]["isSelected"] as! Bool)
        
        for var i = 0; i < friendsDictionary.count; i++ {
            
            if friendsDictionary[i]["picURL"] as! String == friendsDictionaryFiltered[indexPath.row]["picURL"] as! String {
                friendsDictionary[i]["isSelected"] = !(friendsDictionary[i]["isSelected"] as! Bool)
            }
        }
        
        if (friendsDictionary[indexPath.row]["isSelected"] as! Bool) == true {
            
            if !isGroupieName.contains((friendsDictionary[indexPath.row]["name"] as! String)) {
                
                isGroupieName.append(friendsDictionary[indexPath.row]["name"] as! String)
            }
            
        } else {
            
            let index = isGroupieName.indexOf((friendsDictionary[indexPath.row]["name"] as! String))
            if index != nil {
                
                isGroupieName.removeAtIndex(index!)
            }
        }
        
//        //var count = 0
//        for var i = 0; i < friendsDictionary.count; i++ {
//            
//            if friendsDictionary[i]["isSelected"] as! Bool == true {
//                //count++
//            }
//        }
//        
//        
//        
//        
        // Collapse header if no groupies selectionized
        tableView.beginUpdates()
        if isGroupieName.count < 2 {
            
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
//
        // Fill in selected users - must be after section header refreshing (above)
        textView.text = isGroupieName.joinWithSeparator(", ")
        
        if isGroupieName.count > 0 {
            let text = textView.text
            let textRange = text.startIndex..<text.endIndex
            let attributedString = NSMutableAttributedString(string: text)
            var range: NSRange? = nil
            
            text.enumerateSubstringsInRange(textRange, options: NSStringEnumerationOptions.ByWords, { (substring, substringRange, enclosingRange, stop) -> () in
                let start = text.startIndex.distanceTo(substringRange.startIndex)
                let length = substringRange.startIndex.distanceTo(substringRange.endIndex)
                range = NSMakeRange(start, length)
            })
            textView.scrollRangeToVisible(range!)
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        if indexPath.section == 0 {
////            if isGroupieName.count < 1 {
////                return 0 // no users in isSelected display string
////            } else {
////                return 44 // users present in isSelected display string
////            }
//            return 0
//        } else {
            return 44
//        }
    }
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor() // UIColor.whiteColor()
            
            textView = UITextView(frame: CGRectMake(0, -5, self.view.frame.size.width - 70, 68))
            textView.editable = false
            textView.text = isGroupieName.joinWithSeparator(", ")
            textView.backgroundColor = UIColor.clearColor() // mainColorBlue
            textView.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(12))!
            textView.textAlignment = NSTextAlignment.Left
            textView.textColor = UIColor.darkTextColor()
            
            let clearButton = UIButton(frame: CGRectMake(self.tableView.frame.size.width - 28, 22, 20, 20))
            clearButton.setImage(UIImage(named: "clear.png"), forState: UIControlState.Normal)
            clearButton.addTarget(self, action: "clearSelectedGroupies", forControlEvents: .TouchUpInside)
            
            let groupButton = UIButton(frame: CGRectMake(self.tableView.frame.size.width - 78, 18, 42, 32))
//            groupButton.layer.borderWidth = 1
//            groupButton.layer.borderColor = mainColorBlue.CGColor
//            groupButton.layer.cornerRadius = 4
//            groupButton.setTitle("+Group", forState: UIControlState.Normal)
//            groupButton.setTitleColor(mainColorBlue, forState: UIControlState.Normal)
//            groupButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: CGFloat(12))!
            groupButton.setImage(UIImage(named: "createGroup.png"), forState: UIControlState.Normal)
            groupButton.addTarget(self, action: "createGroup", forControlEvents: .TouchUpInside)
            
            // Add the shits to the view
            header.addSubview(textView)
            header.addSubview(clearButton)
            header.addSubview(groupButton)
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
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
            if (myGroups.count + numberOfOptions) < 10 {
                
                popoverViewController.preferredContentSize.height = CGFloat((myGroups.count + numberOfOptions) * 44)
                
            } else { // ... else make it scroll
                
                popoverViewController.preferredContentSize.height = CGFloat(9.5 * 44)
            }
        }
    }
    // Function which returns data from the Group popover:
    func saveText(selectedGroup: AnyObject) {
        
        let groupQuery = PFQuery(className: "GroupJoin")
        groupQuery.whereKey("owner", equalTo: PFUser.currentUser()!)
        groupQuery.whereKey("groupName", equalTo: selectedGroup as! String)
        groupQuery.fromLocalDatastore()
        
        groupQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                var tempGroupNames: [String] = []
                
                if let temp = objects {
                    
                    // Add usernames to isGroupieName array
                    for object in temp {
                        
                        isGroupieName.append(object["name"] as! String)
                        
                        tempGroupNames.append(object["name"] as! String)
                    }
                    
                    // Change isSelected status on appropriate friends
                    for var i = 0; i < friendsDictionary.count; i++ {
                        
                        if tempGroupNames.contains((friendsDictionary[i]["name"] as! String)) {
                            
                            friendsDictionary[i]["isSelected"] = true
                        }
                    }
                    
                    // Refresh to get selectedUsers list
                    self.loadUsers("")
                    //self.tableView.reloadData()
                }
                
            } else {
                
                print("There was an error loading the selected group: \n\(error)")
            }
            
        }
        
        //addFriends(selectedUser["userObject"]!!["username"] as? String, completion: { (isFinished) -> () in })
        //println(isGroupieName)
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


