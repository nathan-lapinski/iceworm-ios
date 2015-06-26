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
    var warnComplete = false
    
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
        
        let title = "Future GROUP functionality may include:"
        let message = "Selecting friends to whom your question will be sent, building custom groups of friends from contacts or Facebook, or other options for which YOU voice desires!"
        displayAlert(title, message: message)
        
    }
    
    @IBAction func privacyButtonAction(sender: AnyObject) {
        
        let title = "Future PRIVACY functionality may include:"
        let message = "Selecting if users can forward your question, sending question anonymously, or other options for which YOU voice desires!"
        displayAlert(title, message: message)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        questionTextField.text = nil
        option1TextField.text = nil
        option2TextField.text = nil
        
        questionTextField.resignFirstResponder()
        option1TextField.resignFirstResponder()
        option2TextField.resignFirstResponder()
        
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        //myQuestion.questionText = questionTextField.text
        //myQuestion.option1Text = option1TextField.text
        //myQuestion.option2Text = option2TextField.text
        
        // PARSE -------------------------------------------------------------
        var socialQ = PFObject(className: "SocialQs")
        
        socialQ["question"] = questionTextField.text
        socialQ["option1"] = option1TextField.text
        socialQ["option2"] = option2TextField.text
        socialQ["stats1"] = 0
        socialQ["stats2"] = 0
        //socialQ["UserId"] = PFUser.currentUser()!.objectId!
        socialQ["askername"] = PFUser.currentUser()!["username"]
        
        socialQ.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil {
                
                // Reset all fields after submitting
                self.questionTextField.text = ""
                self.option1TextField.text = ""
                self.option2TextField.text = ""
                
                //questionTextField.resignFirstResponder()
                //option1TextField.resignFirstResponder()
                //option2TextField.resignFirstResponder()
                
                // Mark question as active
                //myQuestion.questionActive = true
                
                // Switch to results tab when question is submitted
                // - Had to make storyboard ID for the tabBarController = "tabBarController"
                self.tabBarController?.selectedIndex = 1
                
            }
        }
        // PARSE -------------------------------------------------------------
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
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
        groupButton.backgroundColor = bgColor
        privacyButton.layer.cornerRadius = cornerRadius
        privacyButton.backgroundColor = bgColor
        
        cancelButton.layer.cornerRadius = cornerRadius
        cancelButton.backgroundColor = bgColor
        submitButton.layer.cornerRadius = cornerRadius
        submitButton.backgroundColor = bgColor
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if warnComplete == false {
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
        }
        
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

