//
//  AskViewController.swift
//  
//
//  Created by Brett Wiesman on 7/20/15.
//
//

import UIKit

class AskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKAppInviteDialogDelegate {
    
    let thumbnailMax = CGFloat(120)
    let photoMax = CGFloat(800)
    let rowHeights: [CGFloat] = [52, 130, 76, 150]
    
    var clear = false
    var qPhoto = false
    var oPhoto = false
    var imageCount = -1
    
    var chosenImageHighRes: [UIImage?] = [nil, nil, nil]
    var chosenImageThumbnail: [UIImage?] = [nil, nil, nil]
    
    let tableBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.3))
    
    var question: String? = nil
    var option1: String? = nil
    var option2: String? = nil
    
    var whichCell = -1
    
    let picker = UIImagePickerController()
    
    var askSpinner = UIActivityIndicatorView()
    var askBlurView = globalBlurView()
    
    @IBOutlet var askTable: UITableView!
    
    
    @IBAction func test(sender: AnyObject) {
        var inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
        if(inviteDialog.canShow()){
            let appLinkUrl:NSURL = NSURL(string: "https://fb.me/1482092405439439")!
//            let previewImageUrl:NSURL = NSURL(string: "http://mylink.com/image.png")!
            
            var inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
            inviteContent.appLinkURL = appLinkUrl
//            inviteContent.appInvitePreviewImageURL = previewImageUrl
            
            inviteDialog.content = inviteContent
            inviteDialog.delegate = self
            inviteDialog.show()
        }
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        println("Complete invite without error")
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        println("Error in invite \(error)")
    }
    
    
    
    @IBAction func groupiesButtonAction(sender: AnyObject) { }
    @IBAction func privacyButtonAction(sender: AnyObject) { }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        clear = true
        askTable.reloadData()
        
        chosenImageHighRes = [nil, nil, nil]
        chosenImageThumbnail = [nil, nil, nil]
        
        qPhoto = false
        oPhoto = false
        askTable.beginUpdates()
        askTable.endUpdates()
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
                
                if (self.chosenImageThumbnail[0] != nil || self.question != "")
                    && (self.chosenImageThumbnail[0] != nil || self.option1 != "")
                    && (self.chosenImageThumbnail[0] != nil || self.option2 != "") {
                    
                    // Submit Q
                    self.submitQ(sender)
                    
                } else {
                    
                    let title = "Error"
                    let message = "You need to provide a Q and two options!"
                    displayAlert(title, message, self)
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //// IF IS LINKED WITH FACEBOOK ------------------------------------------------
        // Download FB data in background
        // - backgrounding built into FBSDK methods
        downloadFacebookFriends({ (isFinished) -> Void in
            
            if isFinished { println("FB Download completion handler executed") }
        })
        //// IF IS LINKED WITH FACEBOOK ------------------------------------------------
        
        picker.delegate = self
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = tableBackgroundColor
        askTable.layer.cornerRadius = cornerRadius
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        tapGesture.cancelsTouchesInView = true
        askTable.addGestureRecognizer(tapGesture)
        
        self.askTable.backgroundColor = UIColor.clearColor()
        
        // Initiate Push Notifications
        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge |  UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        //
        // Does this AFTER notifications prompted is closed and if declined:
//        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
//            displayAlert("Please reconsider", "SocialQs uses notification methods to minimize data usage and ensure users have recieve quick service! Follow the link in the SocialQs settings page to enable notifications.", self)
//        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        
        returningFromPopover = false
        returningFromSettings = false
        topOffset = 64
        
        NSUserDefaults.standardUserDefaults().setObject(myFriends, forKey: myFriendsStorageKey)
        
        println(">>>>>>>>>>>>>>>>>>")
        println(isGroupieName)
        println(">>>>>>>>>>>>>>>>>>")
        
        /////////////////////////////////////////////
        // Sort groupies
        var socialQsGroupie = [String]()
        var facebookWithAppGroupie = [String]()
        var facebookWithoutAppGroupie = [String]()
        
        for groupie in friendsDictionary {
            if groupie["isSelected"] as! Bool == true {
                
                if groupie["type"] as! String == "socialQs" {
                    socialQsGroupie.append(groupie["name"] as! String)
                } else if groupie["type"] as! String == "facebookWithApp" {
                    facebookWithAppGroupie.append(groupie["id"] as! String)
                } else if groupie["type"] as! String == "facebookWithoutApp" {
                    facebookWithoutAppGroupie.append(groupie["id"] as! String)
                }
            }
        }
        println(socialQsGroupie)
        println(facebookWithAppGroupie)
        println(facebookWithoutAppGroupie)
        /////////////////////////////////////////////
    }
    
    
    func createPNG(image: UIImage, name: String) -> (PFFile) {
        
        let imageData = UIImagePNGRepresentation(image)
        var imageFile: PFFile = PFFile(name: name, data: imageData)
        return imageFile
    }
    
    
    func submitQ(sender: AnyObject) -> Void {
        
        blockUI(true, askSpinner, askBlurView, self)
        
        // Create PFObject
        var socialQ = PFObject(className: "SocialQs")
        socialQ["asker"] = PFUser.currentUser()
        if question != nil { socialQ["questionText"] = question }
        if option1  != nil { socialQ["option1Text"]  = option1  }
        if option2  != nil { socialQ["option2Text"]  = option2  }

        socialQ["option1Stats"] = Int(0)
        socialQ["option2Stats"] = Int(0)
        
        // Perform saveEventually (for network checking) with upload of images in callback
        socialQ.saveEventually({ (success, error) -> Void in
            
            if error == nil {
                
                println("SUCCSEX saving eventually!")
                
                socialQ.setObject(self.createPNG(self.chosenImageHighRes[0]!, name: "questionImage.png"), forKey: "questionPhoto")
                socialQ.setObject(self.createPNG(self.chosenImageHighRes[1]!, name: "option1Image.png"),  forKey: "option1Photo" )
                socialQ.setObject(self.createPNG(self.chosenImageHighRes[2]!, name: "option2Image.png"),  forKey: "option2Photo" )
                
                socialQ.saveInBackgroundWithBlock({ (success, errer) -> Void in
                    
                    if error == nil {
                        
                        println("Success saving images in background!")
                        
                        // Assign to groupies in QJoinTable
                        //
                        // CLOUD CODE!
                        //
                        // Include an entry for self (ie: user will be "to", "from" AND "asker"
                        //  - This is for MyQs delete tracking
                        
                    }
                })
            }
        })
        
        // Add images to PFObjet
        if chosenImageHighRes[0] != nil { socialQ["questionPhoto"] = createPNG(chosenImageHighRes[0]!, name: "questionImage.png") }
        if chosenImageHighRes[1] != nil { socialQ["option1Photo"]  = createPNG(chosenImageHighRes[1]!, name: "option1Image.png")  }
        if chosenImageHighRes[2] != nil { socialQ["option2Photo"]  = createPNG(chosenImageHighRes[2]!, name: "option2Image.png")  }
        
        // Pin completed object to local data store
        socialQ.pinInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil {
                
                println("Successfully pinned new Q object")
                
                // Switch to results tab when question is submitted
                // - Had to make storyboard ID for the tabBarController = "tabBarController"
                self.tabBarController?.selectedIndex = 1
                
                // clear text and photo entries
                self.cancelButtonAction(sender)
                
                blockUI(false, self.askSpinner, self.askBlurView, self)
            }
        }
        
        
        
        
        
        
        
        
        
        
        
//        // CREATE ENTRY FOR FULL RES IMAGES (upload later) -------------------------------------------------------------
//        var photos = PFObject(className: "PhotoFullMetalBlacket")
//        
//        var currentPId = ""
//        
//        photos.saveInBackgroundWithBlock { (success, error) -> Void in
//            
//            if error == nil {
//                currentPId = photos.objectId!
//            } else {
//                println("Error creating high res photos table entry!")
//            }
//            
//            // Add entry to "Votes Table" ----------------
//            var votes = PFObject(className: "Votes")
//            
//            votes.saveInBackgroundWithBlock({ (success, error) -> Void in
//                
//                if error == nil {
//                    
//                    var socialQ = PFObject(className: "SocialQs")
//                    
//                    // Q text
//                    if self.question != "" {
//                        socialQ["question"] = self.question
//                    }
//                    
//                    // Q photo
//                    //if self.isPhoto[0] == true {
//                    if self.chosenImageThumbnail[0] != nil {
//                        
//                        // Resize to THUMBNAIL and upload to SocialQs table
//                        let imageQ = self.chosenImageThumbnail[0]
//                        let imageQData = UIImagePNGRepresentation(imageQ)
//                        
//                        var imageQFile: PFFile = PFFile(name: "questionImage.png", data: imageQData)
//                        
//                        socialQ["questionPhoto"] = imageQFile
//                    }
//                    
//                    // Options text
//                    if self.option1 != ""  || self.option2 != "" {
//                        socialQ["option1"] = self.option1
//                        socialQ["option2"] = self.option2
//                    }
//                    
//                    // Check if O1 is photo or text and upload
//                    if self.chosenImageThumbnail[1] != nil {
//                        
//                        // Resize to THUMBNAIL and upload to SocialQs table
//                        let imageO1 = self.chosenImageThumbnail[1]
//                        let imageO1Data = UIImagePNGRepresentation(imageO1)
//                        
//                        var imageO1File: PFFile = PFFile(name: "option1Image.png", data: imageO1Data)
//                        
//                        socialQ["option1Photo"] = imageO1File
//                    }
//                    
//                    // Check if O2 is photo or text and upload
//                    if self.chosenImageThumbnail[2] != nil {
//                        
//                        // Resize to THUMBNAIL and upload to SocialQs table
//                        let imageO2 = self.chosenImageThumbnail[2]
//                        let imageO2Data = UIImagePNGRepresentation(imageO2)
//                        
//                        let imageO2File = PFFile(name: "option2Image.png", data: imageO2Data)
//                        
//                        socialQ["option2Photo"] = imageO2File
//                    }
//                    
//                    socialQ["stats1"] = 0
//                    socialQ["stats2"] = 0
//                    socialQ["privacyOptions"] = -1
//                    socialQ["askerId"] = PFUser.currentUser()!.objectId!
//                    socialQ["askername"] = PFUser.currentUser()!["username"]
//                    socialQ["votesId"] = votes.objectId!
//                    socialQ["photosId"] = currentPId
//                    
//                    socialQ.saveInBackgroundWithBlock { (success, error) -> Void in
//                        
//                        if error == nil {
//                            
//                            var currentQId = socialQ.objectId!
//                            isUploading.append(currentQId)
//                            
//                            // Reset all fields after submitting
//                            self.question = ""
//                            self.option1  = ""
//                            self.option2  = ""
//                            
//                            // Add qId to "UserQs" table - MyQs -------------------------------
//                            var userQsQuery = PFQuery(className: "UserQs")
//                            userQsQuery.whereKey("objectId", equalTo: uQId)
//                            
//                            // Execute query
//                            userQsQuery.findObjectsInBackgroundWithBlock({ (userQsObjects, error) -> Void in
//                                
//                                if error == nil {
//                                    
//                                    if let temp = userQsObjects {
//                                        
//                                        for userQsObject in temp {
//                                            
//                                            if userQsObject.objectId!! == uQId { // Append qId to myQs within UserQs table
//                                                
//                                                userQsObject.addUniqueObject(currentQId, forKey: "myQsId")
//                                                userQsObject.saveInBackground()
//                                            }
//                                        }
//                                        
//                                        // ---- Switch to results tab when question is submitted ----
//                                        // - Had to make storyboard ID for the tabBarController = "tabBarController"
//                                        self.tabBarController?.selectedIndex = 1
//                                        
//                                        // clear text and photo entries
//                                        self.cancelButtonAction(sender)
//                                        
//                                        // Unblock UI and remove spinner
//                                        blockUI(false, self.askSpinner, self.askBlurView, self)
//                                        
//                                        // ---- Upload full res images if necessary ---------------------------------------------
//                                        var expectedCount = 0
//                                        var downloadedCount = 0
//                                        
//                                        if self.chosenImageThumbnail[0] != nil { expectedCount++ }
//                                        if self.chosenImageThumbnail[1] != nil { expectedCount++ }
//                                        if self.chosenImageThumbnail[2] != nil { expectedCount++ }
//                                        
//                                        if expectedCount > 0 {
//                                            
//                                            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//                                            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//                                            
//                                            dispatch_async(backgroundQueue, {
//                                                
//                                                //println("This is run on the background queue")//
//                                                self.uploadFullResPhotos(currentPId, currentQId: currentQId, expectedCount: expectedCount, downloadedCount: downloadedCount)
//                                                
//                                                //dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                                //    println("This is run on the main queue, after the previous code in outer block")
//                                                //})
//                                            })
//                                        }
//                                    }
//                                    
//                                } else {
//                                    
//                                    println("Error updating UserQs Table - myQs")
//                                    println(error)
//                                }
//                            })
//                            // --------------------------------------------------------------------------------------
//                            
//                        } else {
//                            
//                            println("Write to SocialQs Table error:")
//                            println(error)
//                        }
//                    }
//                }
//            })
//        }
    }
    
    
//    func uploadFullResPhotos(currentPId: String, currentQId: String, expectedCount: Int, var downloadedCount: Int) {
//        
//        var photoQuery = PFQuery(className: "PhotoFullMetalBlacket")
//        photoQuery.whereKey("objectId", equalTo: currentPId)
//        photoQuery.findObjectsInBackgroundWithBlock { (photoObjects, error) -> Void in
//            
//            if error == nil {
//                
//                let uploadComplete = { () -> () in
//                    
//                    let index = find(isUploading, currentQId)
//                    isUploading.removeAtIndex(index!)
//                    
//                    // Send push notifications of new Q and assign Q to appropriate users
//                    self.sendPushes()
//                    self.assignQsToUsers(currentQId)
//                }
//                
//                if let temp = photoObjects {
//                    
//                    for photoObject in temp {
//                        
//                        // Q photo
//                        if self.chosenImageHighRes[0] != nil {
//                            
//                            // Upload  FULL RES to SocialQs table
//                            let imageQDataFull = UIImagePNGRepresentation(self.chosenImageHighRes[0]!)
//                            
//                            var imageQFileFull = PFFile(name: "questionImage.png", data: imageQDataFull)
//                            
//                            photoObject.setObject(imageQFileFull, forKey: "questionPhoto")
//                            photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
//                                
//                                if error == nil {
//                                    println("Full Res Q Photo Uploaded!")
//                                    
//                                    self.chosenImageHighRes[0] = nil
//                                    downloadedCount++
//                                    
//                                    if downloadedCount == expectedCount {
//                                        
//                                        uploadComplete()
//                                    }
//                                    
//                                } else {
//                                    println("Full res Q upload failed")
//                                    println(error)
//                                }
//                            })
//                        }
//                        
//                        // O1 photo
//                        if self.chosenImageHighRes[1] != nil {
//                            
//                            // Upload  FULL RES to SocialQs table
//                            let imageO1DataFull = UIImagePNGRepresentation(self.chosenImageHighRes[1]!)
//                            
//                            var imageO1FileFull = PFFile(name: "option1Image.png", data: imageO1DataFull)
//                            
//                            photoObject.setObject(imageO1FileFull, forKey: "option1Photo")
//                            photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
//                                
//                                if error == nil {
//                                    println("Full Res O1 Photo Uploaded!")
//                                    
//                                    self.chosenImageHighRes[1] = nil
//                                    downloadedCount++
//                                    
//                                    if downloadedCount == expectedCount {
//                                        
//                                        uploadComplete()
//                                    }
//                                    
//                                } else {
//                                    println("Full res O1 upload failed")
//                                    println(error)
//                                }
//                            })
//                        }
//                        
//                        // O2 photo
//                        if self.chosenImageHighRes[2] != nil {
//                            
//                            // Upload  FULL RES to SocialQs table
//                            let imageO2DataFull = UIImagePNGRepresentation(self.chosenImageHighRes[2]!)
//                            
//                            var imageO2FileFull = PFFile(name: "option2Image.png", data: imageO2DataFull)
//                            
//                            photoObject.setObject(imageO2FileFull, forKey: "option2Photo")
//                            photoObject.saveInBackgroundWithBlock({ (success, error) -> Void in
//                                
//                                if error == nil {
//                                    println("Full Res O2 Photo Uploaded!")
//                                    
//                                    self.chosenImageHighRes[2] = nil
//                                    downloadedCount++
//                                    
//                                    if downloadedCount == expectedCount {
//                                        
//                                        uploadComplete()
//                                    }
//                                    
//                                } else {
//                                    println("Full res O2 upload failed")
//                                    println(error)
//                                }
//                            })
//                        }
//                    }
//                }
//                
//            } else {
//                
//                println("Error loading full res images")
//                println(error)
//            }
//        }
//    }
    
    
    func assignQsToUsers(currentQId: String) {
        
        println("Assigning Q to users")
        
        // Split groupies by account type
        // - sQs can be assigned by unique username
        // - facebookWithApp must be queried by FB Id to get unique username
        // - facebookWithoutApp must get a message or invite
        //      - CLOUD CODE: provide a way to cache Q and send FB users once they get the app?
        
        /////////////////////////////////////////////
        // Sort groupies
        var socialQsGroupies = [String]()
        var facebookWithAppGroupie = [String]()
        var facebookWithoutAppGroupie = [String]()
        
        for groupie in friendsDictionary {
            if groupie["isSelected"] as! Bool == true {
                
                if groupie["type"] as! String == "socialQs" {
                    socialQsGroupies.append(groupie["name"] as! String)
                } else if groupie["type"] as! String == "facebookWithApp" {
                    facebookWithAppGroupie.append(groupie["id"] as! String)
                } else if groupie["type"] as! String == "facebookWithoutApp" {
                    facebookWithoutAppGroupie.append(groupie["id"] as! String)
                }
            }
        }
        println(socialQsGroupies)
        /////////////////////////////////////////////
        
        // Add qId to "UserQs" table ------
        var userQsQuery = PFQuery(className: "UserQs")
        
        if isGroupieName.count > 0 {
            userQsQuery.whereKey("username", containedIn: socialQsGroupies)
        }
        
        // Execute query
        userQsQuery.findObjectsInBackgroundWithBlock({ (userQsObjects, error) -> Void in
            
            if error == nil {
                
                if let temp = userQsObjects {
                    
                    for userQsObject in temp {
                        
                        if userQsObject.objectId!! != uQId { // Append qId to theirQs within UserQs table
                            
                            userQsObject.addUniqueObject(currentQId, forKey: "theirQsId")
                            userQsObject.saveInBackground()
                        }
                    }
                }
                
            } else {
                
                println("Error updating UserQs Table - Their Qs")
                println(error)
            }
        })
    }
    
    
    
    
    
    func sendPushes() {
        
        println("Sending pushes")
        
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
        // ****CURRENTLY SEND TO ALL IF NO ONE IS SELECTED!!****
        
        var pushQuery: PFQuery = PFInstallation.query()!
        
        if isGroupieName.isEmpty == false {
            
            toUsers.whereKey("username", containedIn: isGroupieName)
            pushQuery.whereKey("user", matchesQuery: toUsers)
            
        } else {
            // If sendToGroupies is empty, filter push to all users
            // ********************************
            // CHANGE THIS LATER!!!!!!
            // ********************************
            pushQuery.whereKey("user", notContainedIn: isGroupieName)
            //pushQuery.whereKey("username", doesNotMatchQuery: toUsers)
        }
        
        var pushDirected: PFPush = PFPush()
        pushDirected.setQuery(pushQuery)
        
        // Create dictionary to send JSON to parse/to other devices
        //var dataDirected: Dictionary = ["alert":"New Q from \(myName)!", "badge":"Increment", "content-available":"0", "sound":""]////
        //pushDirected.setData(dataDirected)////
        pushDirected.setMessage("New Q from \(username)!")
        
        // Send Push Notifications
        pushDirected.sendPushInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                isGroupieName.removeAll(keepCapacity: true)
                //isGroupieQId.removeAll(keepCapacity: true)
                
                //println("Directed push notification sent!")
                //println("-----")
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
                if chosenImageThumbnail[0] == nil {
                    cell.questionImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.questionImageView.image = chosenImageThumbnail[indexPath.row]
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
                
                if chosenImageThumbnail[1] == nil {
                    cell.option1ImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.option1ImageView.image = chosenImageThumbnail[1]
                }
                
                if chosenImageThumbnail[2] == nil {
                    cell.option2ImageView.image = UIImage(named: "camera.png")
                } else {
                    cell.option2ImageView.image = chosenImageThumbnail[2]
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
            return 106
        }
    }
    
    
    func resignKeyboard() { self.askTable.endEditing(true) }
    
    
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
            
            if self.whichCell == 0 && self.chosenImageThumbnail[0] == nil {
                self.qPhoto = false//!self.qPhoto
            } else if self.whichCell == 1 && self.chosenImageThumbnail[2] == nil {
                self.chosenImageThumbnail[1] = nil//UIImage(named: "camera.png")
                self.chosenImageThumbnail[2] = nil//UIImage(named: "camera.png")
                self.chosenImageHighRes[1] = nil
                self.chosenImageHighRes[2] = nil
                self.askTable.reloadData() // Could just reload row...
                
                self.oPhoto = false//!self.oPhoto
                self.imageCount = -1
            }
            
            self.askTable.beginUpdates()
            self.askTable.endUpdates()
        }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if whichCell == 0 {
            
            chosenImageHighRes[0] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
            //chosenImageThumbnail[0] = resizeImage(chosenImageHighRes[0]!, CGSize(width: thumbnailMax, height: thumbnailMax))
            
        } else if whichCell == 1 {
            
            imageCount = imageCount + 1
            
            chosenImageHighRes[(imageCount % 2) + 1] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
            //chosenImageThumbnail[(imageCount % 2) + 1] = resizeImage(self.chosenImageHighRes[(imageCount % 2) + 1]!, CGSize(width: thumbnailMax, height: thumbnailMax))
            
        } else if whichCell == -1 {
            
            chosenImageHighRes[(imageCount % 2) + 1] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
            //chosenImageThumbnail[(imageCount % 2) + 1] = resizeImage(chosenImageHighRes[(imageCount % 2) + 1]!, CGSize(width: thumbnailMax, height: thumbnailMax))
        }
        
        askTable.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if (imageCount) % 2 == 0 && chosenImageThumbnail[2] == UIImage(named: "camera.png") {
            
            launchImagePickerPopover()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        if whichCell == 0 {
            qPhoto = !qPhoto
        } else {
            chosenImageThumbnail[1] = UIImage(named: "camera.png")
            chosenImageThumbnail[2] = UIImage(named: "camera.png")
            chosenImageHighRes[1] = nil
            chosenImageHighRes[2] = nil
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
    
    

    
    
}
