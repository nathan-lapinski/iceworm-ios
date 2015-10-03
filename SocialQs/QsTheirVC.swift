//
//  QsTheirVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/4/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsTheirVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TheirTableViewCellDelegate {
    
    var alreadyRetrieved = [String]()
    
    var QJoinObjects: [AnyObject] = []
    var refresher: UIRefreshControl!
    var myQsSpinner = UIView()
    var myQsBlurView = globalBlurView()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull to refresh --------------------------------------------------------
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Pull to refresh --------------------------------------------------------
        
        backgroundImageView.image = UIImage(named: "bg5.png")
        tableView.backgroundColor = UIColor.clearColor()
        
        // Create observer to montior for return from sequed push view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTheirQs", name: "refreshTheirQs", object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(QSTheirCellNEW.self, forCellReuseIdentifier: "cell")
    }
    
    func refreshTheirQs() {
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSTheirCellNEW
        
        cell.delegate = self
        cell.QJoinObject = QJoinObjects[indexPath.row] as! PFObject
        
        return cell
    }
    
    
    //func toDoItemDeleted(){ }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = self.QJoinObjects[indexPath.row]["question"]!! as? PFObject
            
            self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
            
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
            
            object["deleted"] = true
            
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
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = UIColor.clearColor()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    func segueToZoom() {
        self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: self)
    }
    
    
    func refresh() {
        
        QJoinObjects.removeAll(keepCapacity: true)
        
        var qJoinQueryLocal = PFQuery(className: "QJoin")
        qJoinQueryLocal.fromLocalDatastore()
        qJoinQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
        qJoinQueryLocal.whereKey("asker", notEqualTo: PFUser.currentUser()!)
        qJoinQueryLocal.orderByDescending("createdAt")
        qJoinQueryLocal.whereKey("deleted", equalTo: false)
        qJoinQueryLocal.includeKey("asker")
        qJoinQueryLocal.includeKey("question")
        qJoinQueryLocal.limit = 1000
        
        qJoinQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                self.QJoinObjects = objects!
                
                for temp in objects! {
                    if temp.objectId! != nil {
                        self.alreadyRetrieved.append(temp.objectId!!)
                    }
                }
                
                // Get Qs that are not in localdata store
                var qJoinQueryServer = PFQuery(className: "QJoin")
                qJoinQueryServer.whereKey("to", equalTo: PFUser.currentUser()!["facebookId"] as! String)
                qJoinQueryServer.whereKey("asker", notEqualTo: PFUser.currentUser()!)
                if self.alreadyRetrieved.count > 0 {
                    qJoinQueryServer.whereKey("objectId", notContainedIn: self.alreadyRetrieved)
                }
                qJoinQueryServer.orderByDescending("createdAt")
                qJoinQueryServer.whereKey("deleted", equalTo: false)
                qJoinQueryServer.includeKey("asker")
                qJoinQueryServer.includeKey("question")
                qJoinQueryServer.limit = 1000
                
                qJoinQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        
                        // Append to local array of PFObjects
                        self.QJoinObjects = self.QJoinObjects + objects!
                        
                        // Pin new Qs to local datastore
                        if let temp = objects as? [PFObject] {
                            
                            for object in temp {
                                
                                object.pinInBackgroundWithBlock { (success, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        println("Their Qs QJoin Object \(object.objectId!) pinned!")
                                    }
                                    
//                                    if let test = object.objectId {
//                                        self.alreadyRetrieved.append(test)
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
        
        println("NO THEIRQS!!")
        
        var noQsJoinObject = PFObject(className: "QJoin")
        var noQsQuestionObject = PFObject(className: "SocialQs")
        var noQsPhotoJoinQObject = PFObject(className: "PhotoJoin")
        var noQsPhotoJoin1Object = PFObject(className: "PhotoJoin")
        var noQsPhotoJoin2Object = PFObject(className: "PhotoJoin")
        var noQsAskerObject = PFObject(className: "User")
        
        let profImageData = UIImagePNGRepresentation(UIImage(named: "logo_square_blueS.png"))
        var profImageFile: PFFile = PFFile(name: "logo_square_blueS.png", data: profImageData)
        noQsAskerObject.setObject(profImageFile, forKey: "profilePicture")
        noQsAskerObject.setObject("SocialQs Team", forKey: "name")
        
        noQsQuestionObject.setObject("No Qs! Don't you have friends?", forKey: "questionText")
        noQsQuestionObject.setObject("I don't 😥, but I'll invite some!", forKey: "option1Text")
        noQsQuestionObject.setObject("I do 😃, but I'll invite more!", forKey: "option2Text")
        
        let qImageData = UIImagePNGRepresentation(UIImage(named: "scenery3.png"))
        var qImageFile: PFFile = PFFile(name: "questionPicture.png", data: qImageData)
        
        var o1ImageData = NSData()
        if arc4random_uniform(2) == 0 {
            o1ImageData = UIImagePNGRepresentation(UIImage(named: "sadNate.png"))
        } else {
            o1ImageData = UIImagePNGRepresentation(UIImage(named: "sadBrett.png"))
            }
        var o1ImageFile: PFFile = PFFile(name: "option1Picture.png", data: o1ImageData)
        
        var o2ImageData = NSData()
        if arc4random_uniform(2) == 0 {
            o2ImageData = UIImagePNGRepresentation(UIImage(named: "happyNate.png"))
        } else {
            o2ImageData = UIImagePNGRepresentation(UIImage(named: "happyBrett.png"))
        }
        var o2ImageFile: PFFile = PFFile(name: "option2Picture.png", data: o2ImageData)
        
        noQsPhotoJoinQObject.setObject(qImageFile, forKey: "thumb")
        noQsPhotoJoinQObject.setObject(qImageFile, forKey: "fullRes")
        noQsPhotoJoin1Object.setObject(o1ImageFile, forKey: "thumb")
        noQsPhotoJoin1Object.setObject(o1ImageFile, forKey: "fullRes")
        noQsPhotoJoin2Object.setObject(o2ImageFile, forKey: "thumb")
        noQsPhotoJoin2Object.setObject(o2ImageFile, forKey: "fullRes")
        
        var images: [PFObject] = [noQsPhotoJoinQObject, noQsPhotoJoin1Object, noQsPhotoJoin2Object]
        
        noQsQuestionObject.setObject(images, forKey: "images")
        noQsQuestionObject.setObject(0, forKey: "option1Stats")
        noQsQuestionObject.setObject(0, forKey: "option2Stats")
        noQsQuestionObject.setObject(noQsAskerObject, forKey: "asker")
        
        noQsJoinObject.setObject(noQsQuestionObject, forKey: "question")
        
        self.QJoinObjects = [noQsJoinObject]
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

