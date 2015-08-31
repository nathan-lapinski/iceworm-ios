//
//  GroupiesSettingsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 8/7/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

// This protocol allows data to be passed back in forth between this 
// and the groupies main view controller - must call this protocol
// when declaring the class for the groupies main view controller
protocol GroupiesSettingsTableViewControllerDelegate {
    
    func saveText(var selectedGroup: AnyObject)
}

class GroupiesSettingsTableViewController: UITableViewController {
    
    var delegate: GroupiesSettingsTableViewControllerDelegate?
    var strSaveText : NSString!
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    var objectsArray = [Objects]()
    let tableFontSize = CGFloat(14)
    var friendEntry: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Popover recieved: \(strSaveText)")
        
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        println(myGroups)
        
        var firstRowText: String = ""
        if myGroups.count == 0 {
            
            firstRowText = "No Groups"
            displayAlert("Create a group!", "Select groupies from the list below, or use the + tool to add a user by SocialQs username to view and user the \"Create Group\" button.", self)
            
        } else {
            
            firstRowText = "Select Group"
        }
        
        // Fill object to populate table
        self.objectsArray = [Objects(sectionName: "", sectionObjects: [firstRowText]), Objects(sectionName: "", sectionObjects: myGroups)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectsArray.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsArray[section].sectionObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupiesSettingsCell", forIndexPath: indexPath) as! GroupiesSettingsCell

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        
        if indexPath.section == 0 {
            
            cell.backgroundColor = UIColor.darkGrayColor()//mainColorBlue//
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: tableFontSize)!
            cell.textLabel?.textColor = UIColor.whiteColor()
            
        } else if indexPath.section == 1 {
            
//            cell.backgroundColor = UIColor.darkGrayColor()//mainColorBlue//
//            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: tableFontSize)!
//            cell.textLabel?.textColor = UIColor.whiteColor()
//            
//        } else if indexPath.section == 2 {
            
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            cell.textLabel?.textColor = UIColor.darkTextColor()
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            
            // Check to make sure the delegate is set then call the returning function (saveText) - which
            // lives in the calling/controlling VC
            if self.delegate != nil {
                
                // Return PFUser
                self.delegate?.saveText(myGroups[indexPath.row])
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
//    func addUserAlert() {
//        
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
//        alert.addAction(UIAlertAction(title: "Add User", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
//            
//            self.resignFirstResponder()
//            
//            let searchString = self.friendEntry.text
//            
//            PFCloud.callFunctionInBackground("findNewUser", withParameters: ["userString": searchString, "currentUser": username]) { (objects, error) -> Void in
//                
//                if error == nil {
//                    
//                    if objects!.count == 0 {
//                        
//                        displayAlert("Sorry!", "No users containing \(searchString) were found. Please verify spelling and try again!", self)
//                        
//                    } else if objects!.count == 1 {
//                        
//                        // ONE USER FOUND, add it
//                        myFriends.append(searchString)
//                        isGroupieName.append(searchString)
//                        
//                        // Post notification to tell calling controller that the popover is being dismissed
//                        // (or simply that the underlying should be reloaded)
//                        NSNotificationCenter.defaultCenter().postNotificationName("SettingsSavedNotification", object: nil)
//                        
//                        // Check to make sure the delegate is set then call the returning function (saveText) - which
//                        // lives in the calling/controlling VC
//                        if self.delegate != nil {
//                            
//                            // Return PFUser
//                            self.delegate?.saveText(objects![0])
//                        }
//
//                        self.dismissViewControllerAnimated(true, completion: nil)
//                        
//                    } else {
//                        
//                        self.selectUserFromOptionsAlert(objects!)
//                    }
//                    
//                } else {
//                    
//                    println("Error filtering usernames in cloud")
//                    println(error)
//                }
//            }
//            
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: {
//            
//            println("completion block")
//        })
//    }
    
    
//    func selectUserFromOptionsAlert(objects: AnyObject) {
//        
//        func handleCancel(alertView: UIAlertAction!) {
//            
//            println("Cancelled !!")
//        }
//        
//        var alert = UIAlertController(title: "Did you mean:", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        var displayString: String = ""
//        
//        let finalCount = min(objects.count, 5)
//        
//        for var i = 0; i < finalCount; i++ {
//        //for var i = 0; i < 5; i++ {
//            
//            let userObject: AnyObject! = objects[i]
//            
//            let usernameLocal = objects[i]["userObject"]!!["username"]! as! String
//            
//            if let nameLocal = objects[i]["userObject"]!!["name"]! as? String {
//                
//                displayString = "@\(usernameLocal) (\(nameLocal))"
//                
//            } else {
//                
//                displayString = "@\(usernameLocal)"
//            }
//            
//            alert.addAction(UIAlertAction(title: displayString, style: .Default, handler: { (UIAlertAction) in
//                
//                println("\(displayString) selected")
//                
//                myFriends.append(usernameLocal)
//                isGroupieName.append(usernameLocal)
//                
//                println(myFriends)
//                
//                // Post notification to tell calling controller that the popover is being dismissed
//                // (or simply that the underlying should be reloaded)
//                NSNotificationCenter.defaultCenter().postNotificationName("SettingsSavedNotification", object: nil)
//                
//                if self.delegate != nil {
//                    
//                    // Return PFUser
//                    self.delegate?.saveText(userObject)
//                }
////                
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }))
//        }
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
//        
//        self.presentViewController(alert, animated: true, completion: { })
//    
//    }
    
    
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
