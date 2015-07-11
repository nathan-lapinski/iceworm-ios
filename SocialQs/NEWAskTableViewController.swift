//
//  NEWAskTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/7/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//
/*
import UIKit
import Parse

class NEWAskTableViewController: UITableViewController {
    
    var question = String()
    var option1 = String()
    var option2 = String()
    
    var qCell: Int = 0
    var o1Cell: Int = 0
    //var o2Cell: Int = 0
    
    var filled = Dictionary<String, Int>()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.filled["Q"]  = -1
            self.filled["O1"] = -1
            self.filled["O2"] = -1
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                self.tableView.reloadData()
                
            }
            
            // SUBMIT Q AND TRANSISTION TO MYQS TAB
        }
    }
    
    @IBAction func groupiesButtonAction(sender: AnyObject) {
        
        performSegueWithIdentifier("groupies", sender: self)
        
    }
    
    @IBAction func privacyButtonAction(sender: AnyObject) {
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
            self.tableView.reloadData()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                println(self.filled)
                
                if self.filled["Q"] == 1 && self.filled["O1"] == 1 && self.filled["O2"] == 1 {
                    
                    
                    
                }
            }
        }
    }
    
    @IBAction func qPhotoButtonPressed(sender: AnyObject) {
        switchCell(&qCell, rowNumber: 0)
    }
    
    @IBAction func qCameraButtonPressed(sender: AnyObject) {
        qPhotoButtonPressed(sender.tag)
    }
    
    @IBAction func qTextButtonPressed(sender: AnyObject) {
        switchCell(&qCell, rowNumber: 0)
    }
    
    @IBAction func oPhotoButtonPressed(sender: AnyObject) {
        //if sender.tag == 1 {
            switchCell(&o1Cell, rowNumber: sender.tag)
        //} else {
        //    switchCell(&o2Cell, rowNumber: sender.tag)
        //}
    }
    
    @IBAction func oCameraButtonPressed(sender: AnyObject) {
        //if sender.tag == 1 {
            switchCell(&o1Cell, rowNumber: sender.tag)
        //} else {
        //    switchCell(&o2Cell, rowNumber: sender.tag)
        //}
    }
    
    @IBAction func oTextButtonPressed(sender: AnyObject) {
        //if sender.tag == 1 {
            switchCell(&o1Cell, rowNumber: sender.tag)
        //} else {
        //    switchCell(&o2Cell, rowNumber: sender.tag)
        //}
    }
    
    
    func switchCell(inout cellValue: Int, rowNumber: Int) {
        
        cellValue = (cellValue + 1) % 2
        
        var indexPathOther = NSIndexPath(forRow: rowNumber, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        
        // TEMP - to make options switch together // *************
        if rowNumber == 1 {
            indexPathOther = NSIndexPath(forRow: 2, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        } else if rowNumber == 2 {
            indexPathOther = NSIndexPath(forRow: 1, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg.png"))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        return 5
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = NEWAskTableViewCell()
        
        switch indexPath.row {
        case 0:
            if qCell == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("qCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                
                if cell.questionTextField.text != "" && self.filled["Q"] == 0 {
                    
                    filled["Q"] = 1
                    question = cell.questionTextField.text
                    
                } else {
                    
                    cell.questionTextField.text = ""
                    
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            }
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
            
        case 1:
            if o1Cell == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.photoOutlet.tag = indexPath.row
                cell.cameraOutlet.tag = indexPath.row
                
                if cell.optionTextField.text != "" && self.filled["O1"] == 0  {
                    
                    filled["O1"] = 1
                    option1 = cell.optionTextField.text
                    
                } else {
                    
                    cell.optionTextField.text = ""
                    
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.textOutlet.tag = indexPath.row
            }
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
            
        case 2:
            if o1Cell == 0 { //if o2Cell == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.photoOutlet.tag = indexPath.row
                cell.cameraOutlet.tag = indexPath.row
                
                if cell.optionTextField.text != ""  && self.filled["O2"] == 0 {
                    
                    filled["O2"] = 1
                    option2 = cell.optionTextField.text
                    
                } else {//if self.filled["Q"] == -1 {
                    
                    cell.optionTextField.text = ""
                    
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.textOutlet.tag = indexPath.row
            }
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
        
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("buttonCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.0))
            
            cell.groupiesButton.layer.cornerRadius = cornerRadius
            cell.privacyButton.layer.cornerRadius = cornerRadius
            cell.cancelButton.layer.cornerRadius = cornerRadius
            cell.submitButton.layer.cornerRadius = cornerRadius
            
            cell.groupiesButton.backgroundColor = buttonBackgroundColor
            cell.privacyButton.backgroundColor = buttonBackgroundColor
            cell.cancelButton.backgroundColor = buttonBackgroundColor
            cell.submitButton.backgroundColor = buttonBackgroundColor
            
            cell.groupiesButton.titleLabel?.textColor = buttonTextColor
            cell.privacyButton.titleLabel?.textColor = buttonTextColor
            cell.cancelButton.titleLabel?.textColor = buttonTextColor
            cell.submitButton.titleLabel?.textColor = buttonTextColor
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("buttonCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.0))
            
            
            //formatButton(&cell.groupiesButton)
            //formatButton(cell.privacyButton)
            //formatButton(cell.cancelButton)
            //formatButton(cell.submitButton)
            
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
        }
        
        /*
        func formatButton(inout button: UIButton) {
        
            button.layer.cornerRadius = cornerRadius
            button.backgroundColor = buttonBackgroundColor
            button.titleLabel?.textColor = buttonTextColor
        }
        */
        
        // Set separator color
        tableView.separatorColor = UIColor.clearColor()
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
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
*/