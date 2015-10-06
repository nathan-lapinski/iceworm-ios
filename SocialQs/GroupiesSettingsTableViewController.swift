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
        
        print("Popover recieved: \(strSaveText)")
        
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        print(myGroups)
        
        var firstRowText: String = ""
        if myGroups.count == 0 {
            
            firstRowText = "No Groups"
            displayAlert("Create a group!", message: "Select groupies from the list below and use the \"Create Group\" button, which will appear next to the groupies list, to store.", sender: self)
            
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupiesSettingsCell", forIndexPath: indexPath) 

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        
        if indexPath.section == 0 {
            
            cell.backgroundColor = UIColor.darkGrayColor()//mainColorBlue//
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: tableFontSize)!
            cell.textLabel?.textColor = UIColor.whiteColor()
            
        } else if indexPath.section == 1 {
            
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
}
