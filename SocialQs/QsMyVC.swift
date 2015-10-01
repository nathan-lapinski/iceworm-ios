//
//  QsMyVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsMyVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MyTableViewCellDelegate {
    
    var alreadyRetrievedMyQs = [String]()
    
    var QJoinObjects: [AnyObject] = []
    var refresher: UIRefreshControl!
    var myQsSpinner = UIView()
    var myQsBlurView = globalBlurView()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate Push Notifications
        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge |  UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        tableView.backgroundColor = UIColor.clearColor()
        
        // Create observer to montior for return from sequed push view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMyQs", name: "refreshMyQs", object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(QSMyCellNEW.self, forCellReuseIdentifier: "cell")
    }
    
    func refreshMyQs() {
        println("REFRESHING POST-ASK")
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //        if returningFromSettings == false && returningFromPopover == false {
        //
        //            println("Page loaded from tab bar")
        //
        //            topOffset = 64
        //
        refresh()
        //        }
        //
        //        if returningFromPopover {
        //
        //            println("Returned from popover")
        //
        //            returningFromPopover = false
        //
        //            if myViewReturnedOnce == false {
        //                myViewReturnedOnce = true
        //                topOffset = 0
        //            } else {
        //                topOffset = 64
        //            }
        //
        //            tableView.reloadData()
        //        }
        //
        //        if returningFromSettings {
        //
        //            println("Returned from settings")
        //
        //            returningFromSettings = false
        //
        //            topOffset = 0
        //
        //            tableView.reloadData()
        //        }
        //
        //        self.tableView.contentInset = UIEdgeInsetsMake(topOffset,0,52,0)  // T, L, B, R
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return QJoinObjects.count }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSMyCellNEW
        
        cell.delegate = self
        cell.QObject = QJoinObjects[indexPath.row] as! PFObject
        
        return cell
    }
    
    
    //func toDoItemDeleted(){ }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = self.QJoinObjects[indexPath.row] as? PFObject
            
            self.performSegueWithIdentifier("viewVotesMyQs", sender: self)
            
            self.tableView.setEditing(false, animated: true)
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        //        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
        //
        //            println("share button tapped")
        //        }
        //        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
            
            let object = self.QJoinObjects[indexPath.row] as! PFObject
            
            object.setObject(true, forKey: "deleted")
            
            //object["deleted"] = true
            
            object.unpinInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    println("question unpinned")
                    
                    object.saveEventually({ (success, error) -> Void in
                        
                        if error == nil {
                            
                            println("Question updated to be labeled as deleted on SERVER")
                            
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
            
//            object.saveInBackgroundWithBlock({ (success, error) -> Void in
//            
//                if error == nil {
//                    println("Q delete status updated on server")
//                }
//                
//            })
            
            self.QJoinObjects.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
        trash.backgroundColor = UIColor.redColor()
        
        println("Swiped MY row: \(indexPath.row)")
        
        if indexPath.row > -1 {
            if self.QJoinObjects[indexPath.row]["vote"] != nil {
                
                return [trash, view] // Order = appearance order, right to left on screen
                
            } else {
                
                return [trash] // Order = appearance order, right to left on screen
            }
            
        } else {
            
            return []
        }
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = UIColor.clearColor()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    func segueToZoom() {
        self.performSegueWithIdentifier("zoomMyPhotoSegue", sender: self)
    }
    
    
    func refresh() {
        
        QJoinObjects.removeAll(keepCapacity: true)
        
        var qQueryLocal = PFQuery(className: "QJoin")
        qQueryLocal.fromLocalDatastore()
        qQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
        qQueryLocal.whereKey("asker", equalTo: PFUser.currentUser()!)
        qQueryLocal.orderByDescending("createdAt")
        qQueryLocal.whereKey("deleted", equalTo: false)
        qQueryLocal.includeKey("asker")
        qQueryLocal.includeKey("question")
        qQueryLocal.limit = 1000
        
        qQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                self.QJoinObjects = objects!
                
                for temp in objects! {
                    if temp.objectId! != nil {
                        self.alreadyRetrievedMyQs.append(temp.objectId!!)
                    }
                }
                
                // Get Qs that are not in localdata store
                var qQueryServer = PFQuery(className: "QJoin")
                qQueryServer.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
                qQueryServer.whereKey("asker", equalTo: PFUser.currentUser()!)
                qQueryServer.whereKey("objectId", notContainedIn: self.alreadyRetrievedMyQs)
                qQueryServer.orderByDescending("createdAt")
                qQueryServer.whereKey("deleted", equalTo: false)
                qQueryServer.includeKey("asker")
                qQueryServer.includeKey("question")
                qQueryServer.limit = 1000
                
                qQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        
                        // Append to local array of PFObjects
                        self.QJoinObjects = self.QJoinObjects + objects!
                        
                        // Pin new Qs to local datastore
                        if let temp = objects as? [PFObject] {
                            
                            for object in temp {
                                
                                object.pinInBackgroundWithBlock { (success, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        println("My Qs QJoin Object \(object.objectId!) pinned!")
                                    }
                                    
//                                    if let test = object.objectId {
//                                        self.alreadyRetrievedMyQs.append(test)
//                                    }
                                }
                            }
                        }
                        
                        if self.QJoinObjects.count < 1 {
                            
                            self.buildNoQsQuestion()
                        }
                        
                        // Reload table data
                        self.tableView.reloadData()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                        
                    } else {
                        
                        println("There was an error retrieving new Qs from the database:")
                        println(error)
                        
                        if self.QJoinObjects.count < 1 {
                            
                            self.buildNoQsQuestion()
                        }
                        
                        // Reload table data
                        self.tableView.reloadData()
                        
                        // Kill refresher when query finished
                        self.refresher.endRefreshing()
                    }
                })
                
            } else {
                
                println("There was an error loading Qs from local data store:")
                println(error)
            }
        }
    }
    
    
    func buildNoQsQuestion() {
        
        // Build a temp question when none are available
        QJoinObjects.removeAll(keepCapacity: true)
            
        println("NO QS!!")
        
        var noQsJoinObject = PFObject(className: "QJoin")
        var noQsQuestionObject = PFObject(className: "SocialQs")
        var noQsAskerObject = PFObject(className: "User")
        
        let profImageData = UIImagePNGRepresentation(UIImage(named: "arrowToAsk.png"))
        var profImageFile: PFFile = PFFile(name: "arrowToAsk.png", data: profImageData)
        noQsAskerObject.setObject(profImageFile, forKey: "profilePicture")
        noQsAskerObject.setObject("SocialQs Team", forKey: "username")
        
        noQsQuestionObject.setObject("Use the ASK button to create a Q!", forKey: "questionText")
        noQsQuestionObject.setObject("Tap any of the images or arrows to zoom...", forKey: "option1Text")
        noQsQuestionObject.setObject("...or drag the image or arrow to the right to cast your vote!", forKey: "option2Text")
        
        let qImageData = UIImagePNGRepresentation(UIImage(named: "logo_square_blueS.png"))
        var qImageFile: PFFile = PFFile(name: "questionPicture.png", data: qImageData)
        noQsQuestionObject.setObject(qImageFile, forKey: "questionPhotoThumb")
        
        let o1ImageData = UIImagePNGRepresentation(UIImage(named: "logo_square_blueS.png"))
        var o1ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o1ImageData)
        noQsQuestionObject.setObject(o1ImageFile, forKey: "option1PhotoThumb")
        
        let o2ImageData = UIImagePNGRepresentation(UIImage(named: "logo_square_blueS.png"))
        var o2ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o2ImageData)
        noQsQuestionObject.setObject(o2ImageFile, forKey: "option2PhotoThumb")
        
        noQsQuestionObject.setObject(qImageFile, forKey: "questionPhoto")
        noQsQuestionObject.setObject(o1ImageFile, forKey: "option1Photo")
        noQsQuestionObject.setObject(o2ImageFile, forKey: "option2Photo")
        
        noQsQuestionObject.setObject(0, forKey: "option1Stats")
        noQsQuestionObject.setObject(0, forKey: "option2Stats")
        
        noQsJoinObject.setObject(noQsQuestionObject, forKey: "question")
        noQsJoinObject.setObject(noQsAskerObject, forKey: "asker")
        
        self.QJoinObjects = [noQsJoinObject]
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
