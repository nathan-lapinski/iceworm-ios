//
//  AskViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/8/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class AskViewController: UIViewController, UITextFieldDelegate {
    
    //var myQuestion = socialQuestionModel()
    //var warnComplete = false
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var whatIsQuestionTextField: UILabel!
    @IBOutlet var whatAreOptionsTextField: UILabel!
    @IBOutlet var questionTextField: UITextField!
    @IBOutlet var option1TextField: UITextField!
    @IBOutlet var option2TextField: UITextField!
    @IBOutlet var groupButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    @IBAction func groupButtonAction(sender: AnyObject) {
        
    }
    
    @IBAction func privacyButtonAction(sender: AnyObject) {
        
        let title = "Future PRIVACY functionality may include:"
        let message = "Selecting if users can forward your question, sending question anonymously, or other options for which you voice desires!"
        displayAlert(title, message: message)
        
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        questionTextField.text = nil
        option1TextField.text = nil
        option2TextField.text = nil
        
        isGroupieName.removeAll(keepCapacity: true)
        isGroupieQId.removeAll(keepCapacity: true)
        
        questionTextField.resignFirstResponder()
        option1TextField.resignFirstResponder()
        option2TextField.resignFirstResponder()
        
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        if questionTextField.text == "" || option1TextField.text == "" || option2TextField.text == "" {
            
            let title = "Well that was silly!"
            let message = "You need to provide a Q and two options!"
            displayAlert(title, message: message)
            
        } else {
        
            
            println("User is attempting to send a Q to:")
            println(isGroupieName)
            println("With qIds:")
            println(isGroupieQId)
            
            // Setup spinner and block application input
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
            // PARSE -------------------------------------------------------------
            // Add entry to "Votes Table" ----------------
            var votes = PFObject(className: "Votes")
            
            votes.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    
                    var socialQ = PFObject(className: "SocialQs")
                    
                    socialQ["question"] = self.questionTextField.text
                    socialQ["option1"] = self.option1TextField.text
                    socialQ["option2"] = self.option2TextField.text
                    socialQ["stats1"] = 0
                    socialQ["stats2"] = 0
                    socialQ["privacyOptions"] = -1
                    socialQ["askerId"] = PFUser.currentUser()!.objectId!
                    socialQ["askername"] = PFUser.currentUser()!["username"]
                    socialQ["votesId"] = votes.objectId!
                    
                    socialQ.saveInBackgroundWithBlock { (success, error) -> Void in
                        
                        var currentQId = socialQ.objectId!
                        
                        if error == nil {
                            
                            // Query all "groupies" and myself (to add to myQs)
                            var usersToQuery = isGroupieQId + [uQId]
                            
                            // Add qId to "UserQs" table ------
                            var userQsQuery = PFQuery(className: "UserQs")
                            
                            println("userToQuery appended:")
                            println(usersToQuery)
                            
                            if isGroupieQId.count > 0 {
                                userQsQuery.whereKey("objectId", containedIn: usersToQuery)
                            }
                            
                            // Execute query
                            userQsQuery.findObjectsInBackgroundWithBlock({ (userQsObjects, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let temp = userQsObjects {
                                        
                                        println("App is sending Q to uQIds:")
                                        for userQsObject in temp {
                                            
                                            if userQsObject.objectId!! == uQId { // Append qId to myQs within UserQs table
                                                
                                                println("Saving to \(userQsObject.objectId!!) myQsId")
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "myQsId")
                                                userQsObject.saveInBackground()
                                                
                                            } else { // Append qId to theirQs within UserQs table
                                                
                                                println("Saving to \(userQsObject.objectId!!) theirQsId")
                                                
                                                userQsObject.addUniqueObject(currentQId, forKey: "theirQsId")
                                                userQsObject.saveInBackground()
                                            }
                                        }
                                        
                                    } else {
                                        
                                        println("Error updating UserQs Table")
                                        println(error)
                                    }
                                    
                                    // SEND CHANNEL PUSH -----------------------------------------------------
                                    var pushGeneral:PFPush = PFPush()
                                    pushGeneral.setChannel("reloadTheirTable")
                                    
                                    // Create dictionary to send JSON to parse/to other devices
                                    var dataGeneral: Dictionary = ["alert":"", "badge":"0", "content-available":"0", "sound":""]
                                    
                                    pushGeneral.setData(dataGeneral)
                                    
                                    pushGeneral.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                        if error == nil { println("General push sent!") }
                                    })
                                    
                                    // SEND SEGMENT PUSH NOTIFICATION ---------------------------------------
                                    // ****CURRENTLY SEND TO ALL IF NO ONE IS SELECTED!!****
                                    var toUsers: PFQuery = PFUser.query()!
                                    
                                    println("********************")
                                    println(toUsers)
                                    println("********************")
                                    
                                    var pushQuery: PFQuery = PFInstallation.query()!
                                    
                                    if isGroupieName.isEmpty == false {
                                        
                                        toUsers.whereKey("username", containedIn: isGroupieName)
                                        pushQuery.whereKey("user", matchesQuery: toUsers)
                                        
                                    } else { // If sendToGroupies is empty, filter push to all users
                                        pushQuery.whereKey("user", notContainedIn: isGroupieName)
                                        pushQuery.whereKey("username", doesNotMatchQuery: toUsers)
                                    }
                                    
                                    var pushDirected: PFPush = PFPush()
                                    pushDirected.setQuery(pushQuery)
                                    
                                    // Create dictionary to send JSON to parse/to other devices
                                    //var dataDirected: Dictionary = ["alert":"New Q from \(myName)!", "badge":"Increment", "content-available":"0", "sound":""]////
                                    //pushDirected.setData(dataDirected)////
                                    pushDirected.setMessage("New Q from \(myName)!")
                                    
                                    // Send Push Notifications
                                    pushDirected.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                        
                                        if error == nil {
                                            
                                            isGroupieName.removeAll(keepCapacity: true)
                                            isGroupieQId.removeAll(keepCapacity: true)
                                            
                                            println("Directed push notification sent!")
                                            println("-----")
                                        }
                                    })
                                    // SEND DIRECTED PUSH NOTIFICATION ---------------------------------------
                                    
                                    // Unlock application interaction and halt spinner
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    self.activityIndicator.stopAnimating()
                                    
                                    // Reset all fields after submitting
                                    self.questionTextField.text = ""
                                    self.option1TextField.text = ""
                                    self.option2TextField.text = ""
                                    
                                    // Resign keyboard/reset cursor
                                    self.questionTextField.resignFirstResponder()
                                    self.option1TextField.resignFirstResponder()
                                    self.option2TextField.resignFirstResponder()
                                    
                                    // Switch to results tab when question is submitted
                                    // - Had to make storyboard ID for the tabBarController = "tabBarController"
                                    self.tabBarController?.selectedIndex = 1
                                }
                            })
                            
                        } else {
                            
                            println("Write to SocialQs Table error:")
                            println(error)
                        }
                    }
                }
            })
            // PARSE -------------------------------------------------------------
        }
    }
        
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Format labels ------------------------------
        whatIsQuestionTextField.textColor = UIColor.whiteColor()
        whatAreOptionsTextField.textColor = UIColor.whiteColor()
        
        /*
        // Format text fields -------------------------
        questionTextField.borderStyle = UITextBorderStyle.Line
        questionTextField.layer.borderColor = UIColor.whiteColor().CGColor
        questionTextField.layer.cornerRadius = 5.0
        questionTextField.layer.borderWidth = 1.0
        questionTextField.layer.backgroundColor = UIColor.clearColor().CGColor
        */
        
        // Format buttons -----------------------------
        groupButton.layer.cornerRadius = cornerRadius
        privacyButton.layer.cornerRadius = cornerRadius
        cancelButton.layer.cornerRadius = cornerRadius
        submitButton.layer.cornerRadius = cornerRadius
        
        groupButton.backgroundColor = buttonBackgroundColor
        privacyButton.backgroundColor = buttonBackgroundColor
        cancelButton.backgroundColor = buttonBackgroundColor
        submitButton.backgroundColor = buttonBackgroundColor
        
        groupButton.titleLabel?.textColor = buttonTextColor
        privacyButton.titleLabel?.textColor = buttonTextColor
        cancelButton.titleLabel?.textColor = buttonTextColor
        submitButton.titleLabel?.textColor = buttonTextColor
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        println("#######################")
        println(votedOn1Ids)
        println(votedOn2Ids)
        println("#######################")
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //println("Subscribing to reloadTable for \(myName)")
        //****************************
        // Register user for push notifications
        var installation = PFInstallation.currentInstallation()
        installation.addUniqueObject("reloadTheirTable", forKey: "channels")
        //installation["user"] = PFUser.currentUser()//?.objectId!
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil {
                println("Installation Success")
                println(success)
            } else {
                println("Installation Error")
                println(error)
            }
        }
        //****************************
        //println("Finished subscribing to reloadTable for \(myName)")
        
        
        //if warnComplete == false {
            /*
            warnComplete = true
            var title = "Limitation of this test"
            var message = "Please note that, for this test, " +
                "all testers will be able to see and answer all Qs. " +
                "Furthermore, Qs cannot yet be removed from the " +
                "Qs database without contacting the developer. " +
                "Have fun and feel free to be goofy and/or mildly innapropriate " +
                "but remain thoughtful of yourself and fellow testers. Thank you!"
            displayAlert(title, message: message)
            */
        //}
        
        // Setup keyboard control delegates
        //questionTextField.delegate = self
        //option2TextField.delegate = self
        
        // Allow data swap between controllers ---------
        //let barViewControllers = self.tabBarController?.viewControllers
        //let svc = barViewControllers![1] as! MyQuestionsTableViewController//ResultsViewController
        //svc.myQuestion = self.myQuestion
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // Dismiss the keyboard
        
        // Call submit routine to cause switch to results page
        submitButtonAction(textField)
        
        return true
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // Function for displaying pop-up
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    // MAKE GLOBAL FUNCTION -----------------------------------------------------------
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

