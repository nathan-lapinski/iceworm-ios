//
//  NEWAskViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/11/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class NEWAskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    var chosenImage = [UIImage(named: "camera.png"), UIImage(named: "camera.png"), UIImage(named: "camera.png")]
    //var chosenO2Image = UIImage(named: "camera.png")
    
    let tableBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.3))
    
    var hide = [false, false, false]
    
    var question = String()
    var option1 = String()
    var option2 = String()
    var whichCell: AnyObject = -1
    
    var qCell: Int = 0
    var o1Cell: Int = 0
    //var o2Cell: Int = 0
    
    var filled = ["Q": 0, "O1": 0, "O2": 0]//Dictionary<String, Int>()
    var isPhoto = [0: false, 1: false, 2: false]
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var groupiesButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    @IBAction func addQPhotoAction(sender: AnyObject) {
        
        whichCell = sender.tag
        println(whichCell)
        
        picker.allowsEditing = false //2
        picker.sourceType = .PhotoLibrary //3
        presentViewController(picker, animated: true, completion: nil)//4
        
    }
    
    @IBAction func addOPhotoAction(sender: AnyObject) {
        
        whichCell = sender.tag
        println(whichCell)
        
        picker.allowsEditing = false //2
        picker.sourceType = .PhotoLibrary //3
        presentViewController(picker, animated: true, completion: nil)//4
        
    }
    
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.filled["Q"]  = -1
            self.filled["O1"] = -1
            self.filled["O2"] = -1
            self.isPhoto[0]  = false
            self.isPhoto[1] = false
            self.isPhoto[2] = false
            
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
        
        println("Submit button pressed")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            println("Reloding table")
            self.askTable.reloadData()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                println(self.filled)
                
                //if self.filled["Q"] == 1 && self.filled["O1"] == 1 && self.filled["O2"] == 1 {
                    
                    println(self.question)
                    println(self.option1)
                    println(self.option2)
                    
                    
                    //
                    //
                    self.submitQ()
                    //
                    //
                    
                    
                //}
            }
        }
    }
    
    func submitQ() -> Void {
        
        println("Submitting Q")
        
        if question == "" {// || option1 == "" || option2 == "" {
            
            let title = "Well that was silly!"
            let message = "You need to provide a Q and two options!"
            displayAlert(title, message: message)
            
        } else {
            
            println("User is attempting to send a Q to:")
            println(isGroupieName)
            println("With qIds:")
            println(isGroupieQId)
            
            // Setup spinner and block application input
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // PARSE -------------------------------------------------------------
            // Add entry to "Votes Table" ----------------
            var votes = PFObject(className: "Votes")
            
            votes.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    var socialQ = PFObject(className: "SocialQs")
                    
                    // Check if Q is photo or not and upload
                    if self.isPhoto[0] == true {
                        
                        var imageData = UIImagePNGRepresentation(self.chosenImage[0])
                        let imageFile = PFFile(name: "image.png", data: imageData)
                        
                        socialQ["questionPhoto"] = imageFile
                        
                    } else {
                    
                        socialQ["question"] = self.question
                    }
                    
                    // Check if O1 is photo or not and upload
                    if self.isPhoto[1] == true {
                        
                        var imageData = UIImagePNGRepresentation(self.chosenImage[1])
                        let imageFile = PFFile(name: "image.png", data: imageData)
                        
                        socialQ["option1Photo"] = imageFile
                        
                    } else {
                        
                        socialQ["option1"] = self.option1
                    }
                    
                    // Check if O2 is photo or not and upload
                    if self.isPhoto[2] == true {
                        
                        var imageData = UIImagePNGRepresentation(self.chosenImage[2])
                        let imageFile = PFFile(name: "image.png", data: imageData)
                        
                        socialQ["option2Photo"] = imageFile
                        
                    } else {
                        
                        socialQ["option2"] = self.option2
                    }
                    
                    socialQ["stats1"] = 0
                    socialQ["stats2"] = 0
                    socialQ["privacyOptions"] = -1
                    socialQ["askerId"] = PFUser.currentUser()!.objectId!
                    socialQ["askername"] = PFUser.currentUser()!["username"]
                    socialQ["votesId"] = votes.objectId!
                    
                    socialQ.saveInBackgroundWithBlock { (success, error) -> Void in
                        
                        var currentQId = socialQ.objectId!
                        
                        if error == nil {
                            
                            // Query all "groupies" and myself (to add to myQs)
                            var usersToQuery = isGroupieQId + [uQId]
                            
                            // Add qId to "UserQs" table ------
                            var userQsQuery = PFQuery(className: "UserQs")
                            
                            println("userToQuery appended:")
                            println(usersToQuery)
                            
                            if isGroupieQId.count > 0 {
                                userQsQuery.whereKey("objectId", containedIn: usersToQuery)
                            }
                            
                            // Execute query
                            userQsQuery.findObjectsInBackgroundWithBlock({ (userQsObjects, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let temp = userQsObjects {
                                        
                                        println("App is sending Q to uQIds:")
                                        for userQsObject in temp {
                                            
                                            if userQsObject.objectId!! == uQId { // Append qId to myQs within UserQs table
                                                
                                                println("Saving to \(userQsObject.objectId!!) myQsId")
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "myQsId")
                                                userQsObject.saveInBackground()
                                                
                                            } else { // Append qId to theirQs within UserQs table
                                                
                                                println("Saving to \(userQsObject.objectId!!) theirQsId")
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "theirQsId")
                                                userQsObject.saveInBackground()
                                            }
                                        }
                                        
                                    } else {
                                        
                                        println("Error updating UserQs Table")
                                        println(error)
                                    }
                                    
                                    // SEND CHANNEL PUSH -----------------------------------------------------
                                    var pushGeneral:PFPush = PFPush()
                                    pushGeneral.setChannel("reloadTheirTable")
                                    
                                    // Create dictionary to send JSON to parse/to other devices
                                    var dataGeneral: Dictionary = ["alert":"", "badge":"0", "content-available":"0", "sound":""]
                                    
                                    pushGeneral.setData(dataGeneral)
                                    
                                    pushGeneral.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                        if error == nil { println("General push sent!") }
                                    })
                                    
                                    // SEND SEGMENT PUSH NOTIFICATION ---------------------------------------
                                    // ****CURRENTLY SEND TO ALL IF NO ONE IS SELECTED!!****
                                    var toUsers: PFQuery = PFUser.query()!
                                    
                                    println("********************")
                                    println(toUsers)
                                    println("********************")
                                    
                                    var pushQuery: PFQuery = PFInstallation.query()!
                                    
                                    if isGroupieName.isEmpty == false {
                                        
                                        toUsers.whereKey("username", containedIn: isGroupieName)
                                        pushQuery.whereKey("user", matchesQuery: toUsers)
                                        
                                    } else { // If sendToGroupies is empty, filter push to all users
                                        pushQuery.whereKey("user", notContainedIn: isGroupieName)
                                        pushQuery.whereKey("username", doesNotMatchQuery: toUsers)
                                    }
                                    
                                    var pushDirected: PFPush = PFPush()
                                    pushDirected.setQuery(pushQuery)
                                    
                                    // Create dictionary to send JSON to parse/to other devices
                                    //var dataDirected: Dictionary = ["alert":"New Q from \(myName)!", "badge":"Increment", "content-available":"0", "sound":""]////
                                    //pushDirected.setData(dataDirected)////
                                    pushDirected.setMessage("New Q from \(myName)!")
                                    
                                    // Send Push Notifications
                                    pushDirected.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                        
                                        if error == nil {
                                            
                                            isGroupieName.removeAll(keepCapacity: true)
                                            isGroupieQId.removeAll(keepCapacity: true)
                                            
                                            println("Directed push notification sent!")
                                            println("-----")
                                        }
                                    })
                                    // SEND DIRECTED PUSH NOTIFICATION ---------------------------------------
                                    
                                    // Unlock application interaction and halt spinner
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    self.activityIndicator.stopAnimating()
                                    
                                    // Reset all fields after submitting
                                    self.question = ""
                                    self.option1 = ""
                                    self.option2 = ""
                                    
                                    // Resign keyboard/reset cursor
                                    //self.questionTextField.resignFirstResponder()
                                    //self.option1TextField.resignFirstResponder()
                                    //self.option2TextField.resignFirstResponder()
                                    
                                    // Switch to results tab when question is submitted
                                    // - Had to make storyboard ID for the tabBarController = "tabBarController"
                                    self.tabBarController?.selectedIndex = 1
                                }
                            })
                            
                        } else {
                            
                            println("Write to SocialQs Table error:")
                            println(error)
                        }
                    }
                }
            })
            // PARSE -------------------------------------------------------------
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
        
        picker.delegate = self
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = tableBackgroundColor
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
        
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        
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
                
            } else { // PHOTO VERSION
                
                cell = askTable.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                
                cell.addQPhoto.tag = indexPath.row
                
                cell.questionImageView.contentMode = .ScaleAspectFit //3
                cell.questionImageView.image = chosenImage[indexPath.row] //4
                
                if hide[indexPath.row] == true {
                    
                    cell.addQPhoto.setTitle("", forState: UIControlState.Normal)
                    cell.questionImageView.backgroundColor = UIColor.clearColor()
                }
                
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
                
            } else { // PHOTO VERSION
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                
                cell.textOutlet.tag = indexPath.row
                cell.addPhotoOutlet.tag = indexPath.row
                
                cell.optionImageView.contentMode = .ScaleAspectFit //3
                cell.optionImageView.image = chosenImage[indexPath.row] //4
                
                if hide[indexPath.row] == true {
                    
                    cell.addPhotoOutlet.setTitle("", forState: UIControlState.Normal)
                    cell.optionImageView.backgroundColor = UIColor.clearColor()
                }
                
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
                
            } else { // PHOTO VERSION
                
                cell = askTable.dequeueReusableCellWithIdentifier("oCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
                
                cell.textOutlet.tag = indexPath.row
                cell.addPhotoOutlet.tag = indexPath.row
                
                cell.optionImageView.contentMode = .ScaleAspectFit //3
                cell.optionImageView.image = chosenImage[indexPath.row] //4
                
                if hide[indexPath.row] == true {
                    
                    cell.addPhotoOutlet.setTitle("", forState: UIControlState.Normal)
                    cell.optionImageView.backgroundColor = UIColor.clearColor()
                }
                
            }
            
            cell.option.text = "Option 2"
            
        default: cell = askTable.dequeueReusableCellWithIdentifier("qCell2", forIndexPath: indexPath) as! NEWAskTableViewCell
            
        }
        
        // Set separator color
        askTable.separatorColor = UIColor.clearColor()
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set cell background color
        cell.backgroundColor = tableBackgroundColor
        
        // Add gesture recognizer to cell - dismiss keyboard
        self.askTable.addGestureRecognizer(gestureRecognizer)
        
        return cell
    }
    
    func resignKeyboard() {
        
        self.askTable.endEditing(true)
    
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // Dismiss the keyboard
        
        // Call submit routine to cause switch to results page
        submitButtonAction(textField)
        
        return true
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    
    //MARK: Image Picker Shits
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        chosenImage[Int(whichCell as! NSNumber)] = info[UIImagePickerControllerOriginalImage] as? UIImage //2
        
        hide[Int(whichCell as! NSNumber)] = true
        isPhoto[Int(whichCell as! NSNumber)] = true
        
        var indexForReload = NSIndexPath(forRow: Int(whichCell as! NSNumber), inSection: 0)
        askTable.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    
    
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
