/*//
//  ResultsViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/8/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import Parse

class ResultsViewController: UIViewController {
    
    var myQuestion = socialQuestionModel()
    var fullWidth = 300
    var width1 = 0
    var width2 = 0
    let loseColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: bgAlpha)
    
    @IBOutlet var option1Results: UILabel!
    @IBOutlet var option2Results: UILabel!
    @IBOutlet var numberOfResults: UILabel!
    @IBOutlet var questionTextField: UILabel!
    @IBOutlet var numResultsTextField: UILabel!
    @IBOutlet var option1ResultsImage: UIImageView!
    @IBOutlet var option2ResultsImage: UIImageView!

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        questionTextField.textColor = UIColor.whiteColor()
        numberOfResults.textColor = UIColor.whiteColor()
        
        // If we got to this view with a submitted question generate results
        if myQuestion.questionActive == true {
            
            // Call function to simulate results
            var results = generateResults()
            
            questionTextField.text = myQuestion.questionText
            option1Results.text = myQuestion.option1Text + " " + String(results.option1Percent) + "%"
            option2Results.text =
                myQuestion.option2Text + " " +
                String(results.option2Percent) + "%"
            numResultsTextField.text =
                String(results.totalResponses) + " responses"
            
            var ratioDec: Double = Double(results.ratioResponses)/100
            
            if results.ratioResponses < 50 { // 1st answer wins
                
                width2 = fullWidth
                width1 = Int(Double(width2)*ratioDec/(1 - ratioDec))
                option1ResultsImage.backgroundColor = loseColor
                option2ResultsImage.backgroundColor = bgColor
                
            } else if results.ratioResponses > 50 { // 2nd answer wins
                
                width1 = fullWidth
                width2 = Int(Double(width1)/ratioDec*(1 - ratioDec))
                option1ResultsImage.backgroundColor = bgColor
                option2ResultsImage.backgroundColor = loseColor
                
            } else { // both are equal and "win" color
                
                width1 = fullWidth
                width2 = Int(Double(width1)/ratioDec*(1 - ratioDec))
                option1ResultsImage.backgroundColor = bgColor
                option2ResultsImage.backgroundColor = bgColor
                
            }
            
            myQuestion.questionActive = false
            
        } else {
            
            // Setup views if no question is active
            option1ResultsImage.hidden = true
            option2ResultsImage.hidden = true
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionTextField.text = "No questions are active"
        
    }
    
    override func viewDidLayoutSubviews() {
        
        option1ResultsImage.frame = CGRectMake(option1ResultsImage.frame.origin.x, option1ResultsImage.frame.origin.y, 0, option1ResultsImage.frame.height)
        
        option2ResultsImage.frame = CGRectMake(option2ResultsImage.frame.origin.x, option2ResultsImage.frame.origin.y, 0, option2ResultsImage.frame.height)
        
        option1Results.alpha = 0.0
        option2Results.alpha = 0.0
        numberOfResults.alpha = 0.0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //if myQuestion.questionActive == true {
        
            option1ResultsImage.hidden = false
            option2ResultsImage.hidden = false
        
            UIView.animateWithDuration(1, delay: 0.40, options: nil, animations: { () -> Void in
            
                self.option1ResultsImage.frame = CGRectMake(self.option1ResultsImage.frame.origin.x, self.option1ResultsImage.frame.origin.y, CGFloat(self.width1), self.option1ResultsImage.frame.height)
            
                self.option2ResultsImage.frame = CGRectMake(self.option2ResultsImage.frame.origin.x, self.option2ResultsImage.frame.origin.y, CGFloat(self.width2), self.option2ResultsImage.frame.height)
            
                self.option1Results.alpha = 1.0
                self.option2Results.alpha = 1.0
            
                }, completion: { finished in
                
            })
        
            UIView.animateWithDuration(2, delay: 1, options: nil, animations: { () -> Void in
                
                    self.numberOfResults.alpha = 1.0
            
                }, completion: { finished in
                
            })
        //}
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function for simulating question-response results --------------------
    func generateResults() -> (option1Percent:Int, option2Percent:Int, totalResponses:Int, ratioResponses:Int) {
        
        // Generate a distribution ration between 20 and 72
        var ratio = Int(arc4random_uniform(52)) + 20
        
        // Generate a number of responses-value between 20 and 43
        var total = Int(arc4random_uniform(23)) + 20
        var option1 = Int(ratio)
        var option2 = 100 - option1
        
        return (option1, option2, total, ratio)
    }

}
*/
