//
//  GroupiesSettingsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 8/7/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class GroupiesSettingsTableViewController: UITableViewController {
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    
    var objectsArray = [Objects]()
    let tableFontSize = CGFloat(14)
    var friendEntry: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        var t1: Dictionary = ["name": "Co-Workers"]
        var t2: Dictionary = ["name": "Roommates"]
        var t3: Dictionary = ["name": "Sluts I Nailed"]
        var t4: Dictionary = ["name": "Nate's Ex-Boyfriends"]
        groupiesGroups.removeAll(keepCapacity: true)
        groupiesGroups.append(t1)
        groupiesGroups.append(t3)
        groupiesGroups.append(t4)
        groupiesGroups.append(t2)
        groupiesGroups.append(t1)
        groupiesGroups.append(t4)
        groupiesGroups.append(t1)
        groupiesGroups.append(t2)
        groupiesGroups.append(t3)
        groupiesGroups.append(t4)
        groupiesGroups.append(t1)
        groupiesGroups.append(t2)
        
        // BUILD STRING FOR DISPLAY - TEMPORARY!!!
        var groupNames = [String]()
        for temp in groupiesGroups {
            
            groupNames.append(temp["name"] as! String)
        }
        
        // Fill object to populate table
        self.objectsArray = [Objects(sectionName: "", sectionObjects: ["+ Find User"]), Objects(sectionName: "", sectionObjects: ["+ Create Group"]), Objects(sectionName: "", sectionObjects: groupNames)]
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
            
            cell.backgroundColor = UIColor.darkGrayColor()//mainColorBlue//
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: tableFontSize)!
            cell.textLabel?.textColor = UIColor.whiteColor()
            
        } else if indexPath.section == 2 {
            
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            cell.textLabel?.textColor = UIColor.darkTextColor()
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            func configurationTextField(textField: UITextField!) {
                
                textField.placeholder = ""
                friendEntry = textField
            }
            
            func handleCancel(alertView: UIAlertAction!) {
                
                println("Cancelled !!")
            }
            
            var alert = UIAlertController(title: "Enter a SocialQs handle", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
            
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
                
                //self.addUser(self.friendEntry.text)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: {
                
                println("completion block")
            })
        }
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
