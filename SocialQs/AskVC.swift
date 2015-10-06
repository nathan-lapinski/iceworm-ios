//
//  AskVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 10/3/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class AskVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    let thumbnailMax = CGFloat(120)
    let photoMax = CGFloat(800)
    let rowHeights: [CGFloat] = [52, 100, 76, 120]
    
    var startingFrame: CGRect = CGRect()
    
    var clear = false
    var qPhoto = false
    var oPhoto = false
    var imageCount = 0
    
    var chosenImageHighRes: [UIImage?] = [nil, nil, nil]
    var chosenImageThumbnail: [UIImage?] = [nil, nil, nil]
    
    let tableBackgroundColor = UIColor.clearColor() //UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.3))
    
    var question: String? = nil
    var option1: String? = nil
    var option2: String? = nil
    
    var whichCell = -1
    
    let picker = UIImagePickerController()
    
    var socialQsGroupies = [String]()
    var facebookWithAppGroupies = [String]()
    var facebookWithoutAppGroupies = [String]()
    
    var askBoxView = UIView()
    var askBlurView = globalBlurView()
    
    @IBOutlet var askTable: UITableView!
    
    @IBAction func handleDismissedPressed(sender: AnyObject) {
        
        let endCenter = presentingViewController!.view.center
        var containerFrame = presentingViewController!.view.frame
        
        UIView.animateWithDuration(0.8,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [],
            animations: {
                
                self.view.center.x = endCenter.x - self.view.frame.width
                self.view.center.y = endCenter.y
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                
            }, completion: {
                _ in
        })
        
    }
    
    
    @IBAction func groupiesButtonAction(sender: AnyObject) { }
    @IBAction func privacyButtonAction(sender: AnyObject) { }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        clear = true
        
        isGroupieName = []
        for var i=0; i < friendsDictionaryFiltered.count; i++ {
            friendsDictionaryFiltered[i]["isSelected"] = false
        }
        for var i=0; i < friendsDictionary.count; i++ {
            friendsDictionary[i]["isSelected"] = false
        }
        
        question = nil
        option1  = nil
        option2  = nil
        
        askTable.reloadData()
        
        chosenImageHighRes = [nil, nil, nil]
        chosenImageThumbnail = [nil, nil, nil]
        
        qPhoto = false
        oPhoto = false
        askTable.beginUpdates()
        askTable.reloadData()
        askTable.endUpdates()
        
        popDirection = "right"
        let overlayVC = storyboard!.instantiateViewControllerWithIdentifier("groupiesVC")
        prepareOverlayVC(overlayVC)
        presentViewController(overlayVC, animated: true, completion: nil)
        
    }
    
    
    private func prepareOverlayVC(overlayVC: UIViewController) {
        overlayVC.transitioningDelegate = overlayTransitioningDelegate
        overlayVC.modalPresentationStyle = .Custom
        overlayVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    @IBAction func addQPhotoAction(sender: AnyObject) {
        
        whichCell = 0
        
        qPhoto = !qPhoto
        
        askTable.beginUpdates()
        askTable.endUpdates()
        
        launchImagePickerPopover()
    }
    
    @IBAction func addO1PhotoAction(sender: AnyObject) {
        
        whichCell = 1
        
        oPhoto = !oPhoto
        
        askTable.beginUpdates()
        askTable.endUpdates()
        
        launchImagePickerPopover()
    }
    
    
    @IBAction func addO2PhotoAction(sender: AnyObject) {
        
        whichCell = 2
        
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
        
        imageCount = imageCount++ // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func o2PhotoButtonPressed(sender: AnyObject) {
        
        whichCell = 1 // Keep popover from double launching
        
        imageCount = imageCount++ // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        //dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
        self.askTable.reloadData()
        
        //dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
        print("a")
        
        if (self.chosenImageHighRes[0] != nil || self.question != nil)
            && (self.chosenImageHighRes[1] != nil || self.option1 != nil)
            && (self.chosenImageHighRes[2] != nil || self.option2 != nil) {
                
                print("b")
                
                if self.facebookWithAppGroupies.count > 1 {
                    
                    print("c")
                    
                    // Submit Q
                    self.submitQ(sender)
                    
                } else {
                    
                    print("d")
                    
                    popDirection = "top"
                    let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController")
                    self.prepareOverlayVC(overlayVC)
                    self.presentViewController(overlayVC, animated: true, completion: nil)
                    
                    //                            let title = "Oops, you can't Q no one!"
                    //                            let message = "Use the \"Add Groupies\" button at the top right to select groupies."
                    //                            displayAlert(title, message, self)
                    
                }
                
        } else {
            
            print("e")
            
            let title = "Error"
            let message = "You need to provide a Q and two options!"
            displayAlert(title, message: message, sender: self)
        }
        //}
        //}
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingFrame = self.view.frame
        
        // Format view
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0, 0)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5

        picker.delegate = self
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = tableBackgroundColor
        askTable.layer.cornerRadius = cornerRadius
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        tapGesture.cancelsTouchesInView = true
        askTable.addGestureRecognizer(tapGesture)
        
        self.askTable.backgroundColor = UIColor.clearColor()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        print(isGroupieName)
        
        // Sort groupies
        for groupie in friendsDictionary {
            if groupie["isSelected"] as! Bool == true {
                facebookWithAppGroupies.append(groupie["id"] as! String)
            }
        }
    }
    
    
    func submitQ(sender: AnyObject) -> Void {
        
        print("1")
        
        //displaySpinnerView(spinnerActive: true, UIBlock: true, askBoxView, askBlurView, "Submitting Q", self)
        
        //blockUI(true, askSpinner, askBlurView, self)
        
        func createPNG(image: UIImage, name: String) -> (PFFile) {
            
            let imageData = UIImagePNGRepresentation(image)
            let imageFile: PFFile = PFFile(name: name, data: imageData!)
            return imageFile
        }
        
        print("2")
        
        // Store images to a temp var so the view can be cleared
        // to submit another Q while images upload
        var thumbnailImages: [PFFile?] = [nil, nil, nil]
        if self.chosenImageThumbnail[0] != nil { thumbnailImages[0] = createPNG(self.chosenImageThumbnail[0]!, name: "questionImage.png") }
        if self.chosenImageThumbnail[1] != nil { thumbnailImages[1] = createPNG(self.chosenImageThumbnail[1]!, name: "option1Image.png")  }
        if self.chosenImageThumbnail[2] != nil { thumbnailImages[2] = createPNG(self.chosenImageThumbnail[2]!, name: "option2Image.png")  }
        
        print("3")
        
        var highResImages: [PFFile?] = [nil, nil, nil]
        if self.chosenImageHighRes[0] != nil { highResImages[0] = createPNG(self.chosenImageHighRes[0]!, name: "questionImage.png") }
        if self.chosenImageHighRes[1] != nil { highResImages[1] = createPNG(self.chosenImageHighRes[1]!, name: "option1Image.png")  }
        if self.chosenImageHighRes[2] != nil { highResImages[2] = createPNG(self.chosenImageHighRes[2]!, name: "option2Image.png")  }
        
        print("4")
        
        // Create PFObject for images
        var photoJoinQ = PFObject(className: "PhotoJoin")
        var photoJoin1 = PFObject(className: "PhotoJoin")
        var photoJoin2 = PFObject(className: "PhotoJoin")
        
        print("5")
        
        // Add images to PFObject
        var qImages: [PFObject] = []
        
        if thumbnailImages[0] != nil {
            photoJoinQ["thumb"] = thumbnailImages[0]!
        } else {
            photoJoinQ["thumb"] = NSNull()
        }
        if highResImages[0] != nil {
            photoJoinQ["fullRes"] = highResImages[0]!
        } else {
            photoJoinQ["fullRes"] = NSNull()
        }
        qImages.append(photoJoinQ)
        
        print("6")
        
        if thumbnailImages[1] != nil {
            photoJoin1["thumb"]  = thumbnailImages[1]!
        } else {
            photoJoin1["thumb"]  = NSNull()
        }
        if highResImages[1] != nil {
            photoJoin1["fullRes"]  = highResImages[1]!
        } else {
            photoJoin1["fullRes"]  = NSNull()
        }
        qImages.append(photoJoin1)
        
        print("7")
        
        if thumbnailImages[2] != nil {
            photoJoin2["thumb"]  = thumbnailImages[2]!
        } else {
            photoJoin2["thumb"]  = NSNull()
        }
        if highResImages[2] != nil {
            photoJoin2["fullRes"]  = highResImages[2]!
        } else {
            photoJoin2["fullRes"]  = NSNull()
        }
        qImages.append(photoJoin2)
        
        print("8")
        
        // Create PFObject for Q
        var socialQ = PFObject(className: "SocialQs")
        socialQ["asker"] = PFUser.currentUser()
        
        print("9")
        
        // Add text to PFObject
        if question != nil { socialQ["questionText"] = question }
        if option1  != nil { socialQ["option1Text"]  = option1  }
        if option2  != nil { socialQ["option2Text"]  = option2  }
        
        print("10")
        
        // Add pointers to images
        if qImages.count > 0 { socialQ.setObject(qImages, forKey: "images") }
        
        // Initialize vote counters in PFObject
        socialQ["option1Stats"] = Int(0)
        socialQ["option2Stats"] = Int(0)
        
        print("11")
        
        // Mark as undelted by asker
        //socialQ["deleted"] = false
        
        // ***************************************************
        // Askers QJoin entry
        // ***************************************************
        var qJoinCurrentUser = PFObject(className: "QJoin")
        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "asker")
        qJoinCurrentUser.setObject(PFUser.currentUser()!["facebookId"] as! String, forKey: "to")
        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "from")
        qJoinCurrentUser.setObject(false, forKey: "deleted")
        qJoinCurrentUser.setObject(socialQ, forKey: "question")
        
        qJoinCurrentUser.pinInBackgroundWithBlock({ (success, error) -> Void in
            
            print("12")
            
            if error != nil {
                
                print("There was an error pinning new Q")
                
            } else {
                
//                // Trigger reload of calling view(s)
//                NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
//                //                NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
//                //                NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
//                
//                // Transition back to originating tab
//                self.navigationController?.popViewControllerAnimated(true)
//                
//                // clear text and photo entries
//                self.cancelButtonAction(sender)
            }
            
            
            // Pin completed object to local data store
            socialQ.pinInBackgroundWithBlock { (success, error) -> Void in
                
                print("13")
                
                if error == nil {
                    
                    print("Successfully pinned new Q object")
                    
                    // Trigger reload of calling view(s)
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
                    //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
                    //NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
                    
                    // Transition back to originating tab
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    // clear text and photo entries
                    self.cancelButtonAction(sender)
                    
                    //displaySpinnerView(spinnerActive: false, UIBlock: false, self.askBoxView, self.askBlurView, nil, self)
                    
                    //blockUI(false, self.askSpinner, self.askBlurView, self)
                }
            }
        })
        
        
        
        // ************** NETWORK CHECK **********************************
        // Save PFObject to Parse
        socialQ.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                print("14")
                
                print("Success saving images in background!")
                
                // Assign to groupies in QJoinTable
                // Include an entry for self (ie: user will be "to", "from" AND "asker"
                var sQsGroupieObjects: [PFObject] = []
                
                for groupiesId in self.facebookWithAppGroupies {
                    
                    var qJoin = PFObject(className: "QJoin")
                    qJoin.setObject(PFUser.currentUser()!, forKey: "asker")
                    qJoin.setObject(groupiesId, forKey: "to")
                    qJoin.setObject(PFUser.currentUser()!, forKey: "from")
                    qJoin.setObject(false, forKey: "deleted")
                    qJoin.setObject(socialQ, forKey: "question")
                    
                    sQsGroupieObjects.append(qJoin)
                    
                }
                
                // ***************************************************
                // ***************************************************
                // **** NEEDS NETWORK CHECK + RETRY FUNCTIONALITY ****
                // ***************************************************
                // ***************************************************
                PFObject.saveAllInBackground(sQsGroupieObjects, block: { (success, error) -> Void in
                    
                    print("15")
                    
                    if error == nil {
                        
                        print("sQs QJoin entries created")
                        
                        // *******************
                        //
                        self.sendPushes()
                        //
                        // *******************
                        
                    } else {
                        
                        print("There was an error creating sQs QJoin entries: \n\(error)")
                    }
                })
                
                qJoinCurrentUser.saveEventually({ (success, error) -> Void in
                    
                    print("QJoin entry for SELF successfully created")
                })
            }
        })
    }
    
    
    func sendPushes() {
        
        print("Sending pushes")
        
        //        // SEND CHANNEL PUSH -----------------------------------------------------
        //        var pushGeneral:PFPush = PFPush()
        //        pushGeneral.setChannel("reloadTheirTable")
        //
        //        // Create dictionary to send JSON to parse/to other devices
        //        var dataGeneral: Dictionary = ["alert":"", "badge":"0", "content-available":"0", "sound":""]
        //
        //        pushGeneral.setData(dataGeneral)
        //
        //        pushGeneral.sendPushInBackgroundWithBlock({ (success, error) -> Void in
        //            if error == nil { //println("General push sent!")
        //            }
        //        })
        
        // SEND SEGMENT PUSH NOTIFICATION ---------------------------------------
        let toUsers: PFQuery = PFUser.query()!
        let pushQuery: PFQuery = PFInstallation.query()!
        
        toUsers.whereKey("facebookId", containedIn: facebookWithAppGroupies)
        pushQuery.whereKey("user", matchesQuery: toUsers)
        
        let pushDirected: PFPush = PFPush()
        pushDirected.setQuery(pushQuery)
        
        // Create dictionary to send JSON to parse/to other devices
        //var dataDirected: Dictionary = ["alert":"New Q from \(myName)!", "badge":"Increment", "content-available":"0", "sound":""]////
        //pushDirected.setData(dataDirected)////
        pushDirected.setMessage("New Q from \(name)!")
        
        // Send Push Notifications
        pushDirected.sendPushInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                self.facebookWithAppGroupies.removeAll(keepCapacity: true)
                
                print("Directed push notification sent!")
                
            } else {
                
                self.facebookWithAppGroupies.removeAll(keepCapacity: true)
                
                print("There was an error sending notifications")
            }
        })
        // SEND DIRECTED PUSH NOTIFICATION ---------------------------------------
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
                if chosenImageHighRes[0] == nil {
                    cell.questionImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.questionImageView.image = chosenImageHighRes[0]//indexPath.row]
                }
                
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
                
                if chosenImageHighRes[1] == nil {
                    cell.option1ImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.option1ImageView.image = chosenImageHighRes[1]
                }
                
                if chosenImageHighRes[2] == nil {
                    cell.option2ImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.option2ImageView.image = chosenImageHighRes[2]
                }
                
            } else {
                
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
        
        // Make cells non-selectable, visually
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set cell background color
        cell.backgroundColor = tableBackgroundColor
        
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
            return 55
        }
    }
    
    
    func resignKeyboard() { self.askTable.endEditing(true) }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: Image Picker Shits
    func launchImagePickerPopover() -> Void {
        
        var titleMessage = "Please choose image source"
        if whichCell == 0 {
            titleMessage = "Please choose Q image source"
        } else if whichCell == 1 {
            //titleMessage = "Please choose Option \(((imageCount + 1) % 2) + 1) image source"
            titleMessage = "Please choose Option 1 image source"
        } else {
            titleMessage = "Please choose Option 2 image source"
        }
        
        let alert = UIAlertController(title: titleMessage, message: nil, preferredStyle:
            .ActionSheet) // Can also set to .Alert if you prefer
        
        let cameraAction = UIAlertAction(title: "Take Picture", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { (action) -> Void in
            self.picker.allowsEditing = false //2
            self.picker.sourceType = .PhotoLibrary //3
            self.presentViewController(self.picker, animated: true, completion: nil)//4
        }
        alert.addAction(libraryAction)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) -> Void in
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
            if self.whichCell == 0 && self.chosenImageHighRes[0] == nil {
                self.qPhoto = false//!self.qPhoto
            } else if self.whichCell == 1 && self.chosenImageHighRes[1] == nil && self.chosenImageHighRes[2] == nil {
                print("FUCKKKKKKK")
                self.chosenImageHighRes[1] = nil
                self.chosenImageHighRes[2] = nil
                self.askTable.reloadData() // Could just reload row...
                
                self.oPhoto = false//!self.oPhoto
                self.imageCount = 0
            }
            
            self.askTable.beginUpdates()
            self.askTable.endUpdates()
        }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if whichCell == 0 {
            
            chosenImageHighRes[0] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, targetSize: CGSize(width: photoMax, height: photoMax))
            chosenImageThumbnail[0] = resizeImage(chosenImageHighRes[0]!, targetSize: CGSize(width: thumbnailMax, height: thumbnailMax))
            
        } else if whichCell == 1 {
            
            chosenImageHighRes[1] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, targetSize: CGSize(width: photoMax, height: photoMax))
            chosenImageThumbnail[1] = resizeImage(self.chosenImageHighRes[1]!, targetSize: CGSize(width: thumbnailMax, height: thumbnailMax))
            
        } else if whichCell == 2 {
            
            chosenImageHighRes[2] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, targetSize: CGSize(width: photoMax, height: photoMax))
            chosenImageThumbnail[2] = resizeImage(self.chosenImageHighRes[2]!, targetSize: CGSize(width: thumbnailMax, height: thumbnailMax))
            
            //        } else if whichCell == 1 {
            //
            //            imageCount = imageCount + 1
            //
            //            chosenImageHighRes[(imageCount % 2) + 1] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
            //            chosenImageThumbnail[(imageCount % 2) + 1] = resizeImage(self.chosenImageHighRes[(imageCount % 2) + 1]!, CGSize(width: thumbnailMax, height: thumbnailMax))
            //
            //        } else if whichCell == -1 {
            //
            //            chosenImageHighRes[(imageCount % 2) + 1] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
            //            chosenImageThumbnail[(imageCount % 2) + 1] = resizeImage(chosenImageHighRes[(imageCount % 2) + 1]!, CGSize(width: thumbnailMax, height: thumbnailMax))
        }
        
        askTable.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
        
        //        if (imageCount) % 2 == 0 && chosenImageHighRes[2] == nil { // UIImage(named: "camera.png") {
        //
        //            launchImagePickerPopover()
        //        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        if whichCell == 0 {
            qPhoto = !qPhoto
        } else {
            chosenImageHighRes[1] = nil
            chosenImageHighRes[2] = nil
            askTable.reloadData() // Could just reload row...
            
            oPhoto = !oPhoto
            imageCount = 0
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
