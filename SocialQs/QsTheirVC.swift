//
//  QsTheirVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/4/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsTheirVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TheirTableViewCellDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
//    var alreadyRetrieved = [String]()
    
//    var QJoinObjects: [AnyObject] = []
    var refresher: UIRefreshControl!
    
    
    
    var refreshControl: UIRefreshControl!
    var customView: UIView!
    var labelsArray: Array<UILabel> = []
    var isAnimating = false
    var currentColorIndex = 0
    var currentLabelIndex = 0
    var timer: NSTimer!
    
    
    
    var myQsSpinner = UIView()
    var myQsBlurView = globalBlurView()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(QSTheirCellNEW.self, forCellReuseIdentifier: "cell")
        
//        // Pull to refresh --------------------------------------------------------
//        refresher = UIRefreshControl()
//        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(refresher)
//        // Pull to refresh --------------------------------------------------------
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.redColor()
        refreshControl.tintColor = UIColor.yellowColor()
        tableView.addSubview(refreshControl)
        loadCustomRefreshContents()
        
        backgroundImageView.image = UIImage(named: "bg5.png")
        tableView.backgroundColor = UIColor.clearColor()
        
        // Create observer to montior for return from sequed push view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTheirQs", name: "refreshTheirQs", object: nil)
        
    }
    
    func refreshTheirQs() {
        refresh()
    }
    
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return theirQJoinObjects.count }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSTheirCellNEW
        
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
        
        
        cell.QJoinObject = theirQJoinObjects[indexPath.row] as! PFObject
        
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
    
    
    func refresh() {
        
        //buildNoTheirQsQuestion()
        
        downloadTheirQs { (completion) -> Void in
            
            if completion == true {
                
                // Reload table data
                self.tableView.reloadData()
                
                // update tabBar badge
                updateBadge("their")
                //NSNotificationCenter.defaultCenter().postNotificationName("refreshTheirQsBadge", object: nil)
                
                // Kill refresher when query finished
                //self.refresher.endRefreshing()
                
            } else {
                
                popErrorMessage = "Q refresh failed! Please check your network and try again!"
                popDirection = "top"
                let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController")
                self.prepareOverlayVC(overlayVC)
                self.presentViewController(overlayVC, animated: true, completion: nil)
                
                // Kill refresher when query finished
                //self.refresher.endRefreshing()
                
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
    
    
    
    
    
    
    
    
    // MARK: UIScrollView delegate method implementation
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refreshControl.refreshing {
            if !isAnimating {
                doSomething()
                animateRefreshStep1()
            }
        }
    }
    
    
    // MARK: Custom function implementation
    
    func loadCustomRefreshContents() {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        
        customView = refreshContents[0] as! UIView
        customView.frame = refreshControl.bounds
        
        print(customView.subviews.count)
        
        for var i=0; i<customView.subviews.count - 1; ++i {
            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
        }
        
        refreshControl.addSubview(customView)
    }
    
    
    func animateRefreshStep1() {
        isAnimating = true
        
        UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            self.labelsArray[self.currentLabelIndex].textColor = self.getNextColor()
            
            }, completion: { (finished) -> Void in
                
                UIView.animateWithDuration(0.03, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.labelsArray[self.currentLabelIndex].transform = CGAffineTransformIdentity
                    self.labelsArray[self.currentLabelIndex].textColor = UIColor.blackColor()
                    
                    }, completion: { (finished) -> Void in
                        ++self.currentLabelIndex
                        
                        if self.currentLabelIndex < self.labelsArray.count {
                            self.animateRefreshStep1()
                        }
                        else {
                            self.animateRefreshStep2()
                        }
                })
        })
    }
    
    
    func animateRefreshStep2() {
        
        let maxScale: CGFloat = 1.25
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.labelsArray[0].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[1].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[2].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[3].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[4].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[5].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[6].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[7].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[8].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[9].transform  = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[10].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[11].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[12].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[13].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[14].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            self.labelsArray[15].transform = CGAffineTransformMakeScale(maxScale, maxScale)
            
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.labelsArray[0].transform  = CGAffineTransformIdentity
                    self.labelsArray[1].transform  = CGAffineTransformIdentity
                    self.labelsArray[2].transform  = CGAffineTransformIdentity
                    self.labelsArray[3].transform  = CGAffineTransformIdentity
                    self.labelsArray[4].transform  = CGAffineTransformIdentity
                    self.labelsArray[5].transform  = CGAffineTransformIdentity
                    self.labelsArray[6].transform  = CGAffineTransformIdentity
                    self.labelsArray[7].transform  = CGAffineTransformIdentity
                    self.labelsArray[8].transform  = CGAffineTransformIdentity
                    self.labelsArray[9].transform  = CGAffineTransformIdentity
                    self.labelsArray[10].transform = CGAffineTransformIdentity
                    self.labelsArray[11].transform = CGAffineTransformIdentity
                    self.labelsArray[12].transform = CGAffineTransformIdentity
                    self.labelsArray[13].transform = CGAffineTransformIdentity
                    self.labelsArray[14].transform = CGAffineTransformIdentity
                    self.labelsArray[15].transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) -> Void in
                        if self.refreshControl.refreshing {
                            self.currentLabelIndex = 0
                            self.animateRefreshStep1()
                        }
                        else {
                            self.isAnimating = false
                            self.currentLabelIndex = 0
                            for var i=0; i<self.labelsArray.count; ++i {
                                self.labelsArray[i].textColor = UIColor.blackColor()
                                self.labelsArray[i].transform = CGAffineTransformIdentity
                            }
                        }
                })
        })
    }
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magentaColor(), UIColor.brownColor(), UIColor.yellowColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor()]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        ++currentColorIndex
        
        return returnColor
    }
    
    
    func doSomething() {
        timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "endOfWork", userInfo: nil, repeats: true)
    }
    
    
    func endOfWork() {
        
        for var i = 0; i < 16; i++ {
            self.labelsArray[i].textColor = UIColor.clearColor()
        }
        refreshControl.endRefreshing()
        
        timer.invalidate()
        timer = nil
    }
    
    
}

