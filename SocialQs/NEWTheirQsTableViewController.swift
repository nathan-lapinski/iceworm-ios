//
//  NEWTheirQsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/14/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class NEWTheirQsTableViewController: UITableViewController {
    
    var questionIds = [String]()
    var questions = [String]()
    var option1s = [String]()
    var option2s = [String]()
    var option1sPhoto = [PFFile]()
    var option2sPhoto = [PFFile]()
    var option1Stats = [Int]()
    var option2Stats = [Int]()
    //var users = [String: String]()
    var askers = [String]()
    //var dismissedTheirStorageKey = myName + "dismissedTheirPermanent"
    var deletedTheirStorageKey = myName + "deletedTheirPermanent"
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func vote1ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 1) }
    
    @IBAction func vote2ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 2) }
    
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
                }
                
                self.option2sPhoto[sender.tag].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                    
                    if error2 != nil {
                        
                        println(error2)
                        
                    } else {
                        
                        if let downloadedImage = UIImage(data: data2!) {
                            
                            imageZoom[1] = downloadedImage
                            
                            self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: sender)
                        }
                    }
                })
            }
        })
    }
    
    
    // Function to process the casting of votes
    func castVote(questionId: Int, optionId: Int) {
        
        // Setup spinner and black application input
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        var voteId = "stats\(optionId)" // remove??
        
        // Update internal and local storage of "myVotes"
        myVotes[questionIds[questionId]] = optionId
        NSUserDefaults.standardUserDefaults().setObject(myVotes, forKey: myVotesStorageKey)
        
        // Query Q table to get vote table Id
        // The access Vote table and do stuffs
        var query = PFQuery(className: "SocialQs")
        query.whereKey("objectId", equalTo: questionIds[questionId])
        query.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
            
            if error == nil {
                
                // ------------------------------------------------------------------------------------
                // All this logic is not necessary - need to figure out how to unwrap "questionObjects"
                // Only one item should exist when pulled with this whereKey, so no for loop needed.
                // ------------------------------------------------------------------------------------
                if let temp = questionObjects {
                    
                    for questionObject in temp {
                        
                        // Update vote data in Votes table (store what user voted)
                        var vId = questionObject["votesId"]!! as! String
                        var votesQuery = PFQuery(className: "Votes")
                        votesQuery.whereKey("objectId", equalTo: vId)
                        votesQuery.getObjectInBackgroundWithId(vId, block: { (voteObjects, error) -> Void in
                            
                            if error == nil {
                                
                                // NEW VOTES TABLE
                                if optionId == 1 {
                                    voteObjects!.addObject(myName, forKey: "option1VoterName")
                                    voteObjects!.saveInBackground()
                                } else {
                                    voteObjects!.addObject(myName, forKey: "option2VoterName")
                                    voteObjects!.saveInBackground()
                                }
                                
                                // Increment vote counter ---------------------------------
                                // Should this be nested in the above so all query/writes to DBare completed before switching views?
                                var statsQuery = PFQuery(className: "SocialQs")
                                
                                statsQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (object, error) -> Void in
                                    
                                    object!.incrementKey(voteId)
                                    object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                        
                                        if (success) { // The score key has been incremented
                                            
                                            //
                                            //
                                            // ---------------------------------------------------------------------------------------------------------------
                                            // Database vote values haven't come down by the time the increment occurs so we repoll this row and update
                                            // *** Instead of repolling, increment the local value and display it, then let it update from the server the next time it is refreshed!
                                            // ***
                                            //
                                            //
                                            var singleQuery = PFQuery(className: "SocialQs")
                                            
                                            singleQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (singleObjects, singleError) -> Void in
                                                
                                                // if singleError... // *********
                                                
                                                if let singleIndex = find(self.questionIds, questionObject.objectId!!) {
                                                    
                                                    self.option1Stats[singleIndex] = singleObjects!["stats1"]! as! Int
                                                    self.option2Stats[singleIndex] = singleObjects!["stats2"]! as! Int
                                                    
                                                    // Update table row
                                                    var indexPath = NSIndexPath(forRow: questionId, inSection: 0)
                                                    self.tableView.beginUpdates()
                                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                                                    self.tableView.endUpdates()
                                                    
                                                    self.activityIndicator.stopAnimating()
                                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                                }
                                            })
                                            // ---------------------------------------------------------------------------------------------------------------
                                            
                                        } else { // There was a problem, check error.description
                                            
                                            println("Increment error:")
                                            println(error)
                                            
                                            self.activityIndicator.stopAnimating()
                                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        }
                                    }
                                })
                                
                            } else {
                                
                                println("Votes Table query error")
                                println(error)
                            }
                        })
                        
                        //
                        //
                        // Move this into the DB nesting above AFTER above changes have been made!
                        //
                        //
                        // Update data in UserQs table (store on what Qs user already voted )
                        var userQsQuery = PFQuery(className: "UserQs")
                        //userQsQuery.whereKey("objectId", equalTo: uQId)
                        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
                            
                            if error == nil {
                                
                                // Store questionId into "votedOnId" array
                                if optionId == 1 {
                                    
                                    userQsObjects!.addObject(self.questionIds[questionId], forKey: "votedOn1Id")
                                    userQsObjects!.saveInBackground()
                                    
                                    votedOn1Ids.append(self.questionIds[questionId])
                                    NSUserDefaults.standardUserDefaults().setObject(votedOn1Ids, forKey: myVoted1StorageKey)
                                    
                                } else {
                                    
                                    userQsObjects!.addObject(self.questionIds[questionId], forKey: "votedOn2Id")
                                    userQsObjects!.saveInBackground()
                                    
                                    votedOn2Ids.append(self.questionIds[questionId])
                                    NSUserDefaults.standardUserDefaults().setObject(votedOn2Ids, forKey: myVoted2StorageKey)
                                }
                            }
                        })
                    }
                }
                
            } else {
                
                // Maybe insert a "this quetion has been flagged for removal" alert
                // - may need this if/when admins have to delete Qs?
                println("SocialQs Table query error:")
                println(error)
            }
        }
    }
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        // Determine which state (unvote or voted on) the cell is in before deleting from arrays
        var votedOn = false
        
        var votedOnTemp = votedOn1Ids + votedOn2Ids
        
        if contains(votedOnTemp, self.questionIds[indexPath.row]) {
            votedOn = true
        } else {
            votedOn = false
        }
        
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
                
                self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
            })
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
            
            // Append qId to "deleted" array in database
            var deletedQuery = PFQuery(className: "UserQs")
            //deletedQuery.whereKey("objectId", equalTo: uQId)
            
            deletedQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
                
                if error == nil {
                    
                    // Add Q to deleted
                    userQsObjects!.addUniqueObject(self.questionIds[indexPath.row], forKey: "deletedTheirQsId")
                    userQsObjects!.saveInBackground()
                    
                    // Remove Q from theirQs (their active Qs)
                    userQsObjects!.removeObject(self.questionIds[indexPath.row], forKey: "theirQsId")
                    userQsObjects!.saveInBackground()
                    
                    //deletedTheirQuestions.append(self.questionIds[indexPath.row])
                    
                    // Store updated array locally
                    //NSUserDefaults.standardUserDefaults().setObject(deletedTheirQuestions, forKey: self.deletedTheirStorageKey)
                    
                    self.questionIds.removeAtIndex(indexPath.row)
                    self.questions.removeAtIndex(indexPath.row)
                    self.option1s.removeAtIndex(indexPath.row)
                    self.option2s.removeAtIndex(indexPath.row)
                    self.option1sPhoto.removeAtIndex(indexPath.row)
                    self.option2sPhoto.removeAtIndex(indexPath.row)
                    self.option1Stats.removeAtIndex(indexPath.row)
                    self.option2Stats.removeAtIndex(indexPath.row)
                    self.askers.removeAtIndex(indexPath.row)
                    
                    tableView.beginUpdates()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.endUpdates()
                    
                } else {
                    
                    println("Error adding qId to UserQs/deletedTheirQsId")
                }
            })
        }
        trash.backgroundColor = UIColor.redColor()
        
        
        if votedOn {
            
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
        
        // Reload data upon first entry to view
        refresh()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg3.png"))
        
        // Set separator color
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(68,0,50,0)  // T, L, B, R
        
        // Disable auto inset adjust
        //self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        var cell = NEWTheirQsCell()
        
        var option1String = ""
        var option2String = ""
        
        // Compute number of reponses and option stats
        var totalResponses = Int()
        totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
            option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
        }
        
        // Build "repsonse" string to account for singular/plural
        var resp = "responses"
        if totalResponses == 1 { resp = "response" }
        
        let maxBarWidth = cell.contentView.bounds.width
        
        // *******************************************************************
        // MOVE TO MAIN SCOPE AND CONCATENATE WHEN THESE TWO ARE UPDATED??
        // *******************************************************************
        var votedOnTemp = votedOn1Ids + votedOn2Ids
        // *******************************************************************
        
        if option1s[indexPath.row] != photoString { // TEXT options
            
            option1String = option1s[indexPath.row] + " "
            option2String = option2s[indexPath.row] + " "
            
            cell = tableView.dequeueReusableCellWithIdentifier("theirCell1", forIndexPath: indexPath) as! NEWTheirQsCell
            
            // Compute and set results image view widths - MAKE GLOBAL CLASS w/ METHOD
            //var width1 = maxBarWidth //cell.option1ImageView.bounds.width
            //var width2 = maxBarWidth //cell.option2ImageView.bounds.width
            
            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
            if option1Percent > option2Percent {
                
                //width1 = maxBarWidth
                //width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
                cell.option1BackgroundImage.backgroundColor = winColor
                cell.option2BackgroundImage.backgroundColor = loseColor
                
            } else if option2Percent > option1Percent {
                
                //width2 = maxBarWidth
                //width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
                cell.option1BackgroundImage.backgroundColor = loseColor
                cell.option2BackgroundImage.backgroundColor = winColor
                
            } else {
                
                //width1 = maxBarWidth
                //width2 = maxBarWidth
                cell.option1BackgroundImage.backgroundColor = winColor
                cell.option2BackgroundImage.backgroundColor = winColor
            }
            
            // Set Vote button text
            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
            
            
        } else if option1s[indexPath.row] == photoString { // PHOTO option
            
            cell = tableView.dequeueReusableCellWithIdentifier("theirCell2", forIndexPath: indexPath) as! NEWTheirQsCell
            
            var option1String = ""
            var option2String = ""
            
            // Hide buttons from view
            cell.vote1Button.backgroundColor = UIColor.clearColor()
            cell.vote2Button.backgroundColor = UIColor.clearColor()
            cell.option1Zoom.backgroundColor = UIColor.clearColor()
            cell.option2Zoom.backgroundColor = UIColor.clearColor()
            
            // Format thumbnail views - aspect fill without breaching imageView bounds
            cell.option1Image.contentMode = UIViewContentMode.ScaleAspectFill
            cell.option2Image.contentMode = UIViewContentMode.ScaleAspectFill
            cell.option1Image.clipsToBounds = true
            cell.option2Image.clipsToBounds = true
            
            // Format options imageViews
            cell.option1Image.layer.cornerRadius = cornerRadius
            cell.option2Image.layer.cornerRadius = cornerRadius
            cell.option1Image.clipsToBounds = true
            cell.option2Image.clipsToBounds = true
            
            // Set thumbnail images
            option1sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data1, error1) -> Void in
                
                if error1 != nil {
                    
                    println(error1)
                    
                } else {
                    
                    if let downloadedImage = UIImage(data: data1!) {
                        
                        cell.option1Image.image = downloadedImage
                    }
                }
            })
            
            option2sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                
                if error2 != nil {
                    
                    println(error2)
                    
                } else {
                    
                    if let downloadedImage = UIImage(data: data2!) {
                        
                        cell.option2Image.image = downloadedImage
                    }
                }
            })
            
            // Blur screen while Q upload is processing
            //let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            //var blurView1 = UIVisualEffectView(effect: blurEffect)
            //var blurView2 = UIVisualEffectView(effect: blurEffect)
            //blurView1.frame = cell.option1Image.frame
            //cell.option1Image.addSubview(blurView1)
            //blurView2.frame = cell.option2Image.frame
            //cell.option2Image.addSubview(blurView2)
            
            if option1Percent > option2Percent {
                
                //width1 = maxBarWidth
                //width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
                cell.option1BackgroundImage.backgroundColor = winColor
                cell.option2BackgroundImage.backgroundColor = loseColor
                
            } else if option2Percent > option1Percent {
                
                //width2 = maxBarWidth
                //width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
                cell.option1BackgroundImage.backgroundColor = loseColor
                cell.option2BackgroundImage.backgroundColor = winColor
                
            } else {
                
                //width1 = maxBarWidth
                //width2 = maxBarWidth
                cell.option1BackgroundImage.backgroundColor = winColor
                cell.option2BackgroundImage.backgroundColor = winColor
            }
            
            // Set Vote button text
            cell.vote1Button.setTitle("Vote", forState: UIControlState.Normal)
            cell.vote2Button.setTitle("Vote", forState: UIControlState.Normal)
            
            // Tag zoom buttons
            cell.option1Zoom.tag = indexPath.row
            cell.option2Zoom.tag = indexPath.row
        }
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Set background image corners
        cell.background.layer.cornerRadius = cornerRadius
        
        // Profile Pic
        cell.profilePicture.layer.borderWidth = 1.0
        cell.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        cell.profilePicture.layer.masksToBounds = false
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width/2
        cell.profilePicture.clipsToBounds = true
        
        // Format option backgrounds
        cell.option1BackgroundImage.layer.cornerRadius = cornerRadius
        cell.option2BackgroundImage.layer.cornerRadius = cornerRadius
        
        // Set vote background to clear
        cell.vote1Button.backgroundColor = UIColor.clearColor()
        cell.vote2Button.backgroundColor = UIColor.clearColor()
        
        // Set all text
        cell.question.numberOfLines = 0 // Dynamic number of lines
        cell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.question.text = questions[indexPath.row]
        cell.username.text = askers[indexPath.row] //"Asked by " + askers[indexPath.row]
        //cell.stats1.text = "\(Int(option1Percent))%"
        //cell.stats2.text = "\(Int(option2Percent))%"
        //cell.stats1.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        //cell.stats2.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        cell.myVote1.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        cell.myVote2.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
        
        // Mark user's choice
        if contains(votedOn1Ids, questionIds[indexPath.row]) {
            
            cell.vote1Button.enabled = false
            cell.vote2Button.enabled = false
            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
            
            cell.myVote1.hidden = false
            cell.myVote2.hidden = true
            cell.myVote1.text = "✔"
            cell.myVote2.text = ""
            
            // Unhide results
            //cell.stats1.hidden = false
            //cell.stats2.hidden = false
            
            cell.option1Label.text = option1String + "\(Int(option1Percent))%"
            cell.option2Label.text = option1String + "\(Int(option2Percent))%"
            
            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
        } else if contains(votedOn2Ids, questionIds[indexPath.row]) {
            
            cell.vote1Button.enabled = false
            cell.vote2Button.enabled = false
            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
            
            // Unhide results
            //cell.stats1.hidden = false
            //cell.stats2.hidden = false
            
            cell.myVote1.hidden = true
            cell.myVote2.hidden = false
            cell.myVote2.text = "✔"
            cell.myVote1.text = ""
            
            cell.option1Label.text = option1String + "\(Int(option1Percent))%"
            cell.option2Label.text = option1String + "\(Int(option2Percent))%"
            
            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
        } else {
            
            cell.vote1Button.enabled = true
            cell.vote2Button.enabled = true
            cell.myVote1.hidden = true
            cell.myVote2.hidden = true
            
            // Hide results
            //cell.stats1.hidden = true
            //cell.stats2.hidden = true
            
            cell.myVote2.text = ""
            cell.myVote1.text = ""
            cell.numberOfResponses.text = ""
            
            cell.option1BackgroundImage.backgroundColor = loseColor
            cell.option2BackgroundImage.backgroundColor = loseColor
            //cell.option1Label.text = ""
            //cell.option2Label.text = ""
            
            cell.option1Label.text = option1String
            cell.option2Label.text = option2String
        }
        
        // Why can't I set a corner radius on text field? -------
        // Format myVote and stats background
        //cell.stats1.layer.cornerRadius = cornerRadius
        //cell.stats2.layer.cornerRadius = cornerRadius
        cell.myVote1.layer.cornerRadius = cornerRadius
        cell.myVote2.layer.cornerRadius = cornerRadius
        // Why can't I set a corner radius on text field? -------
        
        // Format cell backgrounds
        //if indexPath.row % 2 == 0 {
        cell.backgroundColor = UIColor.clearColor()
        //} else {
        //    cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        //}
        
        // Tag vote buttons
        cell.vote1Button.tag = indexPath.row
        cell.vote2Button.tag = indexPath.row
        
        return cell
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
        // MAKE FUNCTION -----------------------------------------------------------
        // Recall deleted/dismissed data
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey) != nil {
            deletedTheirQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey)! as! [(String)]
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey) != nil {
            myVotes = NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey)! as! Dictionary
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey) != nil {
            votedOn1Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey)! as! [(String)]
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey) != nil {
            votedOn2Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey)! as! [(String)]
        }
        // MAKE FUNCTION -----------------------------------------------------------
        
        
        // **********************************************************************************************
        // Manually call refresh upon loading to get most up to datest datas
        // - this needs to be skipped when push is allowed and used when push has been declined
        //if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
        
        if returningFromPopover == false {
            returningFromPopover = true
            refresh()
        }
        
        //refresh()
        //    println("USER IS NOT SUBSCRIBED TO RELOADTHEIRTABLE")
        //}
        // **********************************************************************************************
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        // Get list of Qs to pull from UserQs
        var userQsQuery = PFQuery(className: "UserQs")
        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
            
            if error != nil {
                
                println("Error accessing UserQs/theirQsId")
                println(error)
                
            } else {
                
                if let theirQs = userQsObjects!["theirQsId"] as? [String] {
                    
                    // Pull Qs with Id in pullIds
                    var getSocialQsQuery = PFQuery(className: "SocialQs")
                    
                    // Sort by newest created-date first
                    getSocialQsQuery.orderByDescending("createdAt")
                    
                    // Get only theirQs that I haven't deleted
                    getSocialQsQuery.whereKey("objectId", containedIn: theirQs)
                    
                    // Set query limit to max
                    getSocialQsQuery.limit = 1000
                    
                    // Pull data
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
                            self.askers.removeAll(keepCapacity: true)
                            
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
                                self.askers.append(questionObject["askername"] as! String)
                                
                                // Ensure all queries have completed THEN refresh the table!
                                // CHANGED THIS TO MATCH NEW PULL METHOD - WAS "ASKERS"
                                //
                                if self.questions.count == self.option2Stats.count {
                                    
                                    self.tableView.reloadData()
                                    self.tableView.reloadInputViews()
                                    
                                    // Kill refresher when query finished
                                    self.refresher.endRefreshing()
                                    
                                }
                                
                                // Stop animation - hides when stopped (above) hides spinner automatically
                                //self.activityIndicator.stopAnimating()
                                
                                // Release app input
                                //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            }
                        }
                    }
                } else {
                    
                    // NO Qs
                    
                }
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
