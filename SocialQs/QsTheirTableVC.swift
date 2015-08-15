////
////  QsTheirTableVC.swift
////  SocialQs
////
////  Created by Brett Wiesman on 7/14/15.
////  Copyright (c) 2015 BookSix. All rights reserved.
////
//
//import UIKit
//
//class QsTheirTableVC: UITableViewController {
//    
//    var questionObjects: NSArray = []
//    
////    var questionIds = [String]()
////    var questions = [String]()
////    var option1s = [String]()
////    var option2s = [String]()
////    var option1sPhoto: [PFFile?] = [PFFile]()
////    var option2sPhoto: [PFFile?] = [PFFile]()
////    var questionsPhoto: [PFFile?]  = [PFFile]()
////    var askerPhotos = Dictionary<String, UIImage?>()
////    var option1Stats = [Int]()
////    var option2Stats = [Int]()
////    var askers = [String]()
////    var configuration = [String]()
////    var votesId = [String]()
////    var photosId = [String]()
//    
//    var refresher: UIRefreshControl!
//    var theirQsSpinner = UIActivityIndicatorView()
//    var theirQsBlurView = globalBlurView()
//    
//    @IBAction func vote1ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 1) }
//    
//    @IBAction func vote2ButtonAction(sender: AnyObject) { castVote(sender.tag, optionId: 2) }
//    
//    @IBAction func zoomQButton(sender: AnyObject) {
//        
//        zoomPage = 0
//        setPhotosToZoom(sender)
//    }
//    
//    @IBAction func zoom1ButtonAction(sender: AnyObject) {
//        
//        zoomPage = 0
//        
//        if (questionObjects[sender.tag]["questionPhoto"] as? PFFile != nil) { zoomPage++ }
//        
//        setPhotosToZoom(sender)
//    }
//    
//    @IBAction func zoom2ButtonAction(sender: AnyObject) {
//        
//        zoomPage = 0
//        
//        if (questionObjects[sender.tag]["questionPhoto"] as? PFFile != nil) { zoomPage++ }
//        if (questionObjects[sender.tag]["option1Photo"]  as? PFFile != nil) { zoomPage++ }
//        
//        setPhotosToZoom(sender)
//    }
//
//    
//    func setPhotosToZoom(sender: AnyObject) {
//        
//        println(questionObjects[sender.tag])
//        
//        blockUI(true, theirQsSpinner, theirQsBlurView, self)
//        
//        if contains(isUploading, questionObjects[sender.tag].objectId!!) {
//            
//            displayAlert("Error", "These images are still uploading. Please try again shortly!", self)
//            
//        } else {
//            
//            questionToView = questionObjects[sender.tag] as? PFObject //self.questions[sender.tag]
//            
//            blockUI(false, self.theirQsSpinner, self.theirQsBlurView, self)
//            
//            self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: sender)
//        }
//    }
//    
//    
//    // Function to process the casting of votes
//    func castVote(questionId: Int, optionId: Int) {
//        
//        blockUI(true, theirQsSpinner, theirQsBlurView, self)
//        
//        var getQJoin = PFQuery(className: "QJoin")
//        getQJoin.whereKey("question", equalTo: questionObjects[questionId])
//        
//        getQJoin.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
//            
//            if error != nil {
//                
//                println(object)
//            }
//        }
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//////        // Setup spinner and black application input
//////        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
//////        activityIndicator.center = self.view.center
//////        activityIndicator.hidesWhenStopped = true
//////        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//////        view.addSubview(activityIndicator)
//////        activityIndicator.startAnimating()
//////        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
////        
////        var voteId = "stats\(optionId)" // remove??
////        
////        // Update internal and local storage of "myVotes"
//////        myVotes[questionIds[questionId]] = optionId
//////        NSUserDefaults.standardUserDefaults().setObject(myVotes, forKey: myVotesStorageKey)
////        
////        // Query Q table to get vote table Id
////        // Then access Vote table and do stuffs
////        var query = PFQuery(className: "SocialQs")
////        query.whereKey("objectId", equalTo: questionIds[questionId])
////        query.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
////            
////            if error == nil {
////                
////                // ------------------------------------------------------------------------------------
////                // All this logic is not necessary - need to figure out how to unwrap "questionObjects"
////                // Only one item should exist when pulled with this whereKey, so no for loop needed.
////                // ------------------------------------------------------------------------------------
////                if let temp = questionObjects {
////                    
////                    for questionObject in temp {
////                        
////                        // Update vote data in Votes table (store what user voted)
////                        var vId = questionObject["votesId"]!! as! String
////                        var votesQuery = PFQuery(className: "Votes")
////                        //votesQuery.whereKey("objectId", equalTo: vId)
////                        votesQuery.getObjectInBackgroundWithId(vId, block: { (voteObjects, error) -> Void in
////                            
////                            if error == nil {
////                                
////                                // NEW VOTES TABLE
////                                if optionId == 1 {
////                                    voteObjects!.addObject(username, forKey: "option1VoterName")
////                                    voteObjects!.saveInBackground()
////                                } else {
////                                    voteObjects!.addObject(username, forKey: "option2VoterName")
////                                    voteObjects!.saveInBackground()
////                                }
////                                
////                                // Increment vote counter ---------------------------------
////                                // Should this be nested in the above so all query/writes to DBare completed before switching views?
////                                var statsQuery = PFQuery(className: "SocialQs")
////                                
////                                statsQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (object, error) -> Void in
////                                    
////                                    object!.incrementKey(voteId)
////                                    object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
////                                        
////                                        if (success) { // The score key has been incremented
////                                            
////                                            //
////                                            //
////                                            // ---------------------------------------------------------------------------------------------------------------
////                                            // Database vote values haven't come down by the time the increment occurs so we repoll this row and update
////                                            // *** Instead of repolling, increment the local value and display it, then let it update from the server the next time it is refreshed!
////                                            // ***
////                                            //
////                                            //
////                                            var singleQuery = PFQuery(className: "SocialQs")
////                                            
////                                            singleQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (singleObjects, singleError) -> Void in
////                                                
////                                                // if singleError... // *********
////                                                
////                                                if let singleIndex = find(self.questionIds, questionObject.objectId!!) {
////                                                    
////                                                    self.option1Stats[singleIndex] = singleObjects!["stats1"]! as! Int
////                                                    self.option2Stats[singleIndex] = singleObjects!["stats2"]! as! Int
////                                                    
////                                                    // Update table row
////                                                    var indexPath = NSIndexPath(forRow: questionId, inSection: 0)
////                                                    self.tableView.beginUpdates()
////                                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
////                                                    self.tableView.endUpdates()
////                                                    
//////                                                    self.activityIndicator.stopAnimating()
//////                                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
////                                                    blockUI(false, self.theirQsSpinner, self.theirQsBlurView, self)
////                                                }
////                                            })
////                                            // ---------------------------------------------------------------------------------------------------------------
////                                            
////                                        } else { // There was a problem, check error.description
////                                            
////                                            println("Increment error:")
////                                            println(error)
////                                            
////                                            // self.activityIndicator.stopAnimating()
////                                            // UIApplication.sharedApplication().endIgnoringInteractionEvents()
////                                            blockUI(false, self.theirQsSpinner, self.theirQsBlurView, self)
////                                        }
////                                    }
////                                })
////                                
////                            } else {
////                                
////                                println("Votes Table query error")
////                                println(error)
////                            }
////                        })
////                        
////                        //
////                        //
////                        // Move this into the DB nesting above AFTER above changes have been made!
////                        //
////                        //
////                        // Update data in UserQs table (store on what Qs user already voted )
////                        var userQsQuery = PFQuery(className: "UserQs")
////                        //userQsQuery.whereKey("objectId", equalTo: uQId)
////                        userQsQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
////                            
////                            if error == nil {
////                                
////                                // Store questionId into "votedOnId" array
////                                if optionId == 1 {
////                                    
////                                    userQsObjects!.addObject(self.questionIds[questionId], forKey: "votedOn1Id")
////                                    userQsObjects!.saveInBackground()
////                                    
////                                    votedOn1Ids.append(self.questionIds[questionId])
////                                    NSUserDefaults.standardUserDefaults().setObject(votedOn1Ids, forKey: myVoted1StorageKey)
////                                    
////                                } else {
////                                    
////                                    userQsObjects!.addObject(self.questionIds[questionId], forKey: "votedOn2Id")
////                                    userQsObjects!.saveInBackground()
////                                    
////                                    votedOn2Ids.append(self.questionIds[questionId])
////                                    NSUserDefaults.standardUserDefaults().setObject(votedOn2Ids, forKey: myVoted2StorageKey)
////                                }
////                            }
////                        })
////                    }
////                }
////                
////            } else {
////                
////                // Maybe insert a "this quetion has been flagged for removal" alert
////                // - may need this if/when admins have to delete Qs?
////                println("SocialQs Table query error:")
////                println(error)
////            }
////        }
//    }
//    
//    
//    // Swipe to display options functions ----------------------------------------------------------------------------------
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
//        
//        // Determine which state (unvote or voted on) the cell is in before deleting from arrays
//        var votedOn = false
//        
//        var votedOnTemp = votedOn1Ids + votedOn2Ids
//        
//        if contains(votedOnTemp, self.questionIds[indexPath.row]) {
//            votedOn = true
//        } else {
//            votedOn = false
//        }
//        
//        //"More"
//        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
//            
//            imageZoom = [nil, nil, nil]
//            
//            var expectedCount = 0
//            var downloadedCount = 0
//            
//            if self.questionsPhoto[indexPath.row] != nil { expectedCount++ }
//            if self.option1sPhoto[indexPath.row] != nil { expectedCount++ }
//            if self.option2sPhoto[indexPath.row] != nil { expectedCount++ }
//            
//            self.setViewQ(indexPath.row)
//            
//            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
//            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
//            requestedQId = self.questionIds[indexPath.row]
//            
//            if expectedCount == 0 {
//                
//                self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
//                
//            } else {
//            
//                if self.questionsPhoto[indexPath.row] != nil {
//                    
//                    self.questionsPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                        
//                        if error != nil {
//                            
//                            println(error)
//                            
//                        } else {
//                            
//                            
//                            if let downloadedImage = UIImage(data: data!) {
//                                
//                                imageZoom[0] = downloadedImage
//                                
//                                downloadedCount++
//                            }
//                            
//                            if downloadedCount == expectedCount {
//                                
//                                self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
//                            }
//                        }
//                    })
//                    
//                }
//                
//                if self.option1sPhoto[indexPath.row] != nil {
//                    
//                    self.option1sPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (data1, error1) -> Void in
//                        
//                        if error1 != nil {
//                            
//                            println(error1)
//                            
//                        } else {
//                            
//                            if let downloadedImage = UIImage(data: data1!) {
//                                
//                                imageZoom[1] = downloadedImage
//                                
//                                downloadedCount++
//                            }
//                            
//                            if downloadedCount == expectedCount {
//                                
//                                self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
//                            }
//                        }
//                    })
//                }
//                
//                if self.option2sPhoto[indexPath.row] != nil {
//                    
//                    self.option2sPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (data2, error2) -> Void in
//                        
//                        if error2 != nil {
//                            
//                            println(error2)
//                            
//                        } else {
//                            
//                            if let downloadedImage = UIImage(data: data2!) {
//                                
//                                imageZoom[2] = downloadedImage
//                                
//                                downloadedCount++
//                            }
//                            
//                            if downloadedCount == expectedCount {
//                                
//                                self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
//                            }
//                        }
//                    })
//                }
//            }
//            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
//            // FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION FUNCTION
//        }
//        view.backgroundColor = UIColor.orangeColor()
//        
//        
//        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
//            
//            println("share button tapped")
//        }
//        share.backgroundColor = UIColor.grayColor()
//        
//        
//        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
//            
//            // Append qId to "deleted" array in database
//            var deletedQuery = PFQuery(className: "UserQs")
//            
//            deletedQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
//                
//                if error == nil {
//                    
//                    // Add Q to deleted
//                    userQsObjects!.addUniqueObject(self.questionIds[indexPath.row], forKey: "deletedTheirQsId")
//                    userQsObjects!.saveInBackground()
//                    
//                    // Remove Q from theirQs (their active Qs)
//                    userQsObjects!.removeObject(self.questionIds[indexPath.row], forKey: "theirQsId")
//                    userQsObjects!.saveInBackground()
//                    
//                    self.questionIds.removeAtIndex(indexPath.row)
//                    self.questions.removeAtIndex(indexPath.row)
//                    self.questionsPhoto.removeAtIndex(indexPath.row)
//                    self.option1s.removeAtIndex(indexPath.row)
//                    self.option2s.removeAtIndex(indexPath.row)
//                    self.option1sPhoto.removeAtIndex(indexPath.row)
//                    self.option2sPhoto.removeAtIndex(indexPath.row)
//                    self.option1Stats.removeAtIndex(indexPath.row)
//                    self.option2Stats.removeAtIndex(indexPath.row)
//                    self.askers.removeAtIndex(indexPath.row)
//                    //self.askerPhotos.removeAtIndex(indexPath.row)
//                    self.configuration.removeAtIndex(indexPath.row)
//                    self.votesId.removeAtIndex(indexPath.row)
//                    self.photosId.removeAtIndex(indexPath.row)
//                    
//                    tableView.beginUpdates()
//                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                    tableView.endUpdates()
//                    
//                } else {
//                    
//                    println("Error adding qId to UserQs/deletedTheirQsId")
//                }
//            })
//        }
//        trash.backgroundColor = UIColor.redColor()
//        
//        
//        println("Swiped THEIR row: \(indexPath.row)")
//        
//        
//        if votedOn {
//            
//            return [trash, view] // Order = appearance order, right to left on screen
//            
//        } else {
//            
//            return [trash] // Order = appearance order, right to left on screen
//        }
//    }
//    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // the cells you would like the actions to appear needs to be editable
//        return true
//    }
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // you need to implement this method too or you can't swipe to display the actions
//    }
//    // Swipe to display options functions ----------------------------------------------------------------------------------
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // PUSH - Set up the reload to trigger off the push for "reloadTable"
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "reloadTheirTable", object: nil)
//        
//        // Reload data upon first entry to view - NOW HANDLED IN VIEWWILLAPPEAR
//        //refresh()
//        
//        // Pull to refresh --------------------------------------------------------
//        refresher = UIRefreshControl()
//        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(refresher)
//        // Pull to refresh --------------------------------------------------------
//        
//        // Set table background image
//        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg4.png"))
//        
//        // Set separator color
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        
//        // Adjust top and bottom bounds of table for nav and tab bars
//        //self.tableView.contentInset = UIEdgeInsetsMake(64,0,52,0)  // T, L, B, R
//        
//        // Disable auto inset adjust
//        //self.automaticallyAdjustsScrollViewInsets = false
//        
//    }
//    
//    
//    // MAKE GLOBAL -------------------------------------
//    // MAKE GLOBAL -------------------------------------
//    func setViewQ(index: Int) {
//        
//        viewQ = Dictionary<String, Any>()
//        
//        viewQ["qId"] = self.questionIds[index]
//        viewQ["question"] = self.questions[index]
//        if self.questionsPhoto[index] != nil { viewQ["questionPhoto"] = self.questionsPhoto[index] }
//        viewQ["option1"] = self.option1s[index]
//        if self.option1sPhoto[index] != nil { viewQ["option1Photo"]  = self.option1sPhoto[index] }
//        viewQ["option2"] = self.option2s[index]
//        if self.option2sPhoto[index] != nil { viewQ["option2Photo"]  = self.option2sPhoto[index] }
//        viewQ["votesId"] = self.votesId[index]
//    }
//    // MAKE GLOBAL -------------------------------------
//    // MAKE GLOBAL -------------------------------------
//    
//    
//    // MARK: - Table view data source
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return questions.count
//    }
//    
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        var cell = NEWTheirQsCell()
//        
//        var option1String = ""
//        var option2String = ""
//  
//        // Compute number of reponses and option stats
//        var totalResponses = Int()
//        totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
//        var option1Percent = Float(0.0)
//        var option2Percent = Float(0.0)
//        
//        if totalResponses != 0 {
//            option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
//            option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
//        }
//        
//        // Build "repsonse" string to account for singular/plural
//        var resp = "responses"
//        if totalResponses == 1 { resp = "response" }
//        
//        let maxBarWidth = cell.contentView.bounds.width
//        
//        var votedOnTemp = votedOn1Ids + votedOn2Ids
//        
//        
//        // ---- TEXT ONLY OPTIONS -------------------------------------------------
//        if contains(["1c", "2c", "3c"], configuration[indexPath.row]) {
//            
//            option1String = option1s[indexPath.row] + " "
//            option2String = option2s[indexPath.row] + " "
//            
//            cell = tableView.dequeueReusableCellWithIdentifier("theirCell1", forIndexPath: indexPath) as! NEWTheirQsCell
//            
//            // Compute and set results image view widths - MAKE GLOBAL CLASS w/ METHOD
//            //var width1 = maxBarWidth //cell.option1ImageView.bounds.width
//            //var width2 = maxBarWidth //cell.option2ImageView.bounds.width
//            
//            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
//            
//            if option1Percent > option2Percent {
//                
//                //width1 = maxBarWidth
//                //width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
//                cell.option1BackgroundImage.backgroundColor = winColor
//                cell.option2BackgroundImage.backgroundColor = loseColor
//                
//            } else if option2Percent > option1Percent {
//                
//                //width2 = maxBarWidth
//                //width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
//                cell.option1BackgroundImage.backgroundColor = loseColor
//                cell.option2BackgroundImage.backgroundColor = winColor
//                
//            } else {
//                
//                //width1 = maxBarWidth
//                //width2 = maxBarWidth
//                cell.option1BackgroundImage.backgroundColor = winColor
//                cell.option2BackgroundImage.backgroundColor = winColor
//            }
//            
//            // Set Vote button text
//            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
//            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
//            
//            cell.question.text = questions[indexPath.row]
//            
//            cell.questionZoom.tag = indexPath.row
//            
//        // ---- OTHER OPTIONS ----------------------------------------------------
//        } else {
//            
//            cell = tableView.dequeueReusableCellWithIdentifier("theirCell2", forIndexPath: indexPath) as! NEWTheirQsCell
//            
//            if option1s[indexPath.row] != "" {
//                option1String = option1s[indexPath.row] + " "
//            }
//            if option2s[indexPath.row] != "" {
//                option2String = option2s[indexPath.row] + " "
//            }
//            
//            // Hide buttons from view
//            cell.vote1Button.backgroundColor = UIColor.clearColor()
//            cell.vote2Button.backgroundColor = UIColor.clearColor()
//            cell.option1Zoom.backgroundColor = UIColor.clearColor()
//            cell.option2Zoom.backgroundColor = UIColor.clearColor()
//            
//            // Format thumbnail views - aspect fill without breaching imageView bounds
//            cell.option1Image.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.option2Image.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.option1Image.clipsToBounds = true
//            cell.option2Image.clipsToBounds = true
//            
//            // Format options imageViews
//            cell.option1Image.layer.cornerRadius = cornerRadius
//            cell.option2Image.layer.cornerRadius = cornerRadius
//            cell.option1Image.clipsToBounds = true
//            cell.option2Image.clipsToBounds = true
//            
//            // Set thumbnail images
//            option1sPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (data1, error1) -> Void in
//                
//                if error1 != nil {
//                    
//                    println(error1)
//                    
//                } else {
//                    
//                    if let downloadedImage = UIImage(data: data1!) {
//                        
//                        cell.option1Image.image = downloadedImage
//                    }
//                }
//            })
//            
//            option2sPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (data2, error2) -> Void in
//                
//                if error2 != nil {
//                    
//                    println(error2)
//                    
//                } else {
//                    
//                    if let downloadedImage = UIImage(data: data2!) {
//                        
//                        cell.option2Image.image = downloadedImage
//                    }
//                }
//            })
//            
//            // Blur screen while Q upload is processing
//            //let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            //var blurView1 = UIVisualEffectView(effect: blurEffect)
//            //var blurView2 = UIVisualEffectView(effect: blurEffect)
//            //blurView1.frame = cell.option1Image.frame
//            //cell.option1Image.addSubview(blurView1)
//            //blurView2.frame = cell.option2Image.frame
//            //cell.option2Image.addSubview(blurView2)
//            
//            if option1Percent > option2Percent {
//                
//                //width1 = maxBarWidth
//                //width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
//                cell.option1BackgroundImage.backgroundColor = winColor
//                cell.option2BackgroundImage.backgroundColor = loseColor
//                
//            } else if option2Percent > option1Percent {
//                
//                //width2 = maxBarWidth
//                //width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
//                cell.option1BackgroundImage.backgroundColor = loseColor
//                cell.option2BackgroundImage.backgroundColor = winColor
//                
//            } else {
//                
//                //width1 = maxBarWidth
//                //width2 = maxBarWidth
//                cell.option1BackgroundImage.backgroundColor = winColor
//                cell.option2BackgroundImage.backgroundColor = winColor
//            }
//            
//            // Set Vote button text
//            if option1s[indexPath.row] == "" {
//                cell.vote1Button.setTitle("Vote", forState: UIControlState.Normal)
//            } else {
//                cell.vote1Button.setTitle("", forState: UIControlState.Normal)
//            }
//            if option2s[indexPath.row] == "" {
//                cell.vote2Button.setTitle("Vote", forState: UIControlState.Normal)
//            } else {
//                cell.vote2Button.setTitle("", forState: UIControlState.Normal)
//            }
//            
//            // Tag zoom buttons
//            cell.option1Zoom.tag = indexPath.row
//            cell.option2Zoom.tag = indexPath.row
//        }
//        
//        
//        // Q image stuff in here
//        if contains(["1a", "2a", "1b", "2b"], configuration[indexPath.row]) {
//            
//            // set Q image and set narrow Q text
//            cell.questionImage.hidden = false// Set thumbnail images
//            questionsPhoto[indexPath.row]!.getDataInBackgroundWithBlock({ (dataq, errorq) -> Void in
//                
//                if errorq != nil {
//                    
//                    println(errorq)
//                    
//                } else {
//                    
//                    if let downloadedImage = UIImage(data: dataq!) {
//                        
//                        cell.questionImage.image = downloadedImage
//                    }
//                }
//            })
//            
//            cell.questionImage.hidden = false
//            
//            cell.questionImage.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.questionImage.clipsToBounds = true
//            
//            cell.questionNarrow.text = questions[indexPath.row]
//            cell.questionNarrow.hidden = false
//            cell.question.hidden = true
//            
//        } else {
//            
//            // Q image is blank, set wide Q text
//            cell.questionImage.hidden = true
//            
//            cell.question.text = questions[indexPath.row]
//            cell.question.hidden = false
//            cell.questionNarrow.hidden = true
//        }
//
//        
//        
//        // Make cells non-selectable
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        
//        // Set background image corners
//        cell.background.layer.cornerRadius = cornerRadius
//        
//        // Profile Pic
//        cell.profilePicture.layer.borderWidth = 1.0
//        cell.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
//        cell.profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
//        cell.profilePicture.layer.masksToBounds = false
//        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width/2
//        cell.profilePicture.clipsToBounds = true
//        
//        // Format option backgrounds
//        cell.option1BackgroundImage.layer.cornerRadius = cornerRadius
//        cell.option2BackgroundImage.layer.cornerRadius = cornerRadius
//        
//        // Set vote background to clear
//        cell.vote1Button.backgroundColor = UIColor.clearColor()
//        cell.vote2Button.backgroundColor = UIColor.clearColor()
//        
//        // Set all text
//        cell.question.numberOfLines = 0 // Dynamic number of lines
//        cell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        cell.username.text = askers[indexPath.row]
//        cell.myVote1.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
//        cell.myVote2.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
//        
//        // Mark user's choice
//        if contains(votedOn1Ids, questionIds[indexPath.row]) {
//            
//            cell.vote1Button.enabled = false
//            cell.vote2Button.enabled = false
//            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
//            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
//            
//            cell.myVote1.hidden = false
//            cell.myVote2.hidden = true
//            cell.myVote1.text = "✔"
//            cell.myVote2.text = ""
//            
//            cell.option1Label.text = option1String + "\(Int(option1Percent))%"
//            cell.option2Label.text = option2String + "\(Int(option2Percent))%"
//            
//            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
//            
//        } else if contains(votedOn2Ids, questionIds[indexPath.row]) {
//            
//            cell.vote1Button.enabled = false
//            cell.vote2Button.enabled = false
//            cell.vote1Button.setTitle("", forState: UIControlState.Normal)
//            cell.vote2Button.setTitle("", forState: UIControlState.Normal)
//            
//            cell.myVote1.hidden = true
//            cell.myVote2.hidden = false
//            cell.myVote2.text = "✔"
//            cell.myVote1.text = ""
//            
//            cell.option1Label.text = option1String + "\(Int(option1Percent))%"
//            cell.option2Label.text = option2String + "\(Int(option2Percent))%"
//            
//            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
//            
//        } else {
//            
//            cell.vote1Button.enabled = true
//            cell.vote2Button.enabled = true
//            cell.myVote1.hidden = true
//            cell.myVote2.hidden = true
//            
//            cell.myVote2.text = ""
//            cell.myVote1.text = ""
//            cell.numberOfResponses.text = ""
//            
//            cell.option1BackgroundImage.backgroundColor = loseColor
//            cell.option2BackgroundImage.backgroundColor = loseColor
//            
//            cell.option1Label.text = option1String
//            cell.option2Label.text = option2String
//        }
//        
//        cell.myVote1.layer.cornerRadius = cornerRadius
//        cell.myVote2.layer.cornerRadius = cornerRadius
//        
//        // Format cell backgrounds
//        //if indexPath.row % 2 == 0 {
//        cell.backgroundColor = UIColor.clearColor()
//        //} else {
//        //    cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
//        //}
//        
//        // Tag vote and qZoom buttons
//        cell.vote1Button.tag = indexPath.row
//        cell.vote2Button.tag = indexPath.row
//        cell.questionZoom.tag = indexPath.row
//        
//        // Set askerPhoto
//        if let pic = askerPhotos[askers[indexPath.row]] {
//            cell.profilePicture.image = pic
//        }
//        
//        return cell
//    }
//    
//    
//    override func viewWillAppear(animated: Bool) {
//        self.tableView.reloadData()
//        
//        // MAKE FUNCTION -----------------------------------------------------------
//        // Recall deleted/dismissed data
////        if NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey) != nil {
////            deletedTheirQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey)! as! [(String)]
////        }
//        
////        if NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey) != nil {
////            myVotes = NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey)! as! Dictionary
////        }
//        
//        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey) != nil {
//            votedOn1Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted1StorageKey)! as! [(String)]
//        }
//        
//        if NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey) != nil {
//            votedOn2Ids = NSUserDefaults.standardUserDefaults().objectForKey(myVoted2StorageKey)! as! [(String)]
//        }
//        // MAKE FUNCTION -----------------------------------------------------------
//        
//        
//        // **********************************************************************************************
//        // Manually call refresh upon loading to get most up to datest datas
//        // - this needs to be skipped when push is allowed and used when push has been declined
//        //if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
//        
//        
//        if returningFromSettings == false && returningFromPopover == false {
//            
//            println("Page loaded from tab bar")
//            
//            topOffset = 64
//            
//            refresh()
//            
//        }
//        
//        if returningFromPopover {
//            
//            println("Returned from popover")
//            
//            returningFromPopover = false
//            
//            if theirViewReturnedOnce == false {
//                theirViewReturnedOnce = true
//                topOffset = 0
//            } else {
//                topOffset = 64
//            }
//            
//        }
//        
//        if returningFromSettings {
//            
//            println("Returned from settings")
//            
//            returningFromSettings = false
//            
//            topOffset = 0
//        }
//        
//        self.tableView.contentInset = UIEdgeInsetsMake(topOffset,0,52,0)  // T, L, B, R
//        
//        //    println("USER IS NOT SUBSCRIBED TO RELOADTHEIRTABLE")
//        //}
//        // **********************************************************************************************
//    }
//    
//    
//    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
//    func refresh() {
//        
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
//    }
//    
//    
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
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//}
