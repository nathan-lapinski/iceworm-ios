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
    var dismissedQuestions = [String]() // questions ANSWERED by current user
    var deletedQuestions = [String]() // questions DELETED by current user
    var dismissedStorageKey = myName + "dismissedTheirPermanent"
    var deletedStorageKey = myName + "deletedTheirPermanent"
    var refresher: UIRefreshControl!
    
    @IBAction func voteOption1(sender: AnyObject) {
        
        dismissedQuestions.append(questionIds[sender.tag])
        
        // Store updated array locally
        NSUserDefaults.standardUserDefaults().setObject(dismissedQuestions, forKey: dismissedStorageKey)
        
        castVote(sender.tag, optionId: 1)
        
    }
    
    
    @IBAction func voteOption2(sender: AnyObject) {
        
        dismissedQuestions.append(questionIds[sender.tag])
        
        // Store updated array locally
        NSUserDefaults.standardUserDefaults().setObject(dismissedQuestions, forKey: dismissedStorageKey)
        
        castVote(sender.tag, optionId: 2)
        
    }
    
    
    // Function to process the casting of votes
    func castVote(questionId: Int, optionId: Int) {
        
        var voteId = "stats\(optionId)"
        
        var query = PFQuery(className: "SocialQs")
        
        query.whereKey("objectId", equalTo: questionIds[questionId])
        
        query.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
            
            if error == nil {
                
                if let temp = questionObjects {
                    
                    for questionObject in temp {
                        
                        // Increment vote counter --------------------------------
                        var statsQuery = PFQuery(className: "SocialQs")
                        
                        statsQuery.getObjectInBackgroundWithId(questionObject.objectId!!, block: { (object, error) -> Void in
                            
                            object!.incrementKey(voteId)
                            object!.saveInBackgroundWithBlock {
                                
                                (success: Bool, error: NSError?) -> Void in
                                if (success) { // The score key has been incremented
                                    
                                    //println("refreshing table")
                                    self.refresh()
                                    self.tableView.reloadData()
                                    self.tableView.reloadInputViews()
                                    
                                } else { // There was a problem, check error.description
                                    
                                    println("Increment error:")
                                    println(error)
                                    
                                }
                            }
                        })
                    }
                }
                
            } else {
                
                println("SocialQs query error:")
                println(error)
                
            }
        }
        
    }


    
    /*
    @IBAction func deleteQuestions(sender: AnyObject) {
        
        deletedQuestions.append(questionIds[sender.tag])
        
        // Store updated array locally
        NSUserDefaults.standardUserDefaults().setObject(deletedQuestions, forKey: deletedStorageKey)
        
        refresh()
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        
    }
    */

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg_theirQs.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.whiteColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(12,0,48,0)
        // Disable auto inset adjust
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    
    // Delete functionality
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            deletedQuestions.append(questionIds[indexPath.row])
            
            self.questionIds.removeAtIndex(indexPath.row)
            self.questions.removeAtIndex(indexPath.row)
            self.option1s.removeAtIndex(indexPath.row)
            self.option2s.removeAtIndex(indexPath.row)
            self.option1Stats.removeAtIndex(indexPath.row)
            self.option2Stats.removeAtIndex(indexPath.row)
            self.askers.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
        }
        
        // Store updated array locally
        NSUserDefaults.standardUserDefaults().setObject(deletedQuestions, forKey: deletedStorageKey)
        
        //println("refreshing table")
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        
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
        
        var cell = TheirQuestionsCell()//.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! TheirQuestionsCell
        
        if contains(self.dismissedQuestions, questionIds[indexPath.row]) == true {
            
            // Already voted setup
            cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! TheirQuestionsCell
            
            // Make cells non-selectable
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Format buttons
            cell.dismiss.layer.cornerRadius = cornerRadius
            cell.forward.layer.cornerRadius = cornerRadius
            cell.dismiss.backgroundColor = bgColor
            cell.forward.backgroundColor = bgColor
            
            // Compute and set results image view widths - MAKE GLOBAL CLASS w/ METHOD
            var width1 = cell.option1ImageView.frame.width
            var width2 = cell.option2ImageView.frame.width
            
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
                
                width1 = CGFloat(cell.option1ImageView.bounds.width)
                width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
                cell.option1ImageView.backgroundColor = bgColor
                cell.option2ImageView.backgroundColor = loseColor
                
            } else if option2Percent > option1Percent {
                
                width2 = CGFloat(cell.option2ImageView.bounds.width)
                width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
                cell.option1ImageView.backgroundColor = bgColor
                cell.option2ImageView.backgroundColor = loseColor
                
            } else {
                
                width1 = CGFloat(cell.option1ImageView.bounds.width)
                width2 = width1
                cell.option1ImageView.backgroundColor = bgColor
                cell.option2ImageView.backgroundColor = bgColor
                
            }
            
            // Tag buttons
            cell.delete.tag = indexPath.row
            
        } else {
            
            // Yet to vote setup
            cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! TheirQuestionsCell
            
            // Make cells non-selectable
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Format buttons
            cell.option1.enabled = true
            cell.option2.enabled = true
            cell.option1.layer.cornerRadius = cornerRadius
            cell.option2.layer.cornerRadius = cornerRadius
            cell.option1.backgroundColor = bgColor
            cell.option2.backgroundColor = bgColor
            cell.option1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            cell.option2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
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
        
        // Recall deleted/dismissed data
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedStorageKey) != nil {
            
            deletedQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedStorageKey)! as! [(String)]
            
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(dismissedStorageKey) != nil {
            
            dismissedQuestions = NSUserDefaults.standardUserDefaults().objectForKey(dismissedStorageKey)! as! [(String)]
            
        }
        
        // Manually call refresh upon loading to get most up to datest datas
        refresh()
        
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        var getSocialQsQuery = PFQuery(className: "SocialQs")
        
        // Sort by newest created-date first
        getSocialQsQuery.orderByDescending("createdAt")
        
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
                    
                    // Filter out MY questions
                    if questionObject["askername"] as! String != myName {
                        
                        // Filter out DELETED questions
                        if contains(self.deletedQuestions, questionObject.objectId!!) == false {
                            
                            self.questionIds.append(questionObject.objectId!!)
                            self.questions.append(questionObject["question"] as! String)
                            self.option1s.append(questionObject["option1"] as! String)
                            self.option2s.append(questionObject["option2"] as! String)
                            self.option1Stats.append(questionObject["stats1"] as! Int)
                            self.option2Stats.append(questionObject["stats2"] as! Int)
                            self.askers.append(questionObject["askername"] as! String)
                            
                        }
                    }
                    
                    // Ensure all queries have completed THEN refresh the table!
                    if self.questions.count == self.askers.count {
                        
                        self.tableView.reloadData()
                        self.tableView.reloadInputViews()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                        
                    }
                }
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

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
