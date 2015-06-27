//
//  MyQuestionsTableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class MyQuestionsTableViewController: UITableViewController {

    var questions = [String]()
    var questionIds = [String]()
    var option1s = [String]()
    var option2s = [String]()
    var option1Stats = [Int]()
    var option2Stats = [Int]()
    var deletedQuestions = [String]() // questions DELETED by current user
    var dismissedStorageKey = myName + "dismissedMyPermanent"
    var deletedStorageKey = myName + "deletedMyPermanent"
    var refresher: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "splash_no_logo_reverse.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(12,0,48,0)
        // Disable auto inset adjust
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        /*
        let forward = UITableViewRowAction(style: .Normal, title: "Forward") { action, index in
            println("forward button tapped")
        }
        
        forward.backgroundColor = UIColor.grayColor()
        */
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            
            self.deletedQuestions.append(self.questionIds[indexPath.row])
            
            self.questions.removeAtIndex(indexPath.row)
            self.questionIds.removeAtIndex(indexPath.row)
            self.option1s.removeAtIndex(indexPath.row)
            self.option2s.removeAtIndex(indexPath.row)
            self.option1Stats.removeAtIndex(indexPath.row)
            self.option2Stats.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            // Store updated array locally
            NSUserDefaults.standardUserDefaults().setObject(self.deletedQuestions, forKey: self.deletedStorageKey)
            //println("refreshing table")
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
            
        }
        
        delete.backgroundColor = UIColor.redColor()
        
        return [delete]//, forward] // Order = appearance order, right to left on screen
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
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedStorageKey) != nil {
            
            deletedQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedStorageKey)! as! [(String)]
            
        }
        
        // Manually call refresh upon loading to get most up to datest datas
        refresh()
        
    }
    
    
    // ALL query stuff moved to this function so it can run under pull-to-refresh conditions
    func refresh() {
        
        var getSocialQsQuery = PFQuery(className: "SocialQs")
        
        // Sort by newest created-date first
        getSocialQsQuery.orderByDescending("createdAt")
        getSocialQsQuery.whereKey("askername", equalTo: myName)
        getSocialQsQuery.limit = 1000
        
        getSocialQsQuery.findObjectsInBackgroundWithBlock { (questionObjects, error) -> Void in
            
            if let questionTemp = questionObjects {
                
                self.questions.removeAll(keepCapacity: true)
                self.questionIds.removeAll(keepCapacity: true)
                self.option1s.removeAll(keepCapacity: true)
                self.option2s.removeAll(keepCapacity: true)
                self.option1Stats.removeAll(keepCapacity: true)
                self.option2Stats.removeAll(keepCapacity: true)
                
                for questionObject in questionTemp {
                    // Check for user == current user ------------------------------------
                    
                    // Filter out THEIR questions
                    //if questionObject["askername"] as! String == myName {
                        
                        // Filter out DELETED questions
                        if contains(self.deletedQuestions, questionObject.objectId!!) == false ||
                            self.deletedQuestions.count == 0 {

                            self.questions.append(questionObject["question"] as! String)
                            self.questionIds.append(questionObject.objectId!!)
                            self.option1s.append(questionObject["option1"] as! String)
                            self.option2s.append(questionObject["option2"] as! String)
                            self.option1Stats.append(questionObject["stats1"] as! Int)
                            self.option2Stats.append(questionObject["stats2"] as! Int)
                            
                        }
                    //}
                    
                    // Ensure all queries have completed THEN refresh the table!
                    if self.questions.count == self.option2Stats.count {
                        
                        self.tableView.reloadData()
                        self.tableView.reloadInputViews()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                        
                    }
                }
            }
        }
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
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! MyQuestionsCell
        
        // Make cells non-selectable
        myCell.selectionStyle = UITableViewCellSelectionStyle.None

        // Format cell backgrounds
        if indexPath.row % 2 == 0 {
            
            myCell.backgroundColor = UIColor.clearColor()
            
        } else {
            
            myCell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            
        }
        

        // Compute and set results image view widths
        var width1 = myCell.option1ImageView.frame.width
        var width2 = myCell.option2ImageView.frame.width
        
        var totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            
            option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
            option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
            
        }
        
        myCell.question.text = questions[indexPath.row]
        myCell.option1Text.text = option1s[indexPath.row] + "  \(Int(option1Percent))%"
        myCell.option2Text.text = option2s[indexPath.row] + "  \(Int(option2Percent))%"
        
        var resp = "responses"
        if totalResponses == 1 {
            resp = "response"
        }
        
        myCell.numberOfResponses.text = "\(totalResponses) \(resp)"
        
        if option1Percent > option2Percent {
            
            width1 = CGFloat(myCell.option1ImageView.bounds.width)
            width2 = CGFloat(Float(width1)/(option1Percent/100)*(1 - (option1Percent/100)))
            myCell.option1ImageView.backgroundColor = winColor
            myCell.option2ImageView.backgroundColor = loseColor
            
        } else if option2Percent > option1Percent {
            
            width2 = CGFloat(myCell.option2ImageView.bounds.width)
            width1 = CGFloat(Float(width2)/(option2Percent/100)*(1 - (option2Percent/100)))
            myCell.option1ImageView.backgroundColor = winColor
            myCell.option2ImageView.backgroundColor = loseColor
            
        } else {
            
            width1 = CGFloat(myCell.option1ImageView.bounds.width)
            width2 = width1
            myCell.option1ImageView.backgroundColor = winColor
            myCell.option2ImageView.backgroundColor = winColor
            
        }
        
        //myCell.option1ImageView.bounds = CGRectMake(myCell.option1ImageView.bounds.origin.x, myCell.option1ImageView.bounds.origin.y, CGFloat(width1), myCell.option1ImageView.bounds.height)
        //myCell.option2ImageView.bounds = CGRectMake(myCell.option2ImageView.bounds.origin.x, myCell.option2ImageView.bounds.origin.y, CGFloat(width2), myCell.option2ImageView.bounds.height)
        
        return myCell
    }
    
    
    /*
    // Interaction when tapping on row (ie: view results)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get cell that has been tapped on
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        
        
        let followedObjectId = userids[indexPath.row]
        
        // Check if already following and UNFOLLOW instead
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var follow = PFObject(className: "Follow")
            follow["following"] = userids[indexPath.row]
            follow["follower"] = PFUser.currentUser()?.objectId
            
            // This has to be here or the "delete" section creates an empty entry in the DB
            follow.saveInBackground()
            
        } else {
            
            isFollowing[followedObjectId] = false
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            // Check if this user is being following by the current user
            var query = PFQuery(className: "Follow")
            
            // Set query keys
            // Error here was from the login check not functioning properly, so
            // we reached this point even though we weren't logged in
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            // This happen in random order, so we can't guarantee the results will
            // match the local arrays that determine who is following whom! (username/userids)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                // if objects = objects it must be the case that this user is being followed
                if let temp = objects {
                    
                    for object in temp {
                        
                        object.deleteInBackground()
                        
                    }
                }
            })
        }
    
        
        
    }
    */
    

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
