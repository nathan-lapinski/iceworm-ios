//
//  QsGlobalVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/15/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsGlobalVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GlobalTableViewCellDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    //    var alreadyRetrieved = [String]()
    //    var QJoinObjects: [AnyObject] = []
    var refresher: UIRefreshControl!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = ODRefreshControl(scrollView: tableView)
        refreshControl.addTarget(self, action: Selector("dropViewDidBeginRefreshing:"), forControlEvents: .ValueChanged)
        
        //        // Pull to refresh --------------------------------------------------------
        //        refresher = UIRefreshControl()
        //        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        //        self.tableView.addSubview(refresher)
        //        // Pull to refresh --------------------------------------------------------
        
        backgroundImageView.image = UIImage(named: "bg5.png")
        tableView.backgroundColor = UIColor.clearColor()
        
        // Create observer to montior for return from sequed push view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshGlobalQs", name: "refreshGlobalQs", object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(QSGlobalCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            return interfaceOrientation != .PortraitUpsideDown
        } else {
            return true
        }
    }
    
    func dropViewDidBeginRefreshing(refreshControl: ODRefreshControl) {
        //        let delayInSeconds: UInt64 = 3
        //        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
        //        dispatch_after(popTime, dispatch_get_main_queue()) {
        //            refreshControl.endRefreshing()
        //        }
        refresh(refreshControl)
    }
    
    
    func refreshTheirQs() {
        refresh(nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return theirQJoinObjects.count }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSGlobalCell
        
        cell.delegate = self
        
        
        //        ////////////////////////////////////////////////////////////////////////////////////
        //        ////////////////////////////////////////////////////////////////////////////////////
        //        let allKeys = theirQJoinObjects[indexPath.row]["question"]!!.allKeys
        //        var optionStrings: [String] = []
        //        for str in allKeys {
        //            if str.containsString("option") {
        //                optionStrings.append(str as! String)
        //            }
        //        }
        //        ////////////////////////////////////////////////////////////////////////////////////
        //        ////////////////////////////////////////////////////////////////////////////////////
        //
        //        //cell.optionStrings = optionStrings
        //        //cell.optionStringCount = optionStrings.count
        //        //cell.optionBackgrounds = [UIImageView](count: optionStrings.count, repeatedValue: UIImageView())
        //
        //        let testView = UITextField()
        //        testView.frame = CGRectMake(0, 0, cell.bounds.width, 60)
        //        testView.text = "TEST TEST TEST TEST"
        //        testView.textColor = UIColor.blackColor()
        //        testView.font = UIFont(name: "Helvetice", size: 40)
        //        cell.addSubview(testView)
        
        
        cell.QJoinObject = nil // theirQJoinObjects[indexPath.row] as! PFObject
        
        return cell
    }
    
    
    //func toDoItemDeleted(){ }
    
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    //        ////////////////////////////////////////////////////////////////////////////////////
    //        ////////////////////////////////////////////////////////////////////////////////////
    //        let allKeys = theirQJoinObjects[indexPath.row]["question"]!!.allKeys
    //        var optionStrings: [String] = []
    //        for str in allKeys {
    //            if str.containsString("option") {
    //                optionStrings.append(str as! String)
    //            }
    //        }
    //        ////////////////////////////////////////////////////////////////////////////////////
    //        ////////////////////////////////////////////////////////////////////////////////////
    //
    //        return CGFloat(68 + 64*optionStrings.count)
    //
    //    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: " V ") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = theirQJoinObjects[indexPath.row]["question"]!! as? PFObject
            
            self.performSegueWithIdentifier("viewVotesTheirQs", sender: self)
            
            self.tableView.setEditing(false, animated: true)
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        //        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
        //
        //            println("share button tapped")
        //        }
        //        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: .Normal, title: " D ") { action, index in
            
            let object = theirQJoinObjects[indexPath.row] as! PFObject
            
            object["deleted"] = true
            
            object.unpinInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    print("question unpinned")
                    
                    object.saveEventually({ (success, error) -> Void in
                        
                        if error == nil {
                            
                            print("Question updated to be labeled as deleted")
                            
                        } else {
                            
                            print("There was an error updating the question as deleted:")
                            print(error)
                        }
                    })
                    
                } else {
                    
                    print("There was an error unpinning the question:")
                    print(error)
                }
            })
            
            theirQJoinObjects.removeAtIndex(indexPath.row)
            
            // Update badge
            updateBadge("their")
            //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
            
            // remove progress bar width entries from dictionary
            if theirOption1LastWidth[theirQJoinObjects[indexPath.row].objectId!!] != nil {
                theirOption1LastWidth[theirQJoinObjects[indexPath.row].objectId!!] = nil
            }
            if theirOption2LastWidth[theirQJoinObjects[indexPath.row].objectId!!] != nil {
                theirOption2LastWidth[theirQJoinObjects[indexPath.row].objectId!!] = nil
            }
        }
        trash.backgroundColor = UIColor.redColor()
        
        print("Swiped THEIR row: \(indexPath.row)")
        
        if indexPath.row > -1 {
            
            if let _: Int = theirQJoinObjects[indexPath.row]["vote"] as? Int {
                
                return [trash, view] // Order = appearance order, right to left on screen
                
            } else {
                
                return [trash] // Order = appearance order, right to left on screen
            }
            
        } else {
            
            return []
        }
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    func segueToZoom() {
        
        self.performSegueWithIdentifier("zoomTheirPhotoSegue", sender: self)
    }
    
    
    func refresh(refreshControl: ODRefreshControl?) {
        
        downloadTheirQs { (completion) -> Void in
            
            if completion == true {
                
                // Reload table data
                self.tableView.reloadData()
                
                // update tabBar badge
                updateBadge("their")
                //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
                
                // Kill refresher when query finished
                //self.refresher.endRefreshing()
                if refreshControl != nil { refreshControl!.endRefreshing() }
                
            } else {
                
                popErrorMessage = "Q refresh failed! Please check your network and try again!"
                popDirection = "top"
                let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController")
                self.prepareOverlayVC(overlayVC)
                self.presentViewController(overlayVC, animated: true, completion: nil)
                
                // Kill refresher when query finished
                //self.refresher.endRefreshing()
                if refreshControl != nil { refreshControl!.endRefreshing() }
            }
        }
    }
    
    
    private func prepareOverlayVC(overlayVC: UIViewController) {
        overlayVC.transitioningDelegate = overlayTransitioningDelegate
        overlayVC.modalPresentationStyle = .Custom
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
