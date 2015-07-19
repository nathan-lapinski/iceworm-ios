//
//  NEWMyQsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/15/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class NEWMyQsTableViewController: UITableViewController {
    
    var questions = [String]()
    var questionIds = [String]()
    var option1s = [String]()
    var option2s = [String]()
    var option1sPhoto = [PFFile]()
    var option2sPhoto = [PFFile]()
    var option1Stats = [Int]()
    var option2Stats = [Int]()
    //var deletedMyQuestions = [String]() // questions DELETED by current user
    var deletedMyStorageKey = myName + "deletedMyPermanent"
    var refresher: UIRefreshControl!
    //var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func zoom1ButtonAction(sender: AnyObject) {
        zoomPage = 0
        setPhotosToZoom(sender)
    }
    
    @IBAction func zoom2ButtonAction(sender: AnyObject) {
        zoomPage = 1
        setPhotosToZoom(sender)
    }
    
    
    func setPhotosToZoom(sender: AnyObject) {
        
        questionZoom = questions[sender.tag]
        
        option1sPhoto[sender.tag].getDataInBackgroundWithBlock({ (data1, error1) -> Void in
            
            if error1 != nil {
                
                println(error1)
                
            } else {
                
                if let downloadedImage = UIImage(data: data1!) {
                    
                    imageZoom[0] = downloadedImage
                    
                    self.option2sPhoto[sender.tag].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                        
                        if error2 != nil {
                            
                            println(error2)
                            
                        } else {
                            
                            if let downloadedImage = UIImage(data: data2!) {
                                
                                imageZoom[1] = downloadedImage
                                
                                self.performSegueWithIdentifier("zoomMyPhotoSegue", sender: sender)
                            }
                        }
                    })
                }
            }
        })
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
        //tableView.separatorColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(68,0,50,0)  // T, L, B, R
        
        // Disable auto inset adjust
        //self.automaticallyAdjustsScrollViewInsets = false
        
        //navigationController?.hidesBarsOnSwipe = true
    }
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
            requestedQId = self.questionIds[indexPath.row]
            
            if self.option1s[indexPath.row] == photoString {
                
                // Get images
                self.option1sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data1, error1) -> Void in
                    
                    if error1 != nil {
                        
                        println(error1)
                        
                    } else {
                        
                        if let downloadedImage = UIImage(data: data1!) {
                            
                            imageZoom[0] = downloadedImage
                        }
                    }
                })
                
                self.option2sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                    
                    if error2 != nil {
                        
                        println(error2)
                        
                    } else {
                        
                        if let downloadedImage = UIImage(data: data2!) {
                            
                            imageZoom[1] = downloadedImage
                        }
                    }
                })
            }
            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.performSegueWithIdentifier("viewVotesMyQs", sender: self)
                
            })
            
            // Change setEditing to cause swipe to reset
            // Their Qs does this on its own, but nicer (when the page
            // isn't visible - idk why this page doesn't... =/
            // (it used to...)
            self.tableView.setEditing(false, animated: true)
            
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Trash") { (action, index) -> Void in
            
            // Append qId to "deleted" array in database
            var deletedQuery = PFQuery(className: "UserQs")
            //deletedQuery.whereKey("objectId", equalTo: uQId)
            
            deletedQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
                
                if error == nil {
                    
                    // Add Q to deleted
                    userQsObjects!.addUniqueObject(self.questionIds[indexPath.row], forKey: "deletedMyQsId")
                    userQsObjects!.saveInBackground()
                    
                    // Remove Q from myQs (my active Qs)
                    userQsObjects!.removeObject(self.questionIds[indexPath.row], forKey: "myQsId")
                    userQsObjects!.saveInBackground()
                    
                    self.questionIds.removeAtIndex(indexPath.row)
                    self.questions.removeAtIndex(indexPath.row)
                    self.option1s.removeAtIndex(indexPath.row)
                    self.option2s.removeAtIndex(indexPath.row)
                    self.option1sPhoto.removeAtIndex(indexPath.row)
                    self.option2sPhoto.removeAtIndex(indexPath.row)
                    self.option1Stats.removeAtIndex(indexPath.row)
                    self.option2Stats.removeAtIndex(indexPath.row)
                    
                    tableView.beginUpdates()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.endUpdates()
                    
                } else {
                    
                    println("Error adding qId to UserQs/deletedMyQsId")
                }
            })
        }
        trash.backgroundColor = UIColor.redColor()
        
        println(indexPath.row)
        println(option1Stats.count)
        println(option2Stats.count)
        
        if (option1Stats[indexPath.row] + option2Stats[indexPath.row]) > 0 {
            return [trash, view] // Order = appearance order, right to left on screen
        } else {
            return [trash]
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
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        
        // Recall deleted/dismissed data
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedMyStorageKey) != nil {
        
        deletedMyQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedMyStorageKey)! as! [(String)]
        }
        
        
        // **********************************************************************************************
        // Manually call refresh upon loading to get most up to datest datas
        // - this needs to be skipped when push is allowed and used when push has been declined
        //if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false { refresh() }
        
        // REMOVE LATER!!! ::
        
        if returningFromPopover == false {
            returningFromPopover = true
            refresh()
        }
        
        // **********************************************************************************************
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        // Get list of Qs to pull from UserQs
        var getMyQsQuery = PFQuery(className: "UserQs")
        getMyQsQuery.getObjectInBackgroundWithId(uQId, block: { (myQsObjects, error) -> Void in
            
            if error != nil {
                
                println("Error accessing UserQs/theirQsId")
                println(error)
                
            } else {
                
                if let myQs = myQsObjects!["myQsId"] as? [String] {
                    
                    // Get Qs from SocialsQs based on myQsId
                    var getSocialQsQuery = PFQuery(className: "SocialQs")
                    
                    // Sort by newest created-date first
                    getSocialQsQuery.orderByDescending("createdAt")
                    
                    // Filter off Qs I've deleted from my view
                    getSocialQsQuery.whereKey("objectId", containedIn: myQs)
                    
                    // Set query limit to max
                    getSocialQsQuery.limit = 1000
                    
                    // Pull objects
                    getSocialQsQuery.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
                        
                        if let questionTemp = questionObjects {
                            
                            self.questions.removeAll(keepCapacity: true)
                            self.questionIds.removeAll(keepCapacity: true)
                            self.option1s.removeAll(keepCapacity: true)
                            self.option2s.removeAll(keepCapacity: true)
                            self.option1sPhoto.removeAll(keepCapacity: true)
                            self.option2sPhoto.removeAll(keepCapacity: true)
                            self.option1Stats.removeAll(keepCapacity: true)
                            self.option2Stats.removeAll(keepCapacity: true)
                            
                            for questionObject in questionTemp {
                                
                                self.questions.append(questionObject["question"] as! String)
                                self.questionIds.append(questionObject.objectId!!)
                                
                                
                                if let test = questionObject["option1"] as? String {
                                    
                                    self.option1s.append(questionObject["option1"] as! String)
                                    self.option1sPhoto.append(PFFile())
                                    
                                } else {
                                    
                                    self.option1s.append(photoString)
                                    self.option1sPhoto.append(questionObject["option1Photo"] as! PFFile)
                                    
                                }
                                
                                if let test = questionObject["option2"] as? String {
                                    
                                    self.option2s.append(questionObject["option2"] as! String)
                                    self.option2sPhoto.append(PFFile())
                                    
                                } else {
                                    
                                    self.option2s.append(photoString)
                                    self.option2sPhoto.append(questionObject["option2Photo"] as! PFFile)
                                    
                                }
                                
                                self.option1Stats.append(questionObject["stats1"] as! Int)
                                self.option2Stats.append(questionObject["stats2"] as! Int)
                                
                                // Ensure all queries have completed THEN refresh the table!
                                if self.questions.count == self.option2Stats.count {
                                    
                                    self.tableView.reloadData()
                                    self.tableView.reloadInputViews()
                                    
                                    // Kill refresher when query finished
                                    self.refresher.endRefreshing()
                                    
                                    // Stop animation - hides when stopped (above) hides spinner automatically
                                    //self.activityIndicator.stopAnimating()
                                    
                                    // Release app input
                                    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                }
                            }
                        }
                    }
                }
            }
        })
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
        return questions.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var myCell = NEWMyQsCell()
        
        var option1String = ""
        var option2String = ""
        
        // Compute number of reponses and option stats
        var totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
            option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
        }
        
        // Build "repsonse" string to account for singular/plural
        var resp = "responses"
        if totalResponses == 1 { resp = "response" }
        
        // Currently check if either (1) option photo is filled in and use photo for both
        if option1s[indexPath.row] == photoString { // PHOTO OPTIONS
            
            myCell = tableView.dequeueReusableCellWithIdentifier("myCell2", forIndexPath: indexPath) as! NEWMyQsCell
            
            myCell.background.layer.cornerRadius = cornerRadius
            
            // Hide buttons from view
            myCell.option1Zoom.backgroundColor = UIColor.clearColor()
            myCell.option2Zoom.backgroundColor = UIColor.clearColor()
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            myCell.option1Image.contentMode = UIViewContentMode.ScaleAspectFill
            myCell.option2Image.contentMode = UIViewContentMode.ScaleAspectFill
            myCell.option1Image.clipsToBounds = true
            myCell.option2Image.clipsToBounds = true
            
            // Format options images
            myCell.option1Image.layer.cornerRadius = cornerRadius
            myCell.option2Image.layer.cornerRadius = cornerRadius
            myCell.option1Image.clipsToBounds = true
            myCell.option2Image.clipsToBounds = true
            
            // Set thumbnail images
            option1sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data1, error1) -> Void in
                
                if error1 != nil {
                    
                    println(error1)
                    
                } else {
                    
                    if let downloadedImage = UIImage(data: data1!) {
                        
                        myCell.option1Image.image = downloadedImage
                    }
                }
            })
            
            option2sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                
                if error2 != nil {
                    
                    println(error2)
                    
                } else {
                    
                    if let downloadedImage = UIImage(data: data2!) {
                        
                        myCell.option2Image.image = downloadedImage
                    }
                }
            })
            
            myCell.option1Zoom.tag = indexPath.row
            myCell.option2Zoom.tag = indexPath.row
            
        } else { // TEXT OPTIONS
            
            myCell = tableView.dequeueReusableCellWithIdentifier("myCell1", forIndexPath: indexPath) as! NEWMyQsCell
            
            option1String = option1s[indexPath.row] + " "
            option2String = option2s[indexPath.row] + " "
            
            //myCell.stats1.layer.cornerRadius = cornerRadius
            //myCell.stats2.layer.cornerRadius = cornerRadius
            myCell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
            if option1Percent > option2Percent {
                
                myCell.option1BackgroundImage.backgroundColor = winColor
                myCell.option2BackgroundImage.backgroundColor = loseColor
                
            } else if option2Percent > option1Percent {
                
                myCell.option1BackgroundImage.backgroundColor = winColor
                myCell.option2BackgroundImage.backgroundColor = loseColor
                
            } else {
                
                myCell.option1BackgroundImage.backgroundColor = winColor
                myCell.option2BackgroundImage.backgroundColor = winColor
                
            }
        }
        
        // Make cells non-selectable
        myCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        myCell.background.layer.cornerRadius = cornerRadius
        
        // Format option text backgrounds
        myCell.option1BackgroundImage.layer.cornerRadius = cornerRadius
        myCell.option2BackgroundImage.layer.cornerRadius = cornerRadius
        
        // Set all text
        myCell.question.numberOfLines = 0 // Dynamic number of lines
        myCell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
        myCell.question.text = questions[indexPath.row]
        if option1Stats[indexPath.row] + option1Stats[indexPath.row] > 0 {
            
            myCell.option1Label.text = option1String + "\(Int(option1Percent))%"
            myCell.option2Label.text = option2String + "\(Int(option2Percent))%"
            myCell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
        } else {
            
            myCell.option1Label.text = option1s[indexPath.row]
            myCell.option2Label.text = option2s[indexPath.row]
            myCell.numberOfResponses.text = "\(totalResponses) \(resp)"
            myCell.option1BackgroundImage.backgroundColor = loseColor
            myCell.option2BackgroundImage.backgroundColor = loseColor
        }
        //myCell.stats1.text = "\(Int(option1Percent))%"
        //myCell.stats2.text = "\(Int(option2Percent))%"
        //myCell.stats1.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        //myCell.stats2.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        
        
        // Format cell backgrounds
        //if indexPath.row % 2 == 0 {
        myCell.backgroundColor = UIColor.clearColor()
        //} else {
        //    myCell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        //}
        
        return myCell
    }
    
    
}
