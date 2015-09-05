//
//  QsTheirTableVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/14/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsTheirTableVC: UITableViewController {
    
    var option1Offset: CGFloat = 68.0
    var option2Offset: CGFloat = 68.0
    
    var currentCell = 0
    
    var blockCheck = false // Value to decide if cell should be blocked (vote updating)
    
    //var questionObjects: [AnyObject] = []
    var QJoinObjects: [AnyObject] = []
    
    var refresher: UIRefreshControl!
//    var theirQsSpinner = UIActivityIndicatorView()
//    var theirQsBlurView = globalBlurView()
    var theirQsSpinner = UIView()
    var theirQsBlurView = globalBlurView()
    
    @IBAction func vote1ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 1) }
    
    @IBAction func vote2ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 2) }
    
    @IBAction func zoomQButton(sender: AnyObject) {
        
        zoomPage = 0
        setPhotosToZoom(sender)
    }
    
    @IBAction func zoom1ButtonAction(sender: AnyObject) {
        
        zoomPage = 0
        
        if (QJoinObjects[sender.tag]["question"]!!["questionPhoto"] as? PFFile != nil) { zoomPage++ }
        
        setPhotosToZoom(sender)
    }
    
    @IBAction func zoom2ButtonAction(sender: AnyObject) {
        
        zoomPage = 0
        
        if (QJoinObjects[sender.tag]["question"]!!["questionPhoto"] as? PFFile != nil) { zoomPage++ }
        if (QJoinObjects[sender.tag]["question"]!!["option1Photo"]  as? PFFile != nil) { zoomPage++ }
        
        setPhotosToZoom(sender)
    }

    
    func setPhotosToZoom(sender: AnyObject) {
        
        //println(QJoinObjects[sender.tag]["question"]!!)
        
        if contains(isUploading, QJoinObjects[sender.tag]["question"]!!.objectId!!) {
            
            displayAlert("Error", "These images are still uploading. Please try again shortly!", self)
            
        } else {
            
            displaySpinnerView(spinnerActive: true, UIBlock: true, theirQsSpinner, theirQsBlurView, "Zooming Images", self)
            
            //blockUI(true, theirQsSpinner, theirQsBlurView, self)
            
            questionToView = QJoinObjects[sender.tag]["question"]!! as? PFObject //self.questions[sender.tag]
            
            self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: sender)
            
            displaySpinnerView(spinnerActive: false, UIBlock: false, theirQsSpinner, theirQsBlurView, nil, self)
            
            //blockUI(false, self.theirQsSpinner, self.theirQsBlurView, self)
        }
    }
    
    
    // Function to process the casting of votes
    func castVote(questionId: Int, optionId: Int) {
        
        blockCheck = true

        var indPath = NSIndexPath(forRow: questionId, inSection: 0)
        self.tableView.beginUpdates()
        self.tableView.reloadRowsAtIndexPaths([indPath], withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
        
        var getQJoin = PFQuery(className: "QJoin")
        getQJoin.whereKey("question", equalTo: QJoinObjects[questionId]["question"]!! as! PFObject)
        getQJoin.includeKey("question")
        
        getQJoin.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            
            if error == nil {
                
                object!["question"]!.incrementKey("option\(optionId)Stats")
                object!["question"]!.saveEventually({ (success, error) -> Void in
                    
                    if error == nil {
                        
                        println("Successful vote cast in SocialQs!")
                    }
                })
                
                object?.setObject(optionId, forKey: "vote")
                object?.saveEventually({ (success, error) -> Void in
                    
                    if error == nil {
                        
                        println("Successful vote cast in QJoin!")
                    }
                })
                
                // Delay for one second to make vote process look smoother
                backgroundThread(delay: 1.0, completion: {
                    //var indexPath = NSIndexPath(forRow: questionId, inSection: 0)
                    self.tableView.beginUpdates()
                    self.tableView.reloadRowsAtIndexPaths([indPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    self.tableView.endUpdates()
                })
            }
        }
    }
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = self.QJoinObjects[indexPath.row]["question"]!! as? PFObject
            
            self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
            
            self.tableView.setEditing(false, animated: true)
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
            
            let object = self.QJoinObjects[indexPath.row] as! PFObject
            
            object["askeeDeleted"] = true
            
            object.unpinInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    println("question unpinned")
                    
                    object.saveEventually({ (success, error) -> Void in
                        
                        if error == nil {
                            
                            println("Question updated to be labeled as deleted")
                            
                        } else {
                            
                            println("There was an error updating the question as deleted:")
                            println(error)
                        }
                    })
                    
                } else {
                    
                    println("There was an error unpinning the question:")
                    println(error)
                }
            })
            
            self.QJoinObjects.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
        trash.backgroundColor = UIColor.redColor()
        
        
        println("Swiped THEIR row: \(indexPath.row)")
        
        if self.QJoinObjects[indexPath.row]["vote"] != nil {
            
            return [trash, view] // Order = appearance order, right to left on screen
            
        } else {
            
            return [trash] // Order = appearance order, right to left on screen
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    // Swipe to display options functions ----------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PUSH - Set up the reload to trigger off the push for "reloadTable"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "reloadTheirTable", object: nil)
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg3.png"))
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        // Set separator color
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Adjust top and bottom bounds of table for nav and tab bars
        //self.tableView.contentInset = UIEdgeInsetsMake(64,0,52,0)  // T, L, B, R
        
        // Disable auto inset adjust
        //self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QJoinObjects.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = QsTheirCell()
        
        cell = tableView.dequeueReusableCellWithIdentifier("theirCell", forIndexPath: indexPath) as! QsTheirCell
        
        cell.option1Container.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        cell.option1Container.layer.cornerRadius = 10.0 // cell.option1Container.frame.size.height/2
        cell.option1Container.layer.borderWidth = 2.0
        cell.option1Container.layer.borderColor = UIColor.whiteColor().CGColor
        
        cell.option2Container.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        cell.option2Container.layer.cornerRadius = 10.0 // cell.option1Container.frame.size.height/2
        cell.option2Container.layer.borderWidth = 2.0
        cell.option2Container.layer.borderColor = UIColor.whiteColor().CGColor
        
        if blockCheck == true {
            
            // Overlay spinner/voting message
            var boxView = UIView()
            var blurView = globalBlurView()
            displayCellSpinnerView(boxView, blurView, "Casting Vote", cell)
            
            blockCheck = false
        }
        
        // Compute number of reponses and option stats
        var totalResponses = (self.QJoinObjects[indexPath.row]["question"]!!["option1Stats"] as! Int) + (QJoinObjects[indexPath.row]["question"]!!["option2Stats"] as! Int)
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            option1Percent = Float((self.QJoinObjects[indexPath.row]["question"]!!["option1Stats"] as! Int))/Float(totalResponses)*100
            option2Percent = Float((self.QJoinObjects[indexPath.row]["question"]!!["option2Stats"] as! Int))/Float(totalResponses)*100
        }
        
        // Display question photo
        if let questionPhotoThumb = self.QJoinObjects[indexPath.row]["question"]!!["questionPhotoThumb"] as? PFFile {
            
            getImageFromPFFile(questionPhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.questionImage.setImage(image, forState: UIControlState.Normal)
                    
                } else {
                    
                    println("There was an error downloading a questionPhoto")
                }
            })
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            cell.questionImage.contentMode = UIViewContentMode.ScaleAspectFill
            cell.questionImage.clipsToBounds = true
            cell.questionImage.layer.cornerRadius = cell.questionImage.frame.size.height/2
            
            // Set question text width
            cell.questionTextRightSpace.constant = cell.questionImage.frame.size.width + 12
            cell.questionText.layoutIfNeeded()
            
            cell.questionImage.hidden = false
//            cell.questionZoom.enabled = true
            
        } else {
            
            // Set question text width
            cell.questionTextRightSpace.constant = 8
            cell.questionText.layoutIfNeeded()
            
            cell.questionImage.hidden = true
//            cell.questionZoom.enabled = false
        }
        
        // Display option1 photo
        var option1Offset: CGFloat = 20.0
        if let option1PhotoThumb = self.QJoinObjects[indexPath.row]["question"]!!["option1PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option1PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.option1Image.setImage(image, forState: UIControlState.Normal)
                    
                } else {
                    
                    println("There was an error downloading an option1Photo")
                }
            })
            
            // Set option1 text width
            cell.option1TextLeftSpace.constant = cell.option1Image.frame.size.width + 14
            cell.option1Text.layoutIfNeeded()
            
            cell.option1Image.hidden = false
//            cell.option1Zoom.enabled = true
            
            option1Offset = 80
            
        } else {
            
            // Set question text width
            cell.option1TextLeftSpace.constant = 14
            cell.option1Text.layoutIfNeeded()
            
            cell.option1Image.hidden = true
//            cell.option1Zoom.enabled = false
        }
        
        // Format thumbnail views - aspect fill without breaching imageView bounds
        cell.option1Image.contentMode = UIViewContentMode.ScaleAspectFill
        cell.option1Image.clipsToBounds = true
        cell.option1Image.layer.cornerRadius = 10 // cell.option1Image.frame.size.height/2
        
        // Display option2 photo
        var option2Offset: CGFloat = 20.0
        if let option2PhotoThumb = self.QJoinObjects[indexPath.row]["question"]!!["option2PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option2PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.option2Image.setImage(image, forState: UIControlState.Normal)
                    
                } else {
                    
                    println("There was an error downloading an option2Photo")
                }
            })
            
            // Set option2 text width
            cell.option2TextLeftSpace.constant = cell.option2Image.frame.size.width + 14
            cell.option2Text.layoutIfNeeded()
            
            cell.option2Image.hidden = false
//            cell.option2Zoom.enabled = true
            
            option2Offset = 80
            
        } else {
            
            // Set question text width
            cell.option2TextLeftSpace.constant = 14
            cell.option2Text.layoutIfNeeded()
            
            cell.option2Image.hidden = true
//            cell.option2Zoom.enabled = false
            
        }// Build "repsonse" string to account for singular/plural
        var resp = "responses"
        if totalResponses == 1 { resp = "response" }
        
        let maxBarWidth = cell.questionBackground.frame.size.width
        var width1: CGFloat = 0
        var width2: CGFloat = 0
        
        if option1Percent > option2Percent {
            
            width1 = maxBarWidth
            width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100))) + option1Offset
            cell.option1Background.backgroundColor = winColor
            cell.option2Background.backgroundColor = loseColor
            
        } else if option2Percent > option1Percent {
            
            width2 = maxBarWidth
            width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100))) + option2Offset
            cell.option1Background.backgroundColor = loseColor
            cell.option2Background.backgroundColor = winColor
            
        } else {
            
            width1 = maxBarWidth
            width2 = maxBarWidth
            cell.option1Background.backgroundColor = UIColor.groupTableViewBackgroundColor()
            cell.option2Background.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
        
        // Animate stats bars
        if totalResponses == 0 {
            
            //cell.progress1RightSpace.constant = cell.frame.size.width/2 - 16 // questionBackground.frame.size.width - cell.questionBackground.frame.size.width/2
            cell.option1Background.alpha = 0.0
            cell.option1Background.layoutIfNeeded()
            
            //cell.progress2RightSpace.constant = cell.frame.size.width/2 - 16 // cell.questionBackground.frame.size.width - cell.questionBackground.frame.size.width/2
            cell.option2Background.alpha = 0.0
            cell.option2Background.layoutIfNeeded()
            
        } else {
            
            cell.progress1RightSpace.constant = cell.frame.size.width/2 - 16 // questionBackground.frame.size.width - cell.questionBackground.frame.size.width/2
            cell.option1Background.alpha = 0.0
            cell.option1Background.layoutIfNeeded()
            
            cell.progress2RightSpace.constant = cell.frame.size.width/2 - 16 // cell.questionBackground.frame.size.width - cell.questionBackground.frame.size.width/2
            cell.option2Background.alpha = 0.0
            cell.option2Background.layoutIfNeeded()
            
            UIView.animateWithDuration(0.75, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                cell.option1Background.alpha = 0.6
                cell.option1Background.layoutIfNeeded()
                
                cell.option2Background.alpha = 0.6
                cell.option2Background.layoutIfNeeded()
                
                }) { (isFinished) -> Void in }
            
            UIView.animateWithDuration(1.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                cell.progress1RightSpace.constant = cell.questionBackground.frame.size.width - width1 - 8
                cell.option1Background.layoutIfNeeded()
                
                cell.progress2RightSpace.constant = cell.questionBackground.frame.size.width - width2 - 8
                cell.option2Background.layoutIfNeeded()
                
                }) { (isFinished) -> Void in }
        }
        
        // Format thumbnail views - aspect fill without breaching imageView bounds
        cell.option2Image.contentMode = UIViewContentMode.ScaleAspectFill
        cell.option2Image.clipsToBounds = true
        cell.option2Image.layer.cornerRadius = 10 // cell.option2Image.frame.size.height/2
        
        // Display text
        if let questionText = self.QJoinObjects[indexPath.row]["question"]!!["questionText"] as? String {
            
            cell.questionText.text = questionText
            cell.questionText.numberOfLines = 0 // Dynamic number of lines
            cell.questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.questionText.sizeToFit()
            
        } else {
            
            cell.questionText.text = ""
        }
        cell.questionBackground.layer.cornerRadius = cell.questionBackground.frame.size.height/2
        cell.questionBackground.backgroundColor = mainColorBlue
        
        if let option1Text = self.QJoinObjects[indexPath.row]["question"]!!["option1Text"] as? String {
            if totalResponses > 0 {
                cell.option1Text.text = option1Text + "  \(Int(option1Percent))%"
            } else {
                cell.option1Text.text = option1Text
            }
//            cell.option1Text.numberOfLines = 0 // Dynamic number of lines
//            cell.option1Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        } else {
            if totalResponses > 0 {
                cell.option1Text.text = "\(Int(option1Percent))%"
            } else {
                cell.option1Text.text = ""
            }
        }
        cell.option1Background.layer.cornerRadius = 10 // cell.option1VoteButton.frame.size.height/2
        
        
        if let option2Text = self.QJoinObjects[indexPath.row]["question"]!!["option2Text"] as? String {
            if totalResponses > 0 {
                cell.option2Text.text = option2Text  + "  \(100 - Int(option1Percent))%"
            } else {
                cell.option2Text.text = option2Text
            }
//            cell.option2Label.numberOfLines = 0 // Dynamic number of lines
//            cell.option2Label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            
        } else {
            if totalResponses > 0 {
                cell.option2Text.text = "\(100 - Int(option1Percent))%"
            } else {
                cell.option2Text.text = ""
            }
        }
        cell.option2Background.layer.cornerRadius = 10 // cell.option2VoteButton.frame.size.height/2
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set all text
//        cell.question.numberOfLines = 0 // Dynamic number of lines
//        cell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        cell.numberOfResponses.text = "\(totalResponses) \(resp)"
        
        // Tag buttons
//        cell.option1Zoom.tag  = indexPath.row
//        cell.option2Zoom.tag  = indexPath.row
//        cell.questionZoom.tag = indexPath.row
        
        // Format cell backgrounds
        cell.backgroundColor = UIColor.clearColor()
        
        // Profile Pic
        if (QJoinObjects[indexPath.row]["question"]!!["asker"]!!["profilePicture"] as? PFFile != nil) {
            
            getImageFromPFFile(QJoinObjects[indexPath.row]["question"]!!["asker"]!!["profilePicture"]!! as! PFFile, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.profilePicture.image = image
                }
            })
        }
        cell.profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
        cell.profilePicture.layer.masksToBounds = false
        cell.profilePicture.clipsToBounds = true
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width/2
        
        // Set askername
        cell.username.text = QJoinObjects[indexPath.row]["question"]!!["asker"]!!["username"] as? String
        
        if let myVote = QJoinObjects[indexPath.row]["vote"] as? Int {
            
//            // Set myVote selector
//            if myVote == 1 {
//                
//            } else if myVote == 2 {
//                
//            }
            
        } else {
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
//            let gesture1 = UIPanGestureRecognizer(target: self, action: Selector("wasDragged1:"))
//            cell.option1Image.addGestureRecognizer(gesture1)
//            cell.option1Image.userInteractionEnabled = true
//            
//            currentCell = indexPath.row
//            
//            let gesture2 = UIPanGestureRecognizer(target: self, action: Selector("wasDragged2:"))
//            cell.option2Image.addGestureRecognizer(gesture2)
//            cell.option2Image.userInteractionEnabled = true
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
        
        return cell
    }
    
    
    func wasDragged1(gesture: UIPanGestureRecognizer) {
        
        println(currentCell)
        
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        let option1TopSpace: CGFloat = 101.5
        
        label.center = CGPoint(x: option1Offset + translation.x, y: option1TopSpace)//self.view.bounds.height / 2)// + translation.y)
        
        let xFromCenter = label.center.x - self.view.frame.size.width / 2
        //        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransformMakeRotation(0)
        var stretch = CGAffineTransformScale(rotation, 1, 1)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var endX: CGFloat = 0.0
            
            if xFromCenter <= 0 {
                endX = label.frame.width/2 + 8
            } else {
                endX = self.view.frame.width - label.frame.width/2 - 8
            }
            
            option1Offset = endX
            
            //            rotation = CGAffineTransformMakeRotation(0)
            //            stretch = CGAffineTransformScale(rotation, 1, 1)
            //            label.transform = stretch
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                label.center = CGPoint(x: endX, y: option1TopSpace)//self.view.bounds.height / 2)
                
            }, completion: { (isFinished) -> Void in })
        }
    }
    func wasDragged2(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        let option2TopSpace: CGFloat = 164.0
        
        label.center = CGPoint(x: option2Offset + translation.x, y: option2TopSpace)//self.view.bounds.height / 2)// + translation.y)
        
        let xFromCenter = label.center.x - self.view.frame.size.width / 2
        //        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransformMakeRotation(0)
        var stretch = CGAffineTransformScale(rotation, 1, 1)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var endX: CGFloat = 0.0
            
            if xFromCenter <= 0 {
                endX = label.frame.width/2 + 8
            } else {
                endX = self.view.frame.width - label.frame.width/2 - 8
            }
            
            option2Offset = endX
            
            //            rotation = CGAffineTransformMakeRotation(0)
            //            stretch = CGAffineTransformScale(rotation, 1, 1)
            //            label.transform = stretch
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                label.center = CGPoint(x: endX, y: option2TopSpace)//self.view.bounds.height / 2)
                
            }, completion: { (isFinished) -> Void in })
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        // **********************************************************************************************
        // Manually call refresh upon loading to get most up to datest datas
        // - this needs to be skipped when push is allowed and used when push has been declined
        //if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
        
        if returningFromSettings == false && returningFromPopover == false {
            
            println("Page loaded from tab bar")
            
            topOffset = 64
            
            refresh()
            
        }
        
        if returningFromPopover {
            
            println("Returned from popover")
            
            returningFromPopover = false
            
            if theirViewReturnedOnce == false {
                theirViewReturnedOnce = true
                topOffset = 0
            } else {
                topOffset = 64
            }
            
        }
        
        if returningFromSettings {
            
            println("Returned from settings")
            
            returningFromSettings = false
            
            topOffset = 0
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(topOffset,0,52,0)  // T, L, B, R
        
        //    println("USER IS NOT SUBSCRIBED TO RELOADTHEIRTABLE")
        //}
        // **********************************************************************************************
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        QJoinObjects.removeAll(keepCapacity: true)
        
        var qJoinQueryLocal = PFQuery(className: "QJoin")
        qJoinQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!.username!)
        qJoinQueryLocal.orderByDescending("createdAt")
        qJoinQueryLocal.whereKey("askeeDeleted", equalTo: false)
        qJoinQueryLocal.limit = 1000
        qJoinQueryLocal.includeKey("question")
        qJoinQueryLocal.includeKey("asker")
        qJoinQueryLocal.fromLocalDatastore()
        
        qJoinQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            var alreadyRetrieved = [String]()
            
            if error == nil {
                
                self.QJoinObjects = objects!
                
                // Reload table data
                self.tableView.reloadData()
                
                // Kill refresher when query finished
                self.refresher.endRefreshing()
                
                for temp in objects! {
                    if temp.objectId! != nil {
                        alreadyRetrieved.append(temp.objectId!!)
                    }
                }
                
            } else {
                
                println("There was an error loading Qs from local data store:")
                println(error)
            }
            
            // Get Qs that are not in localdata store
            var qJoinQueryServer = PFQuery(className: "QJoin")
            qJoinQueryServer.whereKey("to", equalTo: PFUser.currentUser()!.username!)
            qJoinQueryServer.whereKey("objectId", notContainedIn: alreadyRetrieved)
            qJoinQueryServer.orderByDescending("createdAt")
            qJoinQueryServer.limit = 1000
            qJoinQueryServer.includeKey("question")
            qJoinQueryServer.includeKey("asker")
            
            qJoinQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error == nil {
                    
                    // Append to local array of PFObjects
                    self.QJoinObjects = self.QJoinObjects + objects!
                    
                    // Reload table data
                    self.tableView.reloadData()
                    
                    // Pin new Qs to local datastore
                    if let temp = objects as? [PFObject] {
                        
                        for object in temp {
                            
                            object.pinInBackgroundWithBlock { (success, error) -> Void in
                                
                                if error == nil {
                                    
                                    println("Their Qs QJoin Object \(object.objectId!) pinned!")
                                }
                            }
                        }
                        
                        // Reload table data
                        self.tableView.reloadData()
                    }
                    
                } else {
                    
                    println("There was an error retrieving new Qs from the database:")
                    println(error)
                    
                    // Reload table data
                    self.tableView.reloadData()
                    
                    // Kill refresher when query finished
                    self.refresher.endRefreshing()
                }
            })
        }
        
        
        
        
        
        
        
//        // Get list of Qs to pull from UserQs
//        var userQsQuery = PFQuery(className: "UserQs")
//
//        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
//            
//            if error != nil {
//                
//                println("Error accessing UserQs/theirQsId")
//                println(error)
//                
//            } else {
//                
//                if let theirQs = userQsObjects!["theirQsId"] as? [String] {
//                    
//                    // Pull Qs with Id in pullIds
//                    var getSocialQsQuery = PFQuery(className: "SocialQs")
//                    
//                    // Sort by newest created-date first
//                    getSocialQsQuery.orderByDescending("createdAt")
//                    
//                    // Get only theirQs that user hasn't deleted
//                    getSocialQsQuery.whereKey("objectId", containedIn: theirQs)
//                    
//                    // Set query limit to max
//                    getSocialQsQuery.limit = 1000
//                    
//                    // Pull data
//                    getSocialQsQuery.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
//                        
//                        if let questionTemp = questionObjects {
//                            
//                            self.questions.removeAll(keepCapacity: true)
//                            self.questionIds.removeAll(keepCapacity: true)
//                            self.questionsPhoto.removeAll(keepCapacity: true)
//                            self.option1s.removeAll(keepCapacity: true)
//                            self.option2s.removeAll(keepCapacity: true)
//                            self.option1sPhoto.removeAll(keepCapacity: true)
//                            self.option2sPhoto.removeAll(keepCapacity: true)
//                            self.option1Stats.removeAll(keepCapacity: true)
//                            self.option2Stats.removeAll(keepCapacity: true)
//                            self.askers.removeAll(keepCapacity: true)
//                            //self.askerPhotos.removeAll(keepCapacity: true)
//                            self.configuration.removeAll(keepCapacity: true)
//                            self.votesId.removeAll(keepCapacity: true)
//                            self.photosId.removeAll(keepCapacity: true)
//                            
//                            for questionObject in questionTemp {
//                                
//                                var tempConfig = ""
//                                
//                                self.questionIds.append(questionObject.objectId!!)
//                                
//                                // ---- DOWNLOAD AND STORE QUESTION DATA -------------------------------
//                                // Check for photo AND text Q
//                                if (questionObject["question"] as? String != nil) && (questionObject["questionPhoto"] as? PFFile != nil) {
//                                    
//                                    self.questions.append(questionObject["question"] as! String)
//                                    self.questionsPhoto.append(questionObject["questionPhoto"] as? PFFile)
//                                    tempConfig = "1"
//                                    
//                                // Check for photo and NO text
//                                } else if (questionObject["questionPhoto"] as? PFFile != nil)  && (questionObject["question"] as? String == nil){
//                                    
//                                    self.questions.append("")
//                                    self.questionsPhoto.append(questionObject["questionPhoto"] as? PFFile)
//                                    tempConfig = "2"
//                                    
//                                // Text and NO photo
//                                } else {
//                                    
//                                    self.questions.append(questionObject["question"] as! String)
//                                    self.questionsPhoto.append(nil)
//                                    tempConfig = "3"
//                                }
//                                // ---------------------------------------------------------------------
//                                
//                                
//                                // ---- DOWNLOAD AND STORE OPTION 1 DATA -------------------------------
//                                // Check for photo AND text Q
//                                if (questionObject["option1"] as? String != nil) && (questionObject["option1Photo"] as? PFFile != nil) {
//                                    
//                                    self.option1s.append(questionObject["option1"] as! String)
//                                    self.option1sPhoto.append(questionObject["option1Photo"] as? PFFile)
//                                    tempConfig = tempConfig + "a"
//                                    
//                                    // Check for photo and NO text
//                                } else if (questionObject["option1Photo"] as? PFFile != nil)  && (questionObject["option1"] as? String == nil){
//                                    
//                                    self.option1s.append("")
//                                    self.option1sPhoto.append(questionObject["option1Photo"] as? PFFile)
//                                    tempConfig = tempConfig + "b"
//                                    
//                                } else { // Text and NO photo
//                                    
//                                    self.option1s.append(questionObject["option1"] as! String)
//                                    self.option1sPhoto.append(nil)
//                                    tempConfig = tempConfig + "c"
//                                    
//                                }
//                                // ---------------------------------------------------------------------
//                                
//                                
//                                // ---- DOWNLOAD AND STORE OPTION 2 DATA -------------------------------
//                                // Check for photo AND text Q
//                                if (questionObject["option2"] as? String != nil) && (questionObject["option2Photo"] as? PFFile != nil) {
//                                    
//                                    self.option2s.append(questionObject["option2"] as! String)
//                                    self.option2sPhoto.append(questionObject["option2Photo"] as? PFFile)
//                                    //                                    tempConfig = tempConfig + "x"
//                                    
//                                    // Check for photo and NO text
//                                } else if (questionObject["option2Photo"] as? PFFile != nil)  && (questionObject["option2"] as? String == nil){
//                                    
//                                    self.option2s.append("")
//                                    self.option2sPhoto.append(questionObject["option2Photo"] as? PFFile)
//                                    //                                    tempConfig = tempConfig + "y"
//                                    
//                                } else { // Text and NO photo
//                                    
//                                    self.option2s.append(questionObject["option2"] as! String)
//                                    self.option2sPhoto.append(nil
//                                    )
//                                    //                                    tempConfig = tempConfig + "z"
//                                    
//                                }
//                                // ---------------------------------------------------------------------
//                                
//                                self.configuration.append(tempConfig)
//                                
//                                // ---- DOWNLOAD AND STORE STATS DATA ----------------------------------
//                                self.option1Stats.append(questionObject["stats1"] as! Int)
//                                self.option2Stats.append(questionObject["stats2"] as! Int)
//                                
//                                // ---- DOWNLOAD AND STORE VOTESID DATA ----------------------------------
//                                self.votesId.append(questionObject["votesId"] as! String)
//                                
//                                // ---- DOWNLOAD AND STORE PHOTOSID DATA ----------------------------------
//                                if let test = questionObject["photosId"] as? String {
//                                    self.photosId.append(questionObject["photosId"] as! String)
//                                } else {
//                                    self.photosId.append("")
//                                }
//                                
//                                self.askers.append(questionObject["askername"] as! String)
//                                
//                            }
//                            
//                            // Ensure all queries have completed THEN get askerPhotos
//                            if self.questionsPhoto.count == self.questions.count {
//                                
//                                // Get profile pictures with code block, then update table
//                                self.getProfilePictures() { (complete: Bool) in
//                                    
//                                    // Reload table data
//                                    self.tableView.reloadData()
//                                    
//                                    // Kill refresher when query finished
//                                    self.refresher.endRefreshing()
//                                }
//                            }
//                        }
//                    }
//                    
//                } else {
//                    
//                    // NO Qs
//                    
//                }
//            }
//        })
    }
    
    
//    func getProfilePictures(completion: (complete: Bool) -> Void) {
//        
//        // CHANGE THIS!! Shouldn't have to rebuild this each time *********************************************************************************************************
//        askerPhotos.removeAll(keepCapacity: true)
//        // CHANGE THIS!! **************************************************************************************************************************************************
//        
//        // Download asker profile picture
//        var pictureQuery = PFQuery(className: "_User")
//        pictureQuery.whereKey("username", containedIn: askers)
//        pictureQuery.findObjectsInBackgroundWithBlock({ (pictureObjects, error) -> Void in
//            
//            if error == nil {
//                
//                if let temp = pictureObjects {
//                    
//                    let numberOfObjects = temp.count
//                    var count = 0
//                    
//                    for pictureObject in temp {
//                        
//                        var askername = pictureObject["username"] as! String
//                        
//                        if let pic = pictureObject["profilePicture"] as? PFFile {
//                            
//                            if let test = self.askerPhotos[askername] {
//                                // entry exists in dictionary
//                                
//                            } else {
//                                
//                                pic.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                                    
//                                    if error != nil {
//                                        
//                                        println("Error retrieving and setting askerPhoto")
//                                        println(error)
//                                        
//                                        count++
//                                        
//                                        if count == numberOfObjects {
//                                            
//                                            completion(complete: true)
//                                        }
//                                        
//                                    } else {
//                                        
//                                        if let downloadedImage = UIImage(data: data!) {
//                                            
//                                            self.askerPhotos[askername] = downloadedImage
//                                            
//                                        }
//                                        
//                                        count++
//                                        
//                                        if count == numberOfObjects {
//                                            
//                                            completion(complete: true)
//                                        }
//                                    }
//                                })
//                            }
//                            
//                        } else {
//                            
//                            // No PFFile image available
//                            count++
//                            
//                            if count == numberOfObjects {
//                                
//                                completion(complete: true)
//                            }
//                        }
//                    }
//                }
//                
//            } else {
//                
//                println("Profile Picture download failed")
//                println(error)
//            }
//        })
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
