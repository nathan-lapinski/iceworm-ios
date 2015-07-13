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
    var option1sPhoto = [PFFile]()
    var option2sPhoto = [PFFile]()
    var option1Stats = [Int]()
    var option2Stats = [Int]()
    //var deletedMyQuestions = [String]() // questions DELETED by current user
    var deletedMyStorageKey = myName + "deletedMyPermanent"
    var refresher: UIRefreshControl!
    //var activityIndicator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        // Set table background image
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "bg_theirQs_reverse.png"))
        
        // Set separator color
        tableView.separatorColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Adjust top and bottom bounds of table for nav and tab bars
        self.tableView.contentInset = UIEdgeInsetsMake(20,0,48,0)  // Top, Left, Bottom, Right
        
        // Disable auto inset adjust
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    
    // Swipe to display options functions ----------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            myRequestedQId = self.questionIds[indexPath.row]
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.performSegueWithIdentifier("viewVotesMyQs", sender: self)
            })
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            println("share button tapped")
        }
        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Trash") { (action, index) -> Void in
            
            // Append qId to "deleted" array in database
            var deletedQuery = PFQuery(className: "UserQs")
            deletedQuery.whereKey("objectId", equalTo: uQId)
            
            deletedQuery.getObjectInBackgroundWithId(uQId, block: { (userQsObjects, error) -> Void in
                
                if error == nil {
                    
                    // Add Q to deleted
                    userQsObjects!.addUniqueObject(self.questionIds[indexPath.row], forKey: "deletedMyQsId")
                    userQsObjects!.saveInBackground()
                    
                    // Remove Q from myQs (my active Qs)
                    userQsObjects!.removeObject(self.questionIds[indexPath.row], forKey: "myQsId")
                    userQsObjects!.saveInBackground()
                    
                    
                    
                    
                    //deletedMyQuestions.append(self.questionIds[indexPath.row])
                    // Store updated array locally
                    //NSUserDefaults.standardUserDefaults().setObject(deletedMyQuestions, forKey: self.deletedMyStorageKey)
                    
                    
                    
                    
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
        
        return [trash, view] // Order = appearance order, right to left on screen
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
        
        /*
        // Recall deleted/dismissed data
        if NSUserDefaults.standardUserDefaults().objectForKey(deletedMyStorageKey) != nil {
            
            
            
            
            deletedMyQuestions = NSUserDefaults.standardUserDefaults().objectForKey(deletedMyStorageKey)! as! [(String)]
            
            
            
            
        }
        */
        
        // **********************************************************************************************
        // Manually call refresh upon loading to get most up to datest datas
        // - this needs to be skipped when push is allowed and used when push has been declined
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false { refresh() }
        
        // REMOVE LATER!!! ::
        refresh()
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
                                    
                                    println("Found Image File 1")
                                    self.option1s.append(photoString)
                                    self.option1sPhoto.append(questionObject["option1Photo"] as! PFFile)
                                    
                                }
                                
                                if let test = questionObject["option2"] as? String {
                                    
                                    self.option2s.append(questionObject["option2"] as! String)
                                    self.option2sPhoto.append(PFFile())
                                    
                                } else {
                                    
                                    println("Found Image File 2")
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
        
        var myCell = MyQuestionsCell()
        
        var totalResponses = option1Stats[indexPath.row] + option2Stats[indexPath.row]
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            
            option1Percent = Float(option1Stats[indexPath.row])/Float(totalResponses)*100
            option2Percent = Float(option2Stats[indexPath.row])/Float(totalResponses)*100
            
        }
        
        // Build "repsonse" string to account for singular/plural
        var resp = "responses"
        if totalResponses == 1 {
            resp = "response"
        }
        
        // Make cells non-selectable
        myCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Currently check if either (1) option photo is filled in and use photo for both
        if option1s[indexPath.row] == photoString { // PHOTO OPTIONS
            
            myCell = tableView.dequeueReusableCellWithIdentifier("myCell2", forIndexPath: indexPath) as! MyQuestionsCell
            
            myCell.question2.text = questions[indexPath.row]
            myCell.option1Text.text = "\(Int(option1Percent))%"
            myCell.option2Text.text = "\(Int(option2Percent))%"
            myCell.option1Text.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
            myCell.option2Text.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.6))
            myCell.option1Text.layer.cornerRadius = cornerRadius
            myCell.option2Text.layer.cornerRadius = cornerRadius
            myCell.numberOfResponses2.text = "\(totalResponses) \(resp)"
            
            option1sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data1, error1) -> Void in
                
                if let downloadedImage = UIImage(data: data1!) {
                
                    myCell.option1Photo.image = downloadedImage
                    
                }
            })
            
            option2sPhoto[indexPath.row].getDataInBackgroundWithBlock({ (data2, error2) -> Void in
                
                if let downloadedImage = UIImage(data: data2!) {
                    
                    myCell.option2Photo.image = downloadedImage
                    
                }
            })
            
            // Format cell backgrounds
            if indexPath.row % 2 == 0 { myCell.backgroundColor = UIColor.clearColor() }
            else { myCell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4) }
            
        } else { // TEXT OPTIONS
            
            myCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! MyQuestionsCell
            
            myCell.question.text = questions[indexPath.row]
            myCell.option1Text.text = option1s[indexPath.row] + "  \(Int(option1Percent))%"
            myCell.option2Text.text = option2s[indexPath.row] + "  \(Int(option2Percent))%"
            myCell.numberOfResponses.text = "\(totalResponses) \(resp)"

            // Compute and set results image view widths
            var width1 = myCell.option1ImageView.frame.width
            var width2 = myCell.option2ImageView.frame.width
            
            
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
            
            // Format cell backgrounds
            if indexPath.row % 2 == 0 {
                
                myCell.backgroundColor = UIColor.clearColor()
                
            } else {
                
                myCell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
                
            }
        }
        
        return myCell
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
