//
//  NEWAskViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/11/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class NEWAskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var question = String()
    var option1 = String()
    var option2 = String()
    
    var qCell: Int = 0
    var o1Cell: Int = 0
    //var o2Cell: Int = 0
    
    var filled = ["Q": 0, "O1": 0, "O2": 0]//Dictionary<String, Int>()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var groupiesButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.filled["Q"]  = -1
            self.filled["O1"] = -1
            self.filled["O2"] = -1
            
            //dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.askTable.reloadData()
            
            //}
        }
    }
    
    @IBAction func groupiesButtonAction(sender: AnyObject) {        
    }
    
    @IBAction func privacyButtonAction(sender: AnyObject) {
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        println("Submitting...")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            println("Reloding table")
            self.askTable.reloadData()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                println(self.filled)
                
                if self.filled["Q"] == 1 && self.filled["O1"] == 1 && self.filled["O2"] == 1 {
                    
                    println(self.question)
                    println(self.option1)
                    println(self.option2)
                    
                    
                    
                    // SUBMIT Q AND TRANSISTION TO MYQS TAB
                    
                    
                    
                }
            }
        }
    }
    
    @IBAction func qPhotoButtonPressed(sender: AnyObject) {
        switchCell(&qCell, rowNumber: 0)
    }
    @IBAction func qCameraButtonPressed(sender: AnyObject) {
        qPhotoButtonPressed(sender)
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
        oPhotoButtonPressed(sender)
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
        askTable.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        
        // TEMP - to make options switch together // *************
        if rowNumber == 1 {
            indexPathOther = NSIndexPath(forRow: 2, inSection: 0)
            askTable.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        } else if rowNumber == 2 {
            indexPathOther = NSIndexPath(forRow: 1, inSection: 0)
            askTable.reloadRowsAtIndexPaths([indexPathOther], withRowAnimation: UITableViewRowAnimation.Middle)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = buttonBackgroundColor
        askTable.layer.cornerRadius = cornerRadius
        
        formatButton(groupiesButton)
        formatButton(privacyButton)
        formatButton(cancelButton)
        formatButton(submitButton)
    }
    
    
    func formatButton(_button: UIButton) {
        
        _button.layer.cornerRadius = cornerRadius
        _button.backgroundColor = buttonBackgroundColor
        _button.titleLabel?.textColor = buttonTextColor
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(askTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(askTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(askTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = NEWAskTableViewCell()
        
        switch indexPath.row {
        case 0:
            if qCell == 0 {
                cell = askTable.dequeueReusableCellWithIdentifier("qCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                
                println(cell.questionTextField.text)
                println(self.filled["Q"]!)
                
                if cell.questionTextField.text != "" && self.filled["Q"]! == 0 {
                    
                    println("Storing Q text")
                    filled["Q"] = 1
                    question = cell.questionTextField.text
                    
                } else {
                    
                    cell.questionTextField.text = ""
                    
                }
                
            } else {
                
                cell = askTable.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                
            }
            
        case 1:
            if o1Cell == 0 {
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.photoOutlet.tag = indexPath.row
                cell.cameraOutlet.tag = indexPath.row
                
                if cell.optionTextField.text != "" && self.filled["O1"]! == 0  {
                    
                    filled["O1"] = 1
                    option1 = cell.optionTextField.text
                    
                } else {
                    
                    cell.optionTextField.text = ""
                    
                }
                
            } else {
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.textOutlet.tag = indexPath.row
                
            }
            
            cell.option.text = "Option 1"
            
        case 2:
            if o1Cell == 0 {
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell1", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.photoOutlet.tag = indexPath.row
                cell.cameraOutlet.tag = indexPath.row
                
                if cell.optionTextField.text != ""  && self.filled["O2"]! == 0 {
                    
                    filled["O2"] = 1
                    option2 = cell.optionTextField.text
                    
                } else {
                    
                    cell.optionTextField.text = ""
                    
                }
                
            } else {
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                cell.textOutlet.tag = indexPath.row
                
            }
            
            cell.option.text = "Option 2"
            
        default: cell = askTable.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            
        }
        
        // Set separator color
        askTable.separatorColor = UIColor.clearColor()
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set cell background color
        cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.6))
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
        /*
        // MARK: - Navigation
        
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        }
        */
        
}
