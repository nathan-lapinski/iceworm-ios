//
//  AskViewController.swift
//  
//
//  Created by Brett Wiesman on 7/20/15.
//
//

import UIKit

class AskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let thumbnailMax = CGFloat(120)
    let photoMax = CGFloat(1200)
    
    var currentPId = ""
    
    var rowHeights: [CGFloat] = [52, 130, 76, 150]
    var qPhoto = false
    var oPhoto = false
    var imageCount = -1
    
    let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? Int
    
    let picker = UIImagePickerController()
    var chosenImage = [UIImage(named: "camera.png"), UIImage(named: "camera.png"), UIImage(named: "camera.png")]
    
    var clear = false
    
    let tableBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.3))
    
    var question = String()
    var option1 = String()
    var option2 = String()
    var whichCell = -1
    
    var qCell: Int = 0
    var o1Cell: Int = 0
    
    var filled = ["Q": 0, "O1": 0, "O2": 0]
    var isPhoto = [0: false, 1: false, 2: false]
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var askTable: UITableView!
    
    @IBAction func groupiesButtonAction(sender: AnyObject) { }
    @IBAction func privacyButtonAction(sender: AnyObject) { }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        clear = true
        //chosenImage = [UIImage(named: "camera.png"), UIImage(named: "camera.png"), UIImage(named: "camera.png")]
        askTable.reloadData()
        
        qPhoto = false
        oPhoto = false
        askTable.beginUpdates()
        askTable.endUpdates()
        
        
//        askTable.reloadInputViews()
        
//        let title = "Sorry!"
//        let message = "CLEAR currently no worky"
//        displayAlert(title, message, self)
    }
    
    @IBAction func addQPhotoAction(sender: AnyObject) {
        
        whichCell = 0
        
        qPhoto = !qPhoto
        
        askTable.beginUpdates()
        askTable.endUpdates()
        
        launchImagePickerPopover()
    }
    
    @IBAction func addOPhotoAction(sender: AnyObject) {
        
        whichCell = 1
        
        oPhoto = !oPhoto
        
        askTable.beginUpdates()
        askTable.endUpdates()
        
        launchImagePickerPopover()
    }
    
    @IBAction func qPhotoButtonPressed(sender: AnyObject) {
        
        whichCell = 0 // Keep popover from double launching
        
        launchImagePickerPopover()
    }
    
    @IBAction func o1PhotoButtonPressed(sender: AnyObject) {
        
        whichCell = 1 // Keep popover from double launching
        
        imageCount = -1 // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func o2PhotoButtonPressed(sender: AnyObject) {
        
        whichCell = 1 // Keep popover from double launching
        
        imageCount = 0 // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.askTable.reloadData()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                if (self.chosenImage[0] != UIImage(named: "camera.png") || self.question != "")
                    && (self.chosenImage[0] != UIImage(named: "camera.png") || self.option1 != "")
                    && (self.chosenImage[0] != UIImage(named: "camera.png") || self.option2 != "") {
                    
                    // Submit Q
                    self.submitQ(sender)
                    
                } else {
                    
                    let title = "Well that was dumb."
                    let message = "You need to provide a Q and two options!"
                    displayAlert(title, message, self)
                }
            }
        }
    }
    
    
    func submitQ(sender: AnyObject) -> Void {
        
        // Blur screen while Q upload is processing
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        self.view.addSubview(blurView)
        
        // Setup spinner and block application input
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // SAVE FULL RES IN BACKGROUND -------------------------------------------------------------
        var photos = PFObject(className: "PhotoFullMetalBlacket")
        
        photos.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil {
                self.currentPId = photos.objectId!
            } else {
                println("Error creating high res photos table entry!")
            }
            
            // Add entry to "Votes Table" ----------------
            var votes = PFObject(className: "Votes")
            
            votes.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    var socialQ = PFObject(className: "SocialQs")
                    
                    // Q text
                    if self.question != "" {
                        socialQ["question"] = self.question
                    }
                    
                    // Q photo
                    if self.isPhoto[0] == true {
                        
                        // Resize to THUMBNAIL and upload to SocialQs table
                        let imageQ = self.RBResizeImage(self.chosenImage[0]!, targetSize: CGSize(width: self.thumbnailMax, height: self.thumbnailMax))
                        let imageQData = UIImagePNGRepresentation(imageQ)
                        
                        var imageQFile: PFFile = PFFile(name: "questionImage.png", data: imageQData)
                        //                    imageQFile.saveInBackgroundWithBlock({ (success, error) -> Void in
                        //
                        //                        if (error == nil) {
                        //                        } else {
                        //                            println(error)
                        //                        }
                        //                    })
                        socialQ["questionPhoto"] = imageQFile
                    }
                    
                    // Options text
                    if self.option1 != ""  || self.option2 != "" {
                        socialQ["option1"] = self.option1
                        socialQ["option2"] = self.option2
                    }
                    
                    // Options photos
                    // Check if O1 is photo or text and upload
                    if self.isPhoto[1] == true {
                        
                        // Resize to THUMBNAIL and upload to SocialQs table
                        let imageO1 = self.RBResizeImage(self.chosenImage[1]!, targetSize: CGSize(width: self.thumbnailMax, height: self.thumbnailMax))
                        let imageO1Data = UIImagePNGRepresentation(imageO1)
                        
                        var imageO1File: PFFile = PFFile(name: "option1Image.png", data: imageO1Data)
                        imageO1File.saveInBackgroundWithBlock({ (success, error) -> Void in
                            
                            if (error == nil) {
                                println(error)
                            }
                        })
                        
                        socialQ["option1Photo"] = imageO1File
                    }
                    
                    // Check if O2 is photo or text and upload
                    if self.isPhoto[2] == true {
                        
                        // Resize to THUMBNAIL and upload to SocialQs table
                        let imageO2 = self.RBResizeImage(self.chosenImage[2]!, targetSize: CGSize(width: self.thumbnailMax, height: self.thumbnailMax))
                        let imageO2Data = UIImagePNGRepresentation(imageO2)
                        
                        let imageO2File = PFFile(name: "option2Image.png", data: imageO2Data)
                        
                        socialQ["option2Photo"] = imageO2File
                    }
                    
                    socialQ["stats1"] = 0
                    socialQ["stats2"] = 0
                    socialQ["privacyOptions"] = -1
                    socialQ["askerId"] = PFUser.currentUser()!.objectId!
                    socialQ["askername"] = PFUser.currentUser()!["username"]
                    socialQ["votesId"] = votes.objectId!
                    socialQ["photosId"] = self.currentPId
                    
                    socialQ.saveInBackgroundWithBlock { (success, error) -> Void in
                        
                        if error == nil {
                            
                            var currentQId = socialQ.objectId!
                            
                            // Query all "groupies" and myself (to add to myQs)
                            var usersToQuery = isGroupieQId + [uQId]
                            
                            // Add qId to "UserQs" table ------
                            var userQsQuery = PFQuery(className: "UserQs")
                            
                            if isGroupieQId.count > 0 {
                                userQsQuery.whereKey("objectId", containedIn: usersToQuery)
                            }
                            
                            // Execute query
                            userQsQuery.findObjectsInBackgroundWithBlock({ (userQsObjects, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let temp = userQsObjects {
                                        
                                        for userQsObject in temp {
                                            
                                            if userQsObject.objectId!! == uQId { // Append qId to myQs within UserQs table
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "myQsId")
                                                userQsObject.saveInBackground()
                                                
                                            } else { // Append qId to theirQs within UserQs table
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "theirQsId")
                                                userQsObject.saveInBackground()
                                            }
                                        }
                                        
                                        // SEND CHANNEL PUSH -----------------------------------------------------
                                        var pushGeneral:PFPush = PFPush()
                                        pushGeneral.setChannel("reloadTheirTable")
                                        
                                        // Create dictionary to send JSON to parse/to other devices
                                        var dataGeneral: Dictionary = ["alert":"", "badge":"0", "content-available":"0", "sound":""]
                                        
                                        pushGeneral.setData(dataGeneral)
                                        
                                        pushGeneral.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                            if error == nil { //println("General push sent!")
                                            }
                                        })
                                        
                                        // SEND SEGMENT PUSH NOTIFICATION ---------------------------------------
                                        // ****CURRENTLY SEND TO ALL IF NO ONE IS SELECTED!!****
                                        var toUsers: PFQuery = PFUser.query()!
                                        
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
                                                
                                                //println("Directed push notification sent!")
                                                //println("-----")
                                            }
                                        })
                                        // SEND DIRECTED PUSH NOTIFICATION ---------------------------------------
                                        
                                        // Unlock application interaction and halt spinner
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        self.activityIndicator.stopAnimating()
                                        
                                        // Reset all fields after submitting
                                        self.question = ""
                                        self.option1  = ""
                                        self.option2  = ""
                                        
                                        // Resign keyboard/reset cursor
                                        //self.questionTextField.resignFirstResponder()
                                        //self.option1TextField.resignFirstResponder()
                                        //self.option2TextField.resignFirstResponder()
                                        
                                        // Switch to results tab when question is submitted
                                        // - Had to make storyboard ID for the tabBarController = "tabBarController"
                                        self.tabBarController?.selectedIndex = 1
                                        
                                        //
                                        //
                                        // clear text and photo entries
                                        self.cancelButtonAction(sender)
                                        
                                        
                                        // Un-blur ASK tab
                                        blurView.removeFromSuperview()
                                        
                                        // Upload full res images ---------------------------------------------
                                        var photoQuery = PFQuery(className: "PhotoFullMetalBlacket")
                                        photoQuery.whereKey("objectId", equalTo: self.currentPId)
                                        photoQuery.findObjectsInBackgroundWithBlock { (photoObjects, error) -> Void in
                                            
                                            if let temp = photoObjects {
                                                
                                                for photoObject in temp {
                                                    
                                                    // Q photo
                                                    if self.isPhoto[0] == true {
                                                        
                                                        self.isPhoto[0] = false
                                                        
                                                        // Resize to THUMBNAIL and upload to SocialQs table
                                                        let imageQFull = self.RBResizeImage(self.chosenImage[0]!, targetSize: CGSize(width: self.photoMax, height: self.photoMax))
                                                        let imageQDataFull = UIImagePNGRepresentation(imageQFull)
                                                        
                                                        var imageQFileFull = PFFile(name: "questionImage.png", data: imageQDataFull)
                                                        
                                                        photoObject.setObject(imageQFileFull, forKey: "questionPhoto")
                                                        photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                                                            
                                                            if error == nil {
                                                                println("Full Res Q Photo Uploaded!")
                                                            } else {
                                                                println("Full res Q upload failed")
                                                                println(error)
                                                            }
                                                        })
                                                    }
                                                    
                                                    // O1 photo
                                                    if self.isPhoto[1] == true {
                                                        
                                                        self.isPhoto[1] = false
                                                        
                                                        // Resize to THUMBNAIL and upload to SocialQs table
                                                        let imageO1Full = self.RBResizeImage(self.chosenImage[1]!, targetSize: CGSize(width: self.photoMax, height: self.photoMax))
                                                        let imageO1DataFull = UIImagePNGRepresentation(imageO1Full)
                                                        
                                                        var imageO1FileFull = PFFile(name: "option1Image.png", data: imageO1DataFull)
                                                        
                                                        photoObject.setObject(imageO1FileFull, forKey: "option1Photo")
                                                        photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                                                            
                                                            if error == nil {
                                                                println("Full Res O1 Photo Uploaded!")
                                                            } else {
                                                                println("Full res O1 upload failed")
                                                                println(error)
                                                            }
                                                        })
                                                    }
                                                    
                                                    // O2 photo
                                                    if self.isPhoto[2] == true {
                                                        
                                                        self.isPhoto[2] = false
                                                        
                                                        // Resize to THUMBNAIL and upload to SocialQs table
                                                        let imageO2Full = self.RBResizeImage(self.chosenImage[2]!, targetSize: CGSize(width: self.photoMax, height: self.photoMax))
                                                        let imageO2DataFull = UIImagePNGRepresentation(imageO2Full)
                                                        
                                                        var imageO2FileFull = PFFile(name: "option2Image.png", data: imageO2DataFull)
                                                        
                                                        photoObject.setObject(imageO2FileFull, forKey: "option2Photo")
                                                        photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                                                            
                                                            if error == nil {
                                                                println("Full Res O2 Photo Uploaded!")
                                                            } else {
                                                                println("Full res O2 upload failed")
                                                                println(error)
                                                            }
                                                        })
                                                    }
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        
                                        println("Error updating UserQs Table")
                                        println(error)
                                    }
                                }
                            })
                            
                        } else {
                            
                            println("Write to SocialQs Table error:")
                            println(error)
                        }
                    }
                }
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = tableBackgroundColor
        askTable.layer.cornerRadius = cornerRadius
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        tapGesture.cancelsTouchesInView = true
        askTable.addGestureRecognizer(tapGesture)
        
        self.askTable.backgroundColor = UIColor.clearColor()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        returningFromPopover = false
        returningFromSettings = false
    }
    
    
    func formatButton(_button: UIButton) {
        
        _button.layer.cornerRadius = cornerRadius
        _button.backgroundColor = buttonBackgroundColor
        _button.titleLabel?.textColor = buttonTextColor
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(askTable: UITableView) -> Int { return 1 }
    
    func tableView(askTable: UITableView, numberOfRowsInSection section: Int) -> Int { return 3 }
    
    func tableView(askTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = AskTableViewCell()
        
        switch indexPath.row {
        case 0://QUESTION
            
            cell = askTable.dequeueReusableCellWithIdentifier("qCell", forIndexPath: indexPath) as! AskTableViewCell
            
            cell.questionImageView.contentMode = .ScaleAspectFit
            cell.addQPhoto.setTitle("", forState: UIControlState.Normal)
            cell.questionImageView.backgroundColor = UIColor.clearColor()
            
            if clear == false {
                
                // Fill question text
                if cell.questionTextField.text != "" { question = cell.questionTextField.text }
                cell.questionImageView.image = chosenImage[indexPath.row]
                
            } else {
                
                cell.questionImageView.image = UIImage(named: "camera.png")
                cell.questionTextField.text = ""
            }
            
            
            
        case 1://OPTIONS
                
            cell = askTable.dequeueReusableCellWithIdentifier("oCell", forIndexPath: indexPath) as! AskTableViewCell
            
            cell.option1ImageView.contentMode = .ScaleAspectFit
            cell.option2ImageView.contentMode = .ScaleAspectFit
            cell.addO1Photo.setTitle("", forState: UIControlState.Normal)
            cell.addO2Photo.setTitle("", forState: UIControlState.Normal)
            cell.option1ImageView.backgroundColor = UIColor.clearColor()
            cell.option2ImageView.backgroundColor = UIColor.clearColor()
            
            if clear == false {
                
                    if cell.option1TextField.text != "" || cell.option2TextField.text != "" {
                        option1 = cell.option1TextField.text
                        option2 = cell.option2TextField.text
                }
                
                cell.option1ImageView.image = chosenImage[1]
                cell.option2ImageView.image = chosenImage[2]
                
            } else {
                
                cell.option1ImageView.image = UIImage(named: "camera.png")
                cell.option2ImageView.image = UIImage(named: "camera.png")
                cell.option1TextField.text = ""
                cell.option2TextField.text = ""
            }
            
        case 2: // Buttons
            
            cell = askTable.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! AskTableViewCell
            
            // FORMAT BUTTONS
            formatButton(cell.groupies)
            formatButton(cell.privacy)
            formatButton(cell.clear)
            formatButton(cell.submit)
            
            self.clear = false
            
        default: cell = askTable.dequeueReusableCellWithIdentifier("oCell", forIndexPath: indexPath) as! AskTableViewCell
            
        }
        
        // Set separator color
        askTable.separatorColor = UIColor.clearColor()
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set cell background color
        cell.backgroundColor = tableBackgroundColor
        
        // Add gesture recognizer to cell - dismiss keyboard
        //self.askTable.addGestureRecognizer(tapGesture)
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if qPhoto {
                return rowHeights[1]
            } else {
                return rowHeights[0]
            }
        } else if indexPath.row == 1 {
            if oPhoto {
                return rowHeights[3]
            } else {
                return rowHeights[2]
            }
        } else {
            return 106
        }
    }
    
    
    func resignKeyboard() { self.askTable.endEditing(true) }
    
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    textField.resignFirstResponder() // Dismiss the keyboard
    
    // Call submit routine to cause switch to results page
    submitButtonAction(textField)
    
    return true
    }
    */
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    //MARK: Image Picker Shits
    func launchImagePickerPopover() -> Void {
        
        var titleMessage = "Please choose image source"
        if whichCell == 0 {
            titleMessage = "Please choose Q image source"
        } else {
            titleMessage = "Please choose Option \(((imageCount + 1) % 2) + 1) image source"
        }
        
        let alert = UIAlertController(title: titleMessage, message: nil, preferredStyle:
            .ActionSheet) // Can also set to .Alert if you prefer
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Library", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false //2
            self.picker.sourceType = .PhotoLibrary //3
            self.presentViewController(self.picker, animated: true, completion: nil)//4
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) -> Void in
            
            if self.whichCell == 0 && self.chosenImage[0] == UIImage(named: "camera.png") {
                self.qPhoto = !self.qPhoto
            } else if self.whichCell == 1 && self.chosenImage[2] == UIImage(named: "camera.png") {
                self.chosenImage[1] = UIImage(named: "camera.png")
                self.chosenImage[2] = UIImage(named: "camera.png")
                self.askTable.reloadData() // Could just reload row...
                
                self.oPhoto = !self.oPhoto
                self.imageCount = -1
            }
            
//            if self.whichCell == 0 {
//                self.qPhoto = !self.qPhoto
//            } else {
//                self.chosenImage[1] = UIImage(named: "camera.png")
//                self.chosenImage[2] = UIImage(named: "camera.png")
//                self.askTable.reloadData() // Could just reload row...
//                
//                self.oPhoto = !self.oPhoto
//                self.imageCount = -1
//            }
            
            self.askTable.beginUpdates()
            self.askTable.endUpdates()
        }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if whichCell == 0 {
            
            chosenImage[0] = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            isPhoto[Int(whichCell)] = true
            
        } else if whichCell == 1 {
            
            imageCount = imageCount + 1
            
            chosenImage[(imageCount % 2) + 1] = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            isPhoto[Int(whichCell) + (imageCount % 2)] = true
            
        } else if whichCell == -1 {
            
            chosenImage[(imageCount % 2) + 1] = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            isPhoto[Int(whichCell) + (imageCount % 2)] = true
        }
        
        askTable.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if (imageCount) % 2 == 0 && chosenImage[2] == UIImage(named: "camera.png") {
            
            launchImagePickerPopover()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        if whichCell == 0 {
            qPhoto = !qPhoto
        } else {
            chosenImage[1] = UIImage(named: "camera.png")
            chosenImage[2] = UIImage(named: "camera.png")
            askTable.reloadData() // Could just reload row...
            
            oPhoto = !oPhoto
            imageCount = -1
        }
        
        self.askTable.beginUpdates()
        self.askTable.endUpdates()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func showPhotoPicker(source: UIImagePickerControllerSourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
