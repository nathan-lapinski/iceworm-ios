////
////  QsGlobalVC.swift
////  SocialQs
////
////  Created by Brett Wiesman on 9/15/15.
////  Copyright (c) 2015 BookSix. All rights reserved.
////
//
//import UIKit
//
//class QsGlobalVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
//    
//    var QJoinObjects: [AnyObject] = []
//    var refresher: UIRefreshControl!
//    var myQsSpinner = UIView()
//    var myQsBlurView = globalBlurView()
//    
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet var backgroundImageView: UIImageView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Pull to refresh --------------------------------------------------------
//        refresher = UIRefreshControl()
//        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(refresher)
//        // Pull to refresh --------------------------------------------------------
//        
//        backgroundImageView.image = UIImage(named: "bg5.png")
//        tableView.backgroundColor = UIColor.clearColor()
//        //        tableView.backgroundColor = UIColor(red: 236/256, green: 236/256, blue: 236/256, alpha: 1.0) //UIColor.whiteColor()//.colorWithAlphaComponent(0.95)
//        
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.registerClass(QSTheirCellNEW.self, forCellReuseIdentifier: "cell")
//    }
//    
//    
//    override func viewWillAppear(animated: Bool) {
//        
//        refresh()
//        
//    }
//    
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return QJoinObjects.count }
//    
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSTheirCellNEW
//        
//        cell.delegate = self
//        cell.QJoinObject = QJoinObjects[indexPath.row] as! PFObject
//        
//        return cell
//    }
//    
//    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
//        
//        //"More"
//        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View") { (action, index) -> Void in
//            
//            // Set question for viewing
//            questionToView = self.QJoinObjects[indexPath.row]["question"]!! as? PFObject
//            
//            self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
//            
//            self.tableView.setEditing(false, animated: true)
//        }
//        view.backgroundColor = UIColor.orangeColor()
//        
//        
//        
//        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { action, index in
//            
//            let object = self.QJoinObjects[indexPath.row] as! PFObject
//            
//            object["askeeDeleted"] = true
//            
//            object.unpinInBackgroundWithBlock({ (success, error) -> Void in
//                
//                if error == nil {
//                    
//                    println("question unpinned")
//                    
//                    object.saveEventually({ (success, error) -> Void in
//                        
//                        if error == nil {
//                            
//                            println("Question updated to be labeled as deleted")
//                            
//                        } else {
//                            
//                            println("There was an error updating the question as deleted:")
//                            println(error)
//                        }
//                    })
//                    
//                } else {
//                    
//                    println("There was an error unpinning the question:")
//                    println(error)
//                }
//            })
//            
//            self.QJoinObjects.removeAtIndex(indexPath.row)
//            
//            tableView.beginUpdates()
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//            tableView.endUpdates()
//        }
//        trash.backgroundColor = UIColor.redColor()
//        
//        println("Swiped THEIR row: \(indexPath.row)")
//        
//        if self.QJoinObjects[indexPath.row]["vote"] != nil {
//            
//            return [trash, view] // Order = appearance order, right to left on screen
//            
//        } else {
//            
//            return [trash] // Order = appearance order, right to left on screen
//        }
//    }
//    
//    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
//        forRowAtIndexPath indexPath: NSIndexPath) {
//            cell.backgroundColor = UIColor.clearColor()
//    }
//    
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
//    
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
//    
//    
//    func segueToZoom() {
//        self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: self)
//    }
//    
//    
//    func refresh() {
//        
//        QJoinObjects.removeAll(keepCapacity: true)
//        
//        var qJoinQueryLocal = PFQuery(className: "QJoin")
//        qJoinQueryLocal.whereKey("to", equalTo: PFUser.currentUser()!.username!)
//        qJoinQueryLocal.orderByDescending("createdAt")
//        qJoinQueryLocal.whereKey("askeeDeleted", equalTo: false)
//        qJoinQueryLocal.limit = 1000
//        qJoinQueryLocal.includeKey("question")
//        qJoinQueryLocal.includeKey("asker")
//        qJoinQueryLocal.fromLocalDatastore()
//        
//        qJoinQueryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            
//            var alreadyRetrieved = [String]()
//            
//            if error == nil {
//                
//                self.QJoinObjects = objects!
//                
//                // Reload table data
//                self.tableView.reloadData()
//                
//                // Kill refresher when query finished
//                self.refresher.endRefreshing()
//                
//                for temp in objects! {
//                    if temp.objectId! != nil {
//                        alreadyRetrieved.append(temp.objectId!!)
//                    }
//                }
//                
//            } else {
//                
//                println("There was an error loading Qs from local data store:")
//                println(error)
//            }
//            
//            // Get Qs that are not in localdata store
//            var qJoinQueryServer = PFQuery(className: "QJoin")
//            qJoinQueryServer.whereKey("to", equalTo: PFUser.currentUser()!.username!)
//            qJoinQueryServer.whereKey("objectId", notContainedIn: alreadyRetrieved)
//            qJoinQueryServer.orderByDescending("createdAt")
//            qJoinQueryServer.limit = 1000
//            qJoinQueryServer.includeKey("question")
//            qJoinQueryServer.includeKey("asker")
//            
//            qJoinQueryServer.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
//                
//                if error == nil {
//                    
//                    // Append to local array of PFObjects
//                    self.QJoinObjects = self.QJoinObjects + objects!
//                    
//                    // Reload table data
//                    self.tableView.reloadData()
//                    
//                    // Pin new Qs to local datastore
//                    if let temp = objects as? [PFObject] {
//                        
//                        for object in temp {
//                            
//                            object.pinInBackgroundWithBlock { (success, error) -> Void in
//                                
//                                if error == nil {
//                                    
//                                    println("Their Qs QJoin Object \(object.objectId!) pinned!")
//                                }
//                            }
//                        }
//                        
//                        // Reload table data
//                        self.tableView.reloadData()
//                    }
//                    
//                } else {
//                    
//                    println("There was an error retrieving new Qs from the database:")
//                    println(error)
//                    
//                    // Reload table data
//                    self.tableView.reloadData()
//                    
//                    // Kill refresher when query finished
//                    self.refresher.endRefreshing()
//                }
//            })
//        }
//    }
//    
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//}