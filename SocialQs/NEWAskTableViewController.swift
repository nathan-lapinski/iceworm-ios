//
//  NEWAskTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/7/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class NEWAskTableViewController: UITableViewController {

    var qCell: Int = 0
    var o1Cell: Int = 0
    //var o2Cell: Int = 0
    
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
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            }
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
        case 1:
            if o1Cell == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.photoOutlet.tag = indexPath.row
                cell.cameraOutlet.tag = indexPath.row
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
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.textOutlet.tag = indexPath.row
            }
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("buttonCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.0))
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("buttonCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.0))
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
        }
        
        
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
