//
//  AskViewController.swift
//  
//
//  Created by Brett Wiesman on 7/20/15.
//
//

import UIKit

class AskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKAppInviteDialogDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    let thumbnailMax = CGFloat(120)
    let photoMax = CGFloat(800)
    let rowHeights: [CGFloat] = [52, 130, 76, 150]
    
    var clear = false
    var qPhoto = false
    var o1Photo = false
    var o2Photo = false
    var imageCount = 0
    
    var chosenImageHighRes: [UIImage?] = [nil, nil, nil]
    var chosenImageThumbnail: [UIImage?] = [nil, nil, nil]
    
    let tableBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: CGFloat(0.3))
    
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
    
    
    
    @IBAction func test(sender: AnyObject) {
        downloadFacebookFriends { (success) -> Void in }
//        var inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
//        if(inviteDialog.canShow()){
////            let appLinkUrl:NSURL = NSURL(string: "https://fb.me/1482092405439439")!
////            let previewImageUrl:NSURL = NSURL(string: "http://socialqs.co/styles/images/brettFinal.png")!
//            
//            var inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
////            inviteContent.appLinkURL = appLinkUrl
////            inviteContent.appInvitePreviewImageURL = previewImageUrl
//            
//            inviteDialog.content = inviteContent
//            inviteDialog.delegate = self
//            inviteDialog.show()
//        }
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Complete invite without error")
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("Error in invite \(error)")
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
        o1Photo = false
        o2Photo = false
        askTable.beginUpdates()
        askTable.reloadData()
        askTable.endUpdates()
        
    }
    
    
    private func prepareOverlayVC(overlayVC: UIViewController) {
        overlayVC.transitioningDelegate = overlayTransitioningDelegate
        overlayVC.modalPresentationStyle = .Custom
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
        
        imageCount = 1
        
        o1Photo = !o1Photo
        
        askTable.beginUpdates()
        askTable.endUpdates()
        
        launchImagePickerPopover()
    }
    
    
    @IBAction func addO2PhotoAction(sender: AnyObject) {
        
        whichCell = 1
        
        imageCount = 2
        
        o2Photo = !o2Photo
        
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
        
        imageCount = 1 // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func o2PhotoButtonPressed(sender: AnyObject) {
        
        whichCell = 1 // Keep popover from double launching
        
        imageCount = 2 // Choose which image location to fill
        
        launchImagePickerPopover()
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        //dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.askTable.reloadData()
        self.askTable.layoutIfNeeded()
            
            //dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                if (self.chosenImageHighRes[0] != nil || self.question != nil)
                    && (self.chosenImageHighRes[1] != nil || self.option1 != nil)
                    && (self.chosenImageHighRes[2] != nil || self.option2 != nil) {
                    
                        if self.facebookWithAppGroupies.count > 0 {
                            
                            // Submit Q
                            self.submitQ(sender)
                        
                        } else {
                            
                            popErrorMessage = "You must select at least one groupie from the menu at the top right!"
                            popDirection = "top"
                            let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController") 
                            self.prepareOverlayVC(overlayVC)
                            self.presentViewController(overlayVC, animated: true, completion: nil)
                        }
                    
                } else {
                    
                    popErrorMessage = "You must provide a Q and two options!"
                    popDirection = "top"
                    let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController")
                    self.prepareOverlayVC(overlayVC)
                    self.presentViewController(overlayVC, animated: true, completion: nil)
                }
            //}
        //}
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        UITabBar.appearance().translucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var btnName: UIButton = UIButton()
//        btnName.setImage(UIImage(named: "addUser.png"), forState: .Normal)
//        btnName.frame = CGRectMake(0, 0, 30, 30)
//        btnName.addTarget(self, action: Selector("displayGroupiesView"), forControlEvents: .TouchUpInside)
//        //.... Set Right/Left Bar Button item
//        var rightBarButton:UIBarButtonItem = UIBarButtonItem()
//        rightBarButton.customView = btnName
//        rightBarButton.tintColor = UIColor.greenColor()
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        // Add "groupies" and "settings" buttons
        let groupiesNavigationButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "addUser.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "displayGroupiesView")
        groupiesNavigationButton.tintColor = UIColor.whiteColor()
        
        let settingsButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "displaySettingsView")
        settingsButton.tintColor = UIColor.whiteColor()
        
        //self.navigationItem.setRightBarButtonItems([settingsButton, groupiesNavigationButton], animated: true)
        self.navigationItem.setRightBarButtonItems([groupiesNavigationButton], animated: true)
        
        
        
        
        
        picker.delegate = self
        
        askTable.delegate = self
        askTable.dataSource = self
        
        askTable.backgroundColor = tableBackgroundColor
        askTable.layer.cornerRadius = cornerRadius
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        tapGesture.cancelsTouchesInView = true
        askTable.addGestureRecognizer(tapGesture)
        
        self.askTable.backgroundColor = UIColor.clearColor()
        
        //
        // Does this AFTER notifications prompted is closed and if declined:
//        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
//            displayAlert("Please reconsider", "SocialQs uses notification methods to minimize data usage and ensure users have recieve quick service! Follow the link in the SocialQs settings page to enable notifications.", self)
//        }
    }
    
    
    func displayGroupiesView() {
        
        performSegueWithIdentifier("toGroupies", sender: self)
    }
    
    
    func displaySettingsView() {
        
        performSegueWithIdentifier("toSettings", sender: self)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        print(isGroupieName)
        
        
//        UITabBar.appearance().barTintColor = UIColor.whiteColor()
//        UITabBar.appearance().translucent = false
        
//        returningFromPopover = false
//        returningFromSettings = false
//        topOffset = 64
        
        //NSUserDefaults.standardUserDefaults().setObject(myFriends, forKey: myFriendsStorageKey)
        
        /////////////////////////////////////////////
        // Sort groupies
        for groupie in friendsDictionary {
            if groupie["isSelected"] as! Bool == true {

//                if groupie["type"] as! String == "socialQs" {
//                    socialQsGroupies.append(groupie["name"] as! String)
//                } else if groupie["type"] as! String == "facebookWithApp" {
                    facebookWithAppGroupies.append(groupie["id"] as! String)
//                } else if groupie["type"] as! String == "facebookWithoutApp" {
//                    facebookWithoutAppGroupies.append(groupie["id"] as! String)
//                }
            }
        }
//        println("sQs: \n\(socialQsGroupies)")
//        println("FacebookWithApp: \n\(facebookWithAppGroupies)")
//        println("FacebookWithoutApp: \n\(facebookWithoutAppGroupies)")
        /////////////////////////////////////////////
    }
    
    
//    func submitQ(sender: AnyObject) -> Void {
//        
//        //displaySpinnerView(spinnerActive: true, UIBlock: true, askBoxView, askBlurView, "Submitting Q", self)
//        
//        //blockUI(true, askSpinner, askBlurView, self)
//        
//        func createPNG(image: UIImage, name: String) -> (PFFile) {
//            
//            let imageData = UIImagePNGRepresentation(image)
//            let imageFile: PFFile = PFFile(name: name, data: imageData!)
//            return imageFile
//        }
//        
//        
//        // Create PFObject for Q
//        var socialQ = PFObject(className: "SocialQs")
//        socialQ["asker"] = PFUser.currentUser()
//        
//        
//        // Store images to a temp var so the view can be cleared 
//        // to submit another Q while images upload
////        var thumbnailImages: [PFFile?] = [nil, nil, nil]
////        var highResImages: [PFFile?] = [nil, nil, nil]
//        
//        if self.chosenImageThumbnail[0] != nil {
//            //var photoJoinQ = PFObject(className: "PhotoJoin")
//            let thumbnailImages = createPNG(self.chosenImageThumbnail[0]!, name: "questionImage.png")
//            //photoJoinQ["thumb"] = thumbnailImages
//            let highResImages = createPNG(self.chosenImageHighRes[0]!, name: "questionImage.png")
//            //photoJoinQ["fullRes"] = highResImages
//            socialQ.setObject(thumbnailImages, forKey: "questionImageThumb")
//            socialQ.setObject(highResImages, forKey: "questionImageFull")
//        }
//        if self.chosenImageThumbnail[1] != nil {
//            //var photoJoin1 = PFObject(className: "PhotoJoin")
//            let thumbnailImages = createPNG(self.chosenImageThumbnail[1]!, name: "option1Image.png")
//            //photoJoin1["thumb"] = thumbnailImages
//            let highResImages = createPNG(self.chosenImageHighRes[1]!, name: "option1Image.png")
//            //photoJoin1["fullRes"] = highResImages
//            socialQ.setObject(thumbnailImages, forKey: "option1ImageThumb")
//            socialQ.setObject(highResImages, forKey: "option1ImageFull")
//        }
//        if self.chosenImageThumbnail[2] != nil {
//            //var photoJoin2 = PFObject(className: "PhotoJoin")
//            let thumbnailImages = createPNG(self.chosenImageThumbnail[2]!, name: "option2Image.png")
//            //photoJoin2["thumb"] = thumbnailImages
//            let highResImages = createPNG(self.chosenImageHighRes[2]!, name: "option2Image.png")
//            //photoJoin2["fullRes"] = highResImages
//            socialQ.setObject(thumbnailImages, forKey: "option2ImageThumb")
//            socialQ.setObject(highResImages, forKey: "option2ImageFull")
//        }
//        
////        if self.chosenImageHighRes[0] != nil { }
////        if self.chosenImageHighRes[1] != nil { }
////        if self.chosenImageHighRes[2] != nil { }
//        
//        // Create PFObject for images
//        
//        // Add images to PFObject
//        //var qImages: [PFObject] = []
//        
////        if thumbnailImages[0] != nil {
////            
////        } else {
////            photoJoinQ["thumb"] = NSNull()
////        }
////        if highResImages[0] != nil {
////            
////        } else {
////            photoJoinQ["fullRes"] = NSNull()
////        }
////        println(photoJoinQ)
////        //qImages.append(photoJoinQ)
////        
////        if thumbnailImages[1] != nil {
////            
////        } else {
////            photoJoin1["thumb"]  = NSNull()
////        }
////        if highResImages[1] != nil {
////            
////        } else {
////            photoJoin1["fullRes"]  = NSNull()
////        }
////        println(photoJoin1)
////        //qImages.append(photoJoin1)
////        
////        if thumbnailImages[2] != nil {
////            
////        } else {
////            photoJoin2["thumb"]  = NSNull()
////        }
////        if highResImages[2] != nil {
////            
////        } else {
////            photoJoin2["fullRes"]  = NSNull()
////        }
////        println(photoJoin2)
////        //qImages.append(photoJoin2)
//        
//        // Add text to PFObject
//        if question != nil { socialQ["questionText"] = question }
//        if option1  != nil { socialQ["option1Text"]  = option1  }
//        if option2  != nil { socialQ["option2Text"]  = option2  }
//        
////        // Add pointers to images
////        if qImages.count > 0 { socialQ.setObject(qImages, forKey: "images") }
//        
//        // Initialize vote counters in PFObject
//        socialQ["option1Stats"] = Int(0)
//        socialQ["option2Stats"] = Int(0)
//        
//        // Mark as undelted by asker
//        //socialQ["deleted"] = false
//        
//        
//        // Pin completed object to local data store
////        socialQ.pinInBackgroundWithBlock { (success, error) -> Void in
////            
////            if error == nil {
////                
////                println("Successfully pinned new Q object")
////                
////                // Trigger reload of calling view(s)
////                NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
////                //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
////                //NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
////                
////                // Transition back to originating tab
////                self.navigationController?.popViewControllerAnimated(true)
////                
////                // clear text and photo entries
////                self.cancelButtonAction(sender)
////
////                //displaySpinnerView(spinnerActive: false, UIBlock: false, self.askBoxView, self.askBlurView, nil, self)
////                
////                //blockUI(false, self.askSpinner, self.askBlurView, self)
////            }
//        //        }
//        
//        // ***************************************************
//        // Askers QJoin entry
//        // ***************************************************
//        var qJoinCurrentUser = PFObject(className: "QJoin")
//        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "asker")
//        qJoinCurrentUser.setObject(PFUser.currentUser()!["facebookId"] as! String, forKey: "to")
//        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "from")
//        qJoinCurrentUser.setObject(false, forKey: "deleted")
//        qJoinCurrentUser.setObject(socialQ, forKey: "question")
//        
//        qJoinCurrentUser.pinInBackgroundWithBlock({ (success, error) -> Void in
//            
//            if error != nil {
//                
//                print("There was an error pinning new Q")
//                
//            } else {
//                
//                // Trigger reload of calling view(s)
//                NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
////                NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
////                NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
//                
//                // Transition back to originating tab
//                self.navigationController?.popViewControllerAnimated(true)
//                //self.tabBarController?.selectedIndex = 1
//                
//                // clear text and photo entries
//                self.cancelButtonAction(sender)
//            }
//        })
//        
//        // ************** NETWORK CHECK **********************************
//        // Save PFObject to Parse
//        socialQ.saveInBackgroundWithBlock({ (success, error) -> Void in
//            
//            if error == nil {
//                
//                print("Success saving images in background!")
//                
//                // Assign to groupies in QJoinTable
//                // Include an entry for self (ie: user will be "to", "from" AND "asker"
//                var sQsGroupieObjects: [PFObject] = []
//                
//                for groupiesId in self.facebookWithAppGroupies {
//                    
//                    var qJoin = PFObject(className: "QJoin")
//                    qJoin.setObject(PFUser.currentUser()!, forKey: "asker")
//                    qJoin.setObject(groupiesId, forKey: "to")
//                    qJoin.setObject(PFUser.currentUser()!, forKey: "from")
//                    qJoin.setObject(false, forKey: "deleted")
//                    qJoin.setObject(socialQ, forKey: "question")
//                    
//                    sQsGroupieObjects.append(qJoin)
//
//                }
//                
//                // ***************************************************
//                // ***************************************************
//                // **** NEEDS NETWORK CHECK + RETRY FUNCTIONALITY ****
//                // ***************************************************
//                // ***************************************************
//                PFObject.saveAllInBackground(sQsGroupieObjects, block: { (success, error) -> Void in
//                    
//                    if error == nil {
//                        
//                        print("sQs QJoin entries created")
//                        
//                        // *******************
//                        //
//                        self.sendPushes()
//                        //
//                        // *******************
//                        
//                    } else {
//                        
//                        print("There was an error creating sQs QJoin entries: \n\(error)")
//                    }
//                })
//                
//                qJoinCurrentUser.saveEventually({ (success, error) -> Void in
//                    
//                    print("QJoin entry for SELF successfully created")
//                })
//            }
//        })
//    }
    func submitQ(sender: AnyObject) -> Void {
        
        // Don't block UI - this could take a while...
        displaySpinnerView(spinnerActive: true, UIBlock: false, _boxView: askBoxView, _blurView: askBlurView, progressText: "Submitting Q", sender: self)
        
        //blockUI(true, askSpinner, askBlurView, self)
        
        func createPNG(image: UIImage, name: String) -> (PFFile) {
            
            let imageData = UIImagePNGRepresentation(image)
            let imageFile: PFFile = PFFile(name: name, data: imageData!)
            return imageFile
        }
        
        // Create PFObject for Q
        let socialQ = PFObject(className: "SocialQs")
        socialQ["asker"] = PFUser.currentUser()
        
        if self.chosenImageThumbnail[0] != nil {
            //var photoJoinQ = PFObject(className: "PhotoJoin")
            let thumbnailImages = createPNG(self.chosenImageThumbnail[0]!, name: "questionImage.png")
            //photoJoinQ["thumb"] = thumbnailImages
            let highResImages = createPNG(self.chosenImageHighRes[0]!, name: "questionImage.png")
            //photoJoinQ["fullRes"] = highResImages
            socialQ.setObject(thumbnailImages, forKey: "questionImageThumb")
            socialQ.setObject(highResImages, forKey: "questionImageFull")
        }
        if self.chosenImageThumbnail[1] != nil {
            //var photoJoin1 = PFObject(className: "PhotoJoin")
            let thumbnailImages = createPNG(self.chosenImageThumbnail[1]!, name: "option1Image.png")
            //photoJoin1["thumb"] = thumbnailImages
            let highResImages = createPNG(self.chosenImageHighRes[1]!, name: "option1Image.png")
            //photoJoin1["fullRes"] = highResImages
            socialQ.setObject(thumbnailImages, forKey: "option1ImageThumb")
            socialQ.setObject(highResImages, forKey: "option1ImageFull")
        }
        if self.chosenImageThumbnail[2] != nil {
            //var photoJoin2 = PFObject(className: "PhotoJoin")
            let thumbnailImages = createPNG(self.chosenImageThumbnail[2]!, name: "option2Image.png")
            //photoJoin2["thumb"] = thumbnailImages
            let highResImages = createPNG(self.chosenImageHighRes[2]!, name: "option2Image.png")
            //photoJoin2["fullRes"] = highResImages
            socialQ.setObject(thumbnailImages, forKey: "option2ImageThumb")
            socialQ.setObject(highResImages, forKey: "option2ImageFull")
        }
        
        // Add text to PFObject
        if question != nil { socialQ["questionText"] = question }
        if option1  != nil { socialQ["option1Text"]  = option1  }
        if option2  != nil { socialQ["option2Text"]  = option2  }
        
        //        // Add pointers to images
        //        if qImages.count > 0 { socialQ.setObject(qImages, forKey: "images") }
        
        // Initialize vote counters in PFObject
        socialQ["option1Stats"] = Int(0)
        socialQ["option2Stats"] = Int(0)
        
        // Mark as undelted by asker
        //socialQ["deleted"] = false
        
        
        // Pin completed object to local data store
        //        socialQ.pinInBackgroundWithBlock { (success, error) -> Void in
        //
        //            if error == nil {
        //
        //                println("Successfully pinned new Q object")
        //
        //                // Trigger reload of calling view(s)
        //                NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
        //                //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
        //                //NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
        //
        //                // Transition back to originating tab
        //                self.navigationController?.popViewControllerAnimated(true)
        //
        //                // clear text and photo entries
        //                self.cancelButtonAction(sender)
        //
        //                //displaySpinnerView(spinnerActive: false, UIBlock: false, self.askBoxView, self.askBlurView, nil, self)
        //
        //                //blockUI(false, self.askSpinner, self.askBlurView, self)
        //            }
        //        }
        
        // ***************************************************
        // Askers QJoin entry
        // ***************************************************
        let qJoinCurrentUser = PFObject(className: "QJoin")
        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "asker")
        qJoinCurrentUser.setObject(PFUser.currentUser()!["facebookId"] as! String, forKey: "to")
        qJoinCurrentUser.setObject(PFUser.currentUser()!, forKey: "from")
        qJoinCurrentUser.setObject(false, forKey: "deleted")
        qJoinCurrentUser.setObject(socialQ, forKey: "question")
        
//        qJoinCurrentUser.pinInBackgroundWithBlock({ (success, error) -> Void in
//            
//            if error != nil {
//                
//                print("There was an error pinning new Q")
//                
//            } else {
//                
//                // Trigger reload of calling view(s)
//                NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
//                //                NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQs", object: nil)
//                //                NSNotificationCenter.defaultCenter().postNotificationName("refreshGlobalQs", object: nil)
//                
//                // Transition back to originating tab
//                self.navigationController?.popViewControllerAnimated(true)
//                //self.tabBarController?.selectedIndex = 1
//                
//                // clear text and photo entries
//                self.cancelButtonAction(sender)
//            }
//        })
        
        // ************** NETWORK CHECK **********************************
        // Save PFObject to Parse
        socialQ.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if error == nil {
                
                // Subscribe to channel
                let objId = socialQ.objectId!
                let newChannel = "Question_\(objId)"
                let currentInstallation = PFInstallation.currentInstallation()
                
                // If user has current channels, check if this one is NOT there and add it
                if let channels = (PFInstallation.currentInstallation().channels as? [String]) {
                    
                    if !channels.contains(newChannel) {
                        currentInstallation.addUniqueObject(newChannel, forKey: "channels")
                        currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
                            
                            if error == nil {
                                
                                print("Subscribed to \(newChannel)")
                            }
                        })
                    }
                    
                } else { // else add it as the first
                    
                    currentInstallation.addUniqueObject(newChannel, forKey: "channels")
                    currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if error == nil {
                            
                            print("Subscribed to \(newChannel)")
                        }
                    })
                }
                
                print("Success saving images in background!")
                
                // Assign to groupies in QJoinTable
                // Include an entry for self (ie: user will be "to", "from" AND "asker"
                var sQsGroupieObjects: [PFObject] = []
                
                for groupiesId in Set(self.facebookWithAppGroupies) {
                    
                    let qJoin = PFObject(className: "QJoin")
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
                    
                    // Remove spinner...
                    displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.askBoxView, _blurView: self.askBlurView, progressText: "Submitting Q", sender: self)
                    
                    // Refresh "myQs" and return to starting tab view
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQs", object: nil)
                    self.navigationController?.popViewControllerAnimated(true)
                    
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
        let dataDirected: Dictionary = ["alert":"New Q from \(name)!", "badge":"Increment", "content-available":"0"]
        pushDirected.setData(dataDirected)
        //pushDirected.setMessage("New Q from \(name)!")
        
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
            if o1Photo || o2Photo {
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
        } else if whichCell == 1 && imageCount == 1 {
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
                
                self.chosenImageHighRes[1] = nil
                self.chosenImageHighRes[2] = nil
                self.askTable.reloadData() // Could just reload row...
                
                self.o1Photo = false//!self.oPhoto
                self.o2Photo = false//!self.oPhoto
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
            
            print(imageCount)
            
            chosenImageHighRes[imageCount] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, targetSize: CGSize(width: photoMax, height: photoMax))
            chosenImageThumbnail[imageCount] = resizeImage(self.chosenImageHighRes[imageCount]!, targetSize: CGSize(width: thumbnailMax, height: thumbnailMax))
            
            
//            chosenImageHighRes[2] = resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, CGSize(width: photoMax, height: photoMax))
//            chosenImageThumbnail[2] = resizeImage(self.chosenImageHighRes[2]!, CGSize(width: thumbnailMax, height: thumbnailMax))
            
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
            
            qPhoto = false
            
        } else {
            
            if chosenImageHighRes[1] == nil && chosenImageHighRes[2] == nil {
                
                o1Photo = false
                o2Photo = false
                imageCount = 0
                
                askTable.reloadData() // Could just reload row...
            }
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


//extension NSDate {
//    struct Date {
//        static let formatter = NSDateFormatter()
//    }
//    var formatted: String {
//        Date.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
//        Date.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
//        Date.formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
//        Date.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        return Date.formatter.stringFromDate(self)
//    }
//}
