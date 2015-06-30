//
//  TheirQuestionsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/16/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class TheirQuestionsTableViewController: UITableViewController {
    
    var questionIds = [String]()
    var questions = [String]()
    var option1s = [String]()
    var option2s = [String]()
    var option1Stats = [Int]()
    var option2Stats = [Int]()
    //var users = [String: String]()
    var askers = [String]()
    // Variable to track how user voted - store to NSUserDefaults //
    var myVotes = Dictionary<String, Int>()
    var dismissedTheirStorageKey = myName + "dismissedTheirPermanent"
    var deletedTheirStorageKey = myName + "deletedTheirPermanent"
    var myVotesStorageKey = myName + "votes"
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    
    @IBAction func voteOption1(sender: AnyObject) {
        
        castVote(sender.tag, optionId: 1)
        
    }
    
    
    @IBAction func voteOption2(sender: AnyObject) {
        
        castVote(sender.tag, optionId: 2)
        
    }
    
    
    // Function to process the casting of votes
    func castVote(questionId: Int, optionId: Int) {
        
        var voteId = "stats\(optionId)" // remove??
        
        // Update internal and local storage of "myVotes"
        myVotes[questionIds[questionId]] = optionId
        NSUserDefaults.standardUserDefaults().setObject(myVotes, forKey: self.myVotesStorageKey)
        
        // Query Q table to get vote table Id
        // The access Vote table and do stuffs
        var query = PFQuery(className: "SocialQs")
        
        query.whereKey("objectId", equalTo: questionIds[questionId])
        query.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
            
            if error == nil {
                
                // ------------------------------------------------------------------------------------
                // All this logic is not necessary - need to figure out how to unwrap "questionObjects"
                // Only one item should exist when pulled with this whereKey to no for loop needed.
                // ------------------------------------------------------------------------------------
                
                if let temp = questionObjects {
                    
                    for questionObject in temp {
                        
                        var vId = questionObject["votesId"]!! as! String
                        
                        var votesQuery = PFQuery(className: "Votes")
                        votesQuery.whereKey("objectId", equalTo: vId)
                        
                        votesQuery.getObjectInBackgroundWithId(vId, block: { (voteObjects, error) -> Void in
                            
                            if error == nil {
                                
                                voteObjects!.addObject(uId, forKey: "voterId")
                                voteObjects!.saveInBackground()
                                voteObjects!.addObject([myName], forKey: "voterName")
                                voteObjects!.saveInBackground()
                                voteObjects!.addObject([optionId], forKey: "vote")
                                voteObjects!.saveInBackground()
                                
                                // Store updated array locally
                                dismissedTheirQuestions.append(questionObject.objectId!!)
                                NSUserDefaults.standardUserDefaults().setObject(dismissedTheirQuestions, forKey: self.dismissedTheirStorageKey)
                                
                                // Update table row
                                var indexPath = NSIndexPath(forRow: questionId, inSection: 0)
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                                
                            } else {
                                
                                println("Votes Table query error")
                                println(error)
                                
                            }
                            
                        })
                        
                        
                        /*
                        votesQuery.getObjectInBackgroundWithId(vId, block: { (voteObject, error) -> Void in
                            
                            if error == nil {
                            
                                println("Doing votey stuffs")
                                
                                voteObject!.addObject([uId], forKey: "voterId")
                                voteObject!.addObject([myName], forKey: "voterName")
                                voteObject!.addObject([optionId], forKey: "vote")
                                
                                // Store updated array locally
                                self.dismissedQuestions.append(questionObject.objectId!!)
                                NSUserDefaults.standardUserDefaults().setObject(self.dismissedQuestions, forKey: self.dismissedStorageKey)
                                
                            }
                        })
                        */
                        
                        
                        // REMOVE THIS AND REWORK TABLE UPDATE MATH TO USE "VOTES" TABLE + VOTE[INT]
                        // Increment vote counter ---------------------------------
                        var statsQuery = PFQuery(className: "SocialQs")
                        
                        statsQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (object, error) -> Void in
                            
                            object!.incrementKey(voteId)
                            object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                
                                if (success) { // The score key has been incremented
                                    
                                    //println("reloading table")
                                    //self.tableView.reloadData()
                                    //self.tableView.reloadInputViews()
                                    
                                    
                                    // ---------------------------------------------------------------------------------------------------------------
                                    // Database vote values haven't come down by the time the increment occurs so we repoll this row and update
                                    var singleQuery = PFQuery(className: "SocialQs")
                                    
                                    singleQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (singleObjects, singleError) -> Void in
                                        
                                        if let singleIndex = find(self.questionIds, questionObject.objectId!!) {
                                            
                                            self.option1Stats[singleIndex] = singleObjects!["stats1"]! as! Int
                                            self.option2Stats[singleIndex] = singleObjects!["stats2"]! as! Int
                                            
                                            /* MOVED ABOVE!!
                                            // Update table row
                                            var indexPath = NSIndexPath(forRow: questionId, inSection: 0)
                                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                                            */
                                            
                                        }
                                    })
                                    // ---------------------------------------------------------------------------------------------------------------
                                    
                                } else { // There was a problem, check error.description
                                    
                                    println("Increment error:")
                                    println(error)
                                    
                                }
                            }
                        })
                        // REMOVE THIS AND REWORK TABLE UPDATE MATH TO USE "VOTES" TABLE + VOTE[INT]
                    }
                }
                
            } else {
                
                println("SocialQs Table query error:")
                println(error)
                
            }
        }
    }

    
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let more = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "More") { (action, index) -> Void in
            println("more button tapped")
        }
        more.backgroundColor = UIColor.orangeColor()
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
            
          deletedTheirQuestions.append(self.questionIds[indexPath.row])
            
            self.questionIds.removeAtIndex(indexPath.row)
            self.questions.removeAtIndex(indexPath.row)
            self.option1s.removeAtIndex(indexPath.row)
            self.option2s.removeAtIndex(indexPath.row)
            self.option1Stats.removeAtIndex(indexPath.row)
            self.option2Stats.removeAtIndex(indexPath.row)
            self.askers.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            // Store updated array locally
            NSUserDefaults.standardUserDefaults().setObject(deletedTheirQuestions, forKey: self.deletedTheirStorageKey)
            //println("refreshing table")
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
            
        }
        
        trash.backgroundColor = UIColor.redColor()
        
        return [trash, share, more] // Order = appearance order, right to left on screen
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
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "splash_no_logo.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(12,0,48,0)
        // Disable auto inset adjust
        self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        var cell = TheirQuestionsCell()
        
        let maxBarWidth = cell.contentView.bounds.width// - 2*(8) // CHANGE 8 to NSLayout leading
        
        if contains(dismissedTheirQuestions, questionIds[indexPath.row]) == true { // Already voted setup
            
            cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! TheirQuestionsCell
            
            // Make cells non-selectable
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Compute and set results image view widths - MAKE GLOBAL CLASS w/ METHOD
            var width1 = maxBarWidth //cell.option1ImageView.bounds.width
            var width2 = maxBarWidth //cell.option2ImageView.bounds.width
            
            var totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
            var option1Percent = Float(0.0)
            var option2Percent = Float(0.0)
            
            if totalResponses != 0 {
                
                option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
                option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
                
            }
            
            cell.question.text = questions[indexPath.row]
            cell.option1Text.text = option1s[indexPath.row] + "  \(Int(option1Percent))%"
            cell.option2Text.text = option2s[indexPath.row] + "  \(Int(option2Percent))%"
            
            var resp = "responses"
            if totalResponses == 1 {
                
                resp = "response"
                
            }
            
            cell.numberOfResponses.text = "\(totalResponses) \(resp)"
            
            if option1Percent > option2Percent {
                
                width1 = maxBarWidth
                width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
                cell.option1ImageView.backgroundColor = winColor
                cell.option2ImageView.backgroundColor = loseColor
                
            } else if option2Percent > option1Percent {
                
                width2 = maxBarWidth
                width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
                cell.option1ImageView.backgroundColor = loseColor
                cell.option2ImageView.backgroundColor = winColor
                
            } else {
                
                //cell.bar1Width.constant = 10//width1/10000
                //cell.layoutIfNeeded()
                //cell.bar2Width.constant = width2/10000
                //cell.layoutIfNeeded()
                
                //width1 = maxBarWidth
                //width2 = maxBarWidth
                //cell.option1ImageView.backgroundColor = winColor
                //cell.option2ImageView.backgroundColor = winColor
                
            }
            
            //println(width1)
            //println(width2)
            
            //cell.option1ImageView.frame = CGRectMake(cell.option1ImageView.frame.origin.x, cell.option1ImageView.frame.origin.y, width1, cell.option1ImageView.frame.height)
            //cell.option2ImageView.frame = CGRectMake(cell.option2ImageView.frame.origin.x, cell.option2ImageView.frame.origin.y, width2, cell.option2ImageView.frame.height)
            
            
            // Color user's choice
            if myVotes[questionIds[indexPath.row]] == 1 {
                
                cell.myVote1.text = "✔"
                cell.myVote2.text = ""
                
            } else {
                
                cell.myVote2.text = "✔"
                cell.myVote1.text = ""
                
            }
            
        } else { // Yet to vote setup
            
            cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! TheirQuestionsCell
            
            // Make cells non-selectable
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Format buttons
            cell.option1.enabled = true
            cell.option2.enabled = true
            cell.option1.layer.cornerRadius = cornerRadius
            cell.option2.layer.cornerRadius = cornerRadius
            cell.option1.backgroundColor = buttonBackgroundColor
            cell.option2.backgroundColor = buttonBackgroundColor
            cell.option1.setTitleColor(buttonTextColor, forState: UIControlState.Normal)
            cell.option2.setTitleColor(buttonTextColor, forState: UIControlState.Normal)
            cell.option1.titleLabel?.numberOfLines = 0 // Dynamic number of lines
            cell.option2.titleLabel?.numberOfLines = 0 // Dynamic number of lines
            cell.option1.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.option2.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.option1.titleEdgeInsets = buttonEdge
            cell.option2.titleEdgeInsets = buttonEdge
            cell.option1.titleLabel?.textAlignment = NSTextAlignment.Center
            cell.option2.titleLabel?.textAlignment = NSTextAlignment.Center
            
            // Format/Set text
            cell.option1.setTitle(option1s[indexPath.row], forState: UIControlState.Normal)
            cell.option2.setTitle(option2s[indexPath.row], forState: UIControlState.Normal)
            
            // Tag buttons
            cell.option1.tag = indexPath.row
            cell.option2.tag = indexPath.row
            
        }
        
        cell.question.numberOfLines = 0 // Dynamic number of lines
        cell.question.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.question.text = questions[indexPath.row]
        cell.asker.text = "Asked by " + askers[indexPath.row]
        
        // Format cell backgrounds
        if indexPath.row % 2 == 0 {
            
            cell.backgroundColor = UIColor.clearColor()
            
        } else {
            
            cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            
        }
        
        return cell
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
        // MAKE FUNCTION -----------------------------------------------------------
        // Recall deleted/dismissed data
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey) != nil {
            
            deletedTheirQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedTheirStorageKey)! as! [(String)]
            
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(dismissedTheirStorageKey) != nil {
            
            dismissedTheirQuestions = NSUserDefaults.standardUserDefaults().objectForKey(dismissedTheirStorageKey)! as! [(String)]
            
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey) != nil {
            
            myVotes = NSUserDefaults.standardUserDefaults().objectForKey(myVotesStorageKey)! as! Dictionary
            
        }
        // MAKE FUNCTION -----------------------------------------------------------
        
        // Setup spinner and black application input
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // Manually call refresh upon loading to get most up to datest datas
        refresh()
        
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        var getSocialQsQuery = PFQuery(className: "SocialQs")
        
        // Sort by newest created-date first
        getSocialQsQuery.orderByDescending("createdAt")
        
        // implement the following whereKey to filter myQs OUT of this list
        getSocialQsQuery.whereKey("askername", notEqualTo: myName)
        
        // Add whereKey for deleted/dismissed Qs here
        // Will also need myQs deleted info
        // Global vars??
        //
        
        getSocialQsQuery.limit = 1000
        
        getSocialQsQuery.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
            
            if let questionTemp = questionObjects {
                
                self.questionIds.removeAll(keepCapacity: true)
                self.questions.removeAll(keepCapacity: true)
                self.option1s.removeAll(keepCapacity: true)
                self.option2s.removeAll(keepCapacity: true)
                self.option1Stats.removeAll(keepCapacity: true)
                self.option2Stats.removeAll(keepCapacity: true)
                self.askers.removeAll(keepCapacity: true)
                
                for questionObject in questionTemp {
                        
                    // Filter out DELETED questions (also need DELETED from myQs tab!!!!)
                    //
                    //
                    //
                    if contains(deletedTheirQuestions, questionObject.objectId!!) == false { // && contains(self.dismissedQuestions, questionObject.objectId!!) {
                        
                        self.questionIds.append(questionObject.objectId!!)
                        self.questions.append(questionObject["question"] as! String)
                        self.option1s.append(questionObject["option1"] as! String)
                        self.option2s.append(questionObject["option2"] as! String)
                        self.option1Stats.append(questionObject["stats1"] as! Int)
                        self.option2Stats.append(questionObject["stats2"] as! Int)
                        self.askers.append(questionObject["askername"] as! String)
                        
                    }
                    
                    // Ensure all queries have completed THEN refresh the table!
                    if self.questions.count == self.askers.count {
                        
                        self.tableView.reloadData()
                        self.tableView.reloadInputViews()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                        
                        // Stop animation - hides when stopped (above) hides spinner automatically
                        self.activityIndicator.stopAnimating()
                        
                        // Release app input
                        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
