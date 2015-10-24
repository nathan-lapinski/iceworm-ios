//
//  QsMyVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsMyVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MyTableViewCellDelegate {
    
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    //var alreadyRetrievedMyQs = [String]()
    
    //var QJoinObjects: [AnyObject] = []
    var refresher: UIRefreshControl!
    var myQsSpinner = UIView()
    var myQsBlurView = globalBlurView()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Initiate Push Notifications
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
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
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // User is already logged in, do work such as go to next view controller.
            print("FB Access Token is good...")
            //self.generateAPILoginDetails()
            
        } else {
            displayAlert("Error", message: "A Facebook error has prevented Groupies from loading. Please quit the app (double-click the home button and swipe up). Relaunching and logging back in should fix the problem!", sender: self)
            
//            PFSession.getCurrentSessionInBackgroundWithBlock { (sessionObject, error) -> Void in
//                
//                if error == nil {
//                    
//                    FBSDKAccessToken.setCurrentAccessToken(sessionObject!.sessionToken!)
//                }
//            }
        }
    }
    
    func refreshMyQs() {
        print("NSNotificationCenter Observer called: refreshMyQs")
        
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        refresh()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("Number of rows to build = \(myQJoinObjects.count)")
        
        return myQJoinObjects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QSMyCellNEW
        
        if indexPath.row >= 0 {
            cell.delegate = self
            cell.QJoinObject = myQJoinObjects[indexPath.row] as! PFObject
        } else {
            print("WTF?!? indexPath.row = \(indexPath.row)")
        }
        
        return cell
    }
    
    
    //func toDoItemDeleted(){ }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.row < 0 { return [] }
        
        //"More"
        let view = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: " V ") { (action, index) -> Void in
            
            // Set question for viewing
            questionToView = myQJoinObjects[indexPath.row]["question"]!! as? PFObject
            
            self.performSegueWithIdentifier("viewVotesMyQs", sender: self)
            
            self.tableView.setEditing(false, animated: true)
        }
        view.backgroundColor = UIColor.orangeColor()
        
        
        //        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
        //
        //            println("share button tapped")
        //        }
        //        share.backgroundColor = UIColor.grayColor()
        
        
        let trash = UITableViewRowAction(style: .Normal, title: " D ") { action, index in
            
            let object = myQJoinObjects[indexPath.row] as! PFObject
            
            object.setObject(true, forKey: "deleted")
            
            object.unpinInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    print("question unpinned")
                    
                    // Unsubscribe from channel
                    // If user has current channels, check if this one is NOT there and add it
                    if let channels = (PFInstallation.currentInstallation().channels! as? [String]) {
                        
                        if channels.contains(object.objectId!) {
                            
                            let currentInstallation = PFInstallation.currentInstallation()
                            currentInstallation.removeObject("Question_\(object.objectId!)", forKey: "channels")
                            currentInstallation.saveEventually()
                        }
                        
                        print("Unsubbed from Q channel")
                        
                    }
                    
                    object.saveEventually({ (success, error) -> Void in
                        
                        if error == nil {
                            
                            print("Question updated to be labeled as deleted on SERVER")
                            
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
            
            myQJoinObjects.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
            
            // Update badge
            updateBadge("my")
            //NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
        }
        trash.backgroundColor = UIColor.redColor()
        
        print("Swiped MY row: \(indexPath.row)")
        
        
        if indexPath.row > -1 {
            
            if (((myQJoinObjects[indexPath.row] as! PFObject)["question"]!["option1Stats"] as! Int) + ((myQJoinObjects[indexPath.row] as! PFObject)["question"]!["option2Stats"] as! Int)) > 0 {
                
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
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }
    
    
    func segueToZoom() {
        
        self.performSegueWithIdentifier("zoomMyPhotoSegue", sender: self)
    }
    
    
    func refresh() {
        
        downloadMyQs { (completion) -> Void in
            
            if completion == true {
                
                // Reload table data
                self.tableView.reloadData()
                
                // update tabBar badge
                updateBadge("my")
                //NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
                
                // Kill refresher when query finished
                self.refresher.endRefreshing()
                
            } else {
                
                //                if theirQJoinObjects.count < 1 {
                //
                //                    buildNoQsQuestion()
                //                }
                
                //                // Reload table data
                //                self.tableView.reloadData()
                //
                // update tabBar badge
                //self.updateBadge()
                
                popErrorMessage = "Q refresh failed! Please check your network and try again!"
                popDirection = "top"
                let overlayVC = self.storyboard!.instantiateViewControllerWithIdentifier("errorOverlayViewController")
                self.prepareOverlayVC(overlayVC)
                self.presentViewController(overlayVC, animated: true, completion: nil)
                
                
                // Kill refresher when query finished
                self.refresher.endRefreshing()
                
            }
        }
    }
    
    
    private func prepareOverlayVC(overlayVC: UIViewController) {
        overlayVC.transitioningDelegate = overlayTransitioningDelegate
        overlayVC.modalPresentationStyle = .Custom
    }
    
    
//    func buildNoQsQuestion() {
//    
//        // Build a temp question when none are available
//        QJoinObjects.removeAll(keepCapacity: true)
//            
//        print("NO MYQS!!")
//        
//        let noQsJoinObject = PFObject(className: "QJoin")
//        let noQsQuestionObject = PFObject(className: "SocialQs")
////        var noQsPhotoJoinQObject = PFObject(className: "PhotoJoin")
////        var noQsPhotoJoin1Object = PFObject(className: "PhotoJoin")
////        var noQsPhotoJoin2Object = PFObject(className: "PhotoJoin")
//        let noQsAskerObject = PFObject(className: "User")
//        
//        let profImageData = UIImagePNGRepresentation(UIImage(named: "arrowToAsk.png")!)
//        let
//        profImageFile: PFFile = PFFile(name: "arrowToAsk.png", data: profImageData!)
//        noQsAskerObject.setObject(profImageFile, forKey: "profilePicture")
//        noQsAskerObject.setObject("SocialQs Team", forKey: "name")
//
//        noQsQuestionObject.setObject("Use the ASK button in the top left to create a Q!", forKey: "questionText")
//        noQsQuestionObject.setObject("Tap any of the images to enlarge...", forKey: "option1Text")
//        noQsQuestionObject.setObject("...or drag to the right to cast your vote!", forKey: "option2Text")
//        noQsQuestionObject.setObject(noQsAskerObject, forKey: "asker")
//
//        let qImageData = UIImagePNGRepresentation(UIImage(named: "scenery3.png")!)
//        let qImageFile: PFFile = PFFile(name: "questionPicture.png", data: qImageData!)
//        let o1ImageData = UIImagePNGRepresentation(UIImage(named: "scenery1.png")!)
//        let o1ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o1ImageData!)
//        let o2ImageData = UIImagePNGRepresentation(UIImage(named: "scenery2.png")!)
//        let o2ImageFile: PFFile = PFFile(name: "questionPicture.png", data: o2ImageData!)
//        
//        noQsQuestionObject.setObject(qImageFile, forKey: "questionImageThumb")
//        noQsQuestionObject.setObject(qImageFile, forKey: "questionImageFull")
//        noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageThumb")
//        noQsQuestionObject.setObject(o1ImageFile, forKey: "option1ImageFull")
//        noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageThumb")
//        noQsQuestionObject.setObject(o2ImageFile, forKey: "option2ImageFull")
//        
//        //var images: [PFObject] = [noQsPhotoJoinQObject, noQsPhotoJoin1Object, noQsPhotoJoin2Object]
//        
////        noQsQuestionObject.setObject(noQsPhotoJoinQObject, forKey: "questionImages")
////        noQsQuestionObject.setObject(noQsPhotoJoin1Object, forKey: "option1Images")
////        noQsQuestionObject.setObject(noQsPhotoJoin2Object, forKey: "option2Images")
//        noQsQuestionObject.setObject(0, forKey: "option1Stats")
//        noQsQuestionObject.setObject(0, forKey: "option2Stats")
//
//        noQsJoinObject.setObject(noQsQuestionObject, forKey: "question")
//        noQsJoinObject.setObject(noQsAskerObject, forKey: "asker")
//
//        self.QJoinObjects = [noQsJoinObject]
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
