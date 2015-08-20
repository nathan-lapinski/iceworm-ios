//
//  QsMyTableVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/15/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsMyTableVC: UITableViewController {
    
    var questionObjects: [AnyObject] = []
    
    var refresher: UIRefreshControl!
//    var myQsSpinner = UIActivityIndicatorView()
//    var myQsBlurView = globalBlurView()
    var myQsSpinner = UIView()
    var myQsBlurView = globalBlurView()
    
    @IBAction func zoomQButton(sender: AnyObject) {
        
        zoomPage = 0
        setPhotosToZoom(sender)
    }
    
    @IBAction func zoom1ButtonAction(sender: AnyObject) {
        
        zoomPage = 0
        
        if (questionObjects[sender.tag]["questionPhoto"] as? PFFile != nil) { zoomPage++ }
        
        setPhotosToZoom(sender)
    }
    
    @IBAction func zoom2ButtonAction(sender: AnyObject) {
        
        zoomPage = 0
        
        if (questionObjects[sender.tag]["questionPhoto"] as? PFFile != nil) { zoomPage++ }
        if (questionObjects[sender.tag]["option1Photo"]  as? PFFile != nil) { zoomPage++ }
        
        setPhotosToZoom(sender)
    }
    

    func setPhotosToZoom(sender: AnyObject) {
        
        if contains(isUploading, questionObjects[sender.tag].objectId!!) {
            
            displayAlert("Error", "These images are still uploading. Please try again shortly!", self)
            
        } else {
            
            displaySpinnerView(spinnerActive: true, UIBlock: true, myQsSpinner, myQsBlurView, "Zooming Image", self)
            
            //blockUI(true, myQsSpinner, myQsBlurView, self)
            
            questionToView = questionObjects[sender.tag] as? PFObject //self.questions[sender.tag]
            
            displaySpinnerView(spinnerActive: false, UIBlock: false, myQsSpinner, myQsBlurView, nil, self)
        
            //blockUI(false, self.myQsSpinner, self.myQsBlurView, self)
            
            self.performSegueWithIdentifier("zoomMyPhotoSegue", sender: sender)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh upon first load of controller
        refresh()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg3.png"))
        //self.tableView.backgroundColor = UIColor.lightGrayColor()
        
        // Set separator color
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        if returningFromSettings == false && returningFromPopover == false {
            
            println("Page loaded from tab bar")
            
            topOffset = 64
            
            refresh()
        }
        
        if returningFromPopover {
            
            println("Returned from popover")
            
            returningFromPopover = false
            
            if myViewReturnedOnce == false {
                myViewReturnedOnce = true
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
    }
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        println(questionObjects[indexPath.row])
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = self.questionObjects[indexPath.row] as? PFObject
            
            self.performSegueWithIdentifier("viewVotesMyQs", sender: self)
            
            // Change setEditing to cause swipe to reset
            // Their Qs does this on its own, but nicer (when the page
            // isn't visible - idk why this page doesn't... =/
            // (it used to...??)
            self.tableView.setEditing(false, animated: true)
            
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Trash") { (action, index) -> Void in
            
            let object = self.questionObjects[indexPath.row] as! PFObject
            
            object["askerDeleted"] = true
            
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
            
            self.questionObjects.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
        trash.backgroundColor = UIColor.redColor()
        
        println("Swiped MY row: \(indexPath.row)")
        
        if ((questionObjects[indexPath.row]["option1Stats"]! as! Int) + (questionObjects[indexPath.row]["option2Stats"]! as! Int)) > 0 {
            return [trash, view] // Order = appearance order, right to left on screen
        } else {
            return [trash]
        }
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        var myQsQueryLocal = PFQuery(className: "SocialQs")
        
        myQsQueryLocal.fromLocalDatastore()
        myQsQueryLocal.whereKey("asker", equalTo: PFUser.currentUser()!)
        myQsQueryLocal.whereKey("askerDeleted", equalTo: false)
        myQsQueryLocal.orderByDescending("createdAt")
        myQsQueryLocal.limit = 1000
        
        myQsQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                var qIds = [String]()
                
                self.questionObjects = objects!
                
                for temp in objects! {
                    
                    qIds.append(temp.objectId!!)
                }
                
                println(qIds)
                
                var myQsQueryServer = PFQuery(className: "SocialQs")
                myQsQueryServer.whereKey("asker", equalTo: PFUser.currentUser()!)
                myQsQueryServer.whereKey("askerDeleted", equalTo: false)
                myQsQueryServer.whereKey("objectId", notContainedIn: qIds)
                myQsQueryServer.orderByDescending("createdAt")
                myQsQueryServer.limit = 1000
                
                myQsQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        
                        // Append to local array of PFObjects
                        self.questionObjects = self.questionObjects + objects!
                        
                        if let temp = objects {
                            
                            for object in temp {
                                
                                (object as! PFObject).pinInBackgroundWithBlock { (success, error) -> Void in
                                    
                                    println("Object \(object.objectId) pinned!")
                                }
                            }
                        }
                        
                        self.tableView.reloadData()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                    }
                })
                
            } else {
                
                println("There was an error loading Qs from local data store:")
                println(error)
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return questionObjects.count }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Compute number of reponses and option stats
        var totalResponses = (self.questionObjects[indexPath.row]["option1Stats"] as! Int) + (self.questionObjects[indexPath.row]["option2Stats"] as! Int)
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            option1Percent = Float((self.questionObjects[indexPath.row]["option1Stats"] as! Int))/Float(totalResponses)*100
            option2Percent = Float((self.questionObjects[indexPath.row]["option2Stats"] as! Int))/Float(totalResponses)*100
        }
        
        // Build "repsonse" string to account for singular/plural
        var resp = "responses"
        if totalResponses == 1 { resp = "response" }
        
        var cell = QsMyCell()
        cell = tableView.dequeueReusableCellWithIdentifier("myCell2", forIndexPath: indexPath) as! QsMyCell
        
        let maxBarWidth = cell.option1BackgroundImage.frame.size.width
        var width1: CGFloat = 0
        var width2: CGFloat = 0
        
        if option1Percent > option2Percent {
            
            width1 = maxBarWidth
            width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
            cell.progress1.backgroundColor = winColor
            cell.progress2.backgroundColor = loseColor
            
        } else if option2Percent > option1Percent {
            
            width2 = maxBarWidth
            width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
            cell.progress1.backgroundColor = loseColor
            cell.progress2.backgroundColor = winColor
            
        } else {
            
            width1 = maxBarWidth
            width2 = maxBarWidth
            cell.progress1.backgroundColor = winColor
            cell.progress2.backgroundColor = winColor
        }
        
        // Animate stats bars
        if totalResponses == 0 {
            
            cell.progress1.hidden = true
            cell.progress2.hidden = true
            
        } else {
            
            cell.progress1.hidden = false
            cell.progress2.hidden = false
            cell.progress1RightSpace.constant = cell.option1BackgroundImage.frame.size.width - cell.option1BackgroundImage.frame.size.width/2
            cell.progress1.alpha = 0.0
            cell.progress1.layoutIfNeeded()
            cell.progress2RightSpace.constant = cell.option1BackgroundImage.frame.size.width - cell.option1BackgroundImage.frame.size.width/2
            cell.progress2.alpha = 0.0
            cell.progress2.layoutIfNeeded()
            
            UIView.animateWithDuration(0.75, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                cell.progress1.alpha = 1.0
                cell.progress1.layoutIfNeeded()
                cell.progress2.alpha = 1.0
                cell.progress2.layoutIfNeeded()
                
                }) { (isFinished) -> Void in }
            
            UIView.animateWithDuration(1.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                cell.progress1RightSpace.constant = cell.option1BackgroundImage.frame.size.width - width1 + 8
                cell.progress1.layoutIfNeeded()
                cell.progress2RightSpace.constant = cell.option2BackgroundImage.frame.size.width - width2 + 8
                cell.progress2.layoutIfNeeded()
                
                }) { (isFinished) -> Void in }
        }
        
        // Display question photo
        if let questionPhotoThumb = self.questionObjects[indexPath.row]["questionPhotoThumb"] as? PFFile {
            
            getImageFromPFFile(questionPhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.questionImage.image = image
                    
                } else {
                    
                    println("There was an error downloading a questionPhoto")
                }
            })
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            cell.question.contentMode = UIViewContentMode.ScaleAspectFill
            cell.question.clipsToBounds = true
            cell.question.layer.cornerRadius = cornerRadius
            
            // Set question text width
            cell.questionTextRightSpace.constant = cell.questionImage.frame.size.width + 12
            cell.question.layoutIfNeeded()
            
            cell.question.hidden = false
            cell.question.enabled = true
            
        } else {
            
            // Set question text width
            cell.questionTextRightSpace.constant = 8
            cell.question.layoutIfNeeded()
            
            cell.questionImage.hidden = true
            cell.questionZoom.enabled = false
        }
        
        // Display option1 photo
        if let option1PhotoThumb = self.questionObjects[indexPath.row]["option1PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option1PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.option1Image.image = image
                    
                } else {
                    
                    println("There was an error downloading an option1Photo")
                }
            })
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            cell.option1Image.contentMode = UIViewContentMode.ScaleAspectFill
            cell.option1Image.clipsToBounds = true
            cell.option1Image.layer.cornerRadius = cornerRadius
            
            // Set option1 text width
            cell.option1TextLeftSpace.constant = cell.option1Image.frame.size.width + 12
            cell.option1BackgroundImage.layoutIfNeeded()
            
            cell.option1Image.hidden = false
            cell.option1Zoom.enabled = true
            
        } else {
            
            // Set question text width
            cell.option1TextLeftSpace.constant = 14
            cell.option1BackgroundImage.layoutIfNeeded()
            
            cell.option1Image.hidden = true
            cell.option1Zoom.enabled = false
        }
        
        // Display option2 photo
        if let option2PhotoThumb = self.questionObjects[indexPath.row]["option2PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option2PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    cell.option2Image.image = image
                    
                } else {
                    
                    println("There was an error downloading an option2Photo")
                }
            })
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            cell.option2Image.contentMode = UIViewContentMode.ScaleAspectFill
            cell.option2Image.clipsToBounds = true
            cell.option2Image.layer.cornerRadius = cornerRadius
            
            // Set option2 text width
            cell.option2TextLeftSpace.constant = cell.option2Image.frame.size.width + 12
            cell.option2BackgroundImage.layoutIfNeeded()
            
            cell.option2Image.hidden = false
            cell.option2Zoom.enabled = true
            
        } else {
            
            // Set question text width
            cell.option2TextLeftSpace.constant = 14
            cell.option2BackgroundImage.layoutIfNeeded()
            
            cell.option2Image.hidden = true
            cell.option2Zoom.enabled = false
        }
        
        
        // **** NEEDS STATS APPENDED!
        // Display text
        if let questionText = self.questionObjects[indexPath.row]["questionText"] as? String {
            
            cell.question.text = questionText
            cell.question.numberOfLines = 0 // Dynamic number of lines
            cell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.question.sizeToFit()
        }
        if let option1Text = self.questionObjects[indexPath.row]["option1Text"] as? String {
            
            cell.option1Label.text = option1Text + "  \(Int(option1Percent))%"
            cell.option1Label.numberOfLines = 0 // Dynamic number of lines
            cell.option1Label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        } else {
            
            cell.option1Label.text = "\(Int(option1Percent))%"
        }
        if let option2Text = self.questionObjects[indexPath.row]["option2Text"] as? String {
            
            cell.option2Label.text = option2Text  + "  \(100 - Int(option1Percent))%"
            cell.option2Label.numberOfLines = 0 // Dynamic number of lines
            cell.option2Label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        } else {
            
            cell.option2Label.text = "\(100 - Int(option1Percent))%"
        }
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set background image corners
        cell.background.layer.cornerRadius = cornerRadius
        
        // Format option backgrounds
        cell.option1BackgroundImage.layer.cornerRadius = cornerRadius
        cell.option2BackgroundImage.layer.cornerRadius = cornerRadius
        
        cell.numberOfResponses.text = "\(totalResponses) \(resp)"
//        cell.option1Label.text = option1String + "\(Int(option1Percent))%"
//        cell.option2Label.text = option2String + "\(Int(option2Percent))%"
        
        // Tag buttons
        cell.option1Zoom.tag  = indexPath.row
        cell.option2Zoom.tag  = indexPath.row
        cell.questionZoom.tag = indexPath.row
        
        // Format cell backgrounds
        cell.backgroundColor = UIColor.clearColor()
        
        // Disable appropriate vote buttons and vote checkmarks
        /*
        if let myVote = QJoinObjects[indexPath.row]["vote"] as? Int {
            
            cell.vote1Button.enabled = false
            cell.vote2Button.enabled = false
            
            // Set myVote selector
            if myVote == 1 {
                
                cell.myVote1.hidden = false
                cell.myVote1.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.5))
                cell.myVote2.hidden = true
            } else {
                
                cell.myVote2.hidden = false
                cell.myVote2.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.5))
                cell.myVote1.hidden = true
            }
            
        } else {
            
            cell.vote1Button.enabled = true
            cell.vote2Button.enabled = true
            cell.myVote1.hidden = true
            cell.myVote2.hidden = true
        }
        */
        
        return cell
    }
    
    
}
