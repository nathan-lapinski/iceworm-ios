//
//  QSTheirCellNEW.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/4/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    //func toDoItemDeleted()
}

class QSTheirCellNEW: UITableViewCell {
    
    var delegate: TableViewCellDelegate?
    var optionIdentifier: Int = 0
    var option1Offset: CGFloat = 38.0
    var option2Offset: CGFloat = 38.0
    var horizontalSpace: CGFloat = 8.0
    var imageBarExtraSpace: CGFloat = 3.0
    
    var questionBackground: UIImageView! = UIImageView()
    var profilePicture: UIImageView! = UIImageView()
    var questionPicture: UIImageView! = UIImageView()
    
    var option1Background: UIImageView = UIImageView()
    var option2Background: UIImageView = UIImageView()
    
    var option1Image: UIImageView! = UIImageView()
    var option2Image: UIImageView! = UIImageView()
    
    var option1Vote: UIImageView! = UIImageView()
    var option2Vote: UIImageView! = UIImageView()
    
    var questionZoom: UIButton = UIButton()
    var option1Zoom: UIButton = UIButton()
    var option2Zoom: UIButton = UIButton()
    
    var option1Bar: UIImageView! = UIImageView()
    var option2Bar: UIImageView! = UIImageView()
    
    var usernameLabel: UILabel! = UILabel()
    var questionText: UILabel! = UILabel()
    var option1Text: UILabel! = UILabel()
    var option2Text: UILabel! = UILabel()
    var responsesText: UILabel! = UILabel()
    
    var QJoinObject: PFObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(questionBackground)
        self.addSubview(profilePicture)
        self.addSubview(questionPicture)
        
        self.addSubview(option1Background)
        self.addSubview(option2Background)
        
        self.addSubview(usernameLabel)
        self.addSubview(questionText)
        self.addSubview(option1Text)
        self.addSubview(option2Text)
        self.addSubview(responsesText)
        
        self.addSubview(option1Bar)
        self.addSubview(option2Bar)
        self.addSubview(option1Image)
        self.addSubview(option2Image)
        
        self.addSubview(option1Vote)
        self.addSubview(option2Vote)
        
        self.addSubview(questionZoom)
        self.addSubview(option1Zoom)
        self.addSubview(option2Zoom)
        
        // Make cell non-selectable
        selectionStyle = .None
        
        // Set background
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        // add a pan recognizers
        var recognizer1 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier1:")
        recognizer1.delegate = self
        option1Zoom.addGestureRecognizer(recognizer1)
        option1Zoom.userInteractionEnabled = true
        
        var recognizer2 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier2:")
        recognizer2.delegate = self
        option2Zoom.addGestureRecognizer(recognizer2)
        option2Zoom.userInteractionEnabled = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        questionBackground.frame = CGRectMake(8, 8, bounds.width - 16, 60)
        questionBackground.layer.cornerRadius = questionBackground.frame.height/2
        questionBackground.backgroundColor = mainColorBlue.colorWithAlphaComponent(0.7)//UIColor.whiteColor().colorWithAlphaComponent(1.0)//
        
        profilePicture.frame = CGRectMake(8, 8, 60, 60)
        if (QJoinObject["question"]!["asker"]!!["profilePicture"] as? PFFile != nil) {
            
            getImageFromPFFile(QJoinObject["question"]!["asker"]!!["profilePicture"]!! as! PFFile, { (image, error) -> () in
                
                if error == nil {
                    
                    self.profilePicture.image = image
                }
            })
        }
        profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
        profilePicture.layer.masksToBounds = false
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        
        usernameLabel.frame = CGRectMake(68, 6, 150, 20)
        usernameLabel?.font = UIFont(name: "HelveticaNeue", size: CGFloat(12))!
        usernameLabel?.textColor = UIColor.whiteColor()//mainColorBlue
        let usernameString = QJoinObject["question"]!["asker"]!!["username"] as? String
        usernameLabel.text = "@\(usernameString!)"
        
        questionText.frame = CGRectMake(76, 24, bounds.width - 120 - 16, 50)
        if let qText = self.QJoinObject["question"]!["questionText"] as? String {
            questionText.text = qText
            questionText.numberOfLines = 0
            questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
            questionText.textAlignment = NSTextAlignment.Center
            questionText?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
            questionText?.textColor = UIColor.darkTextColor()
            questionText.sizeToFit()
        } else {
            questionText.text = ""
        }
        
        questionPicture.frame = CGRectMake(bounds.width - 60 - horizontalSpace, 8, 60, 60)
        if let questionPhotoThumb = self.QJoinObject["question"]!["questionPhotoThumb"] as? PFFile {
            
            getImageFromPFFile(questionPhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    self.questionPicture.image = image
                    
                } else {
                    
                    println("There was an error downloading a questionPhoto")
                }
            })
            questionPicture.contentMode = UIViewContentMode.ScaleAspectFill
            questionPicture.clipsToBounds = true
            questionPicture.layer.cornerRadius = questionPicture.frame.width/2
//            questionTextRightSpace.constant = cell.questionImage.frame.size.width + 12
//            questionText.layoutIfNeeded()
            questionPicture.hidden = false
        } else {
//            questionTextRightSpace.constant = 8
//            questionText.layoutIfNeeded()
            questionPicture.hidden = true
        }
        
        option1Background.frame = CGRectMake(horizontalSpace, 71, bounds.width - 2*horizontalSpace, 60)
//        option1Background.layer.cornerRadius = 10
//        option1Background.layer.borderWidth = 1.0
//        option1Background.layer.borderColor = UIColor.whiteColor().CGColor
        option1Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1.0)
        
        option2Background.frame = CGRectMake(horizontalSpace, 134, bounds.width - 2*horizontalSpace, 60)
//        option2Background.layer.cornerRadius = 10
//        option2Background.layer.borderWidth = 1.0
//        option2Background.layer.borderColor = UIColor.whiteColor().CGColor
        option2Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1.0)
        
        option1Image.frame = CGRectMake(horizontalSpace, 71, 60, 60)
        if let option1PhotoThumb = self.QJoinObject["question"]!["option1PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option1PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    self.option1Image.image = image
                    
                } else {
                    
                    println("There was an error downloading an option1Photo")
                }
            })
            
            // Set option1 text width
//            cell.option1TextLeftSpace.constant = cell.option1Image.frame.size.width + 14
            //            cell.option1Text.layoutIfNeeded()
            
            
        } else {
            
            // Set question text width
//            cell.option1TextLeftSpace.constant = 14
//            cell.option1Text.layoutIfNeeded()
            
            option1Image.image = UIImage(named: "logo_square.png")
        }
        option1Image.contentMode = UIViewContentMode.ScaleAspectFill
        option1Image.clipsToBounds = true
//        option1Image.layer.cornerRadius = 10
        
        option2Image.frame = CGRectMake(horizontalSpace, 134, 60, 60)
        if let option2PhotoThumb = self.QJoinObject["question"]!["option2PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option2PhotoThumb, { (image, error) -> () in
                
                if error == nil {
                    
                    self.option2Image.image = image
                    
                } else {
                    
                    println("There was an error downloading an option2Photo")
                }
            })
            
            // Set option2 text width
//            cell.option2TextLeftSpace.constant = cell.option2Image.frame.size.width + 14
            //            cell.option2Text.layoutIfNeeded()
            
        } else {
            
            // Set question text width
//            option2TextLeftSpace.constant = 14
            //            option2Text.layoutIfNeeded()
            
            option2Image.image = UIImage(named: "logo_square.png")
        }
        option2Image.contentMode = UIViewContentMode.ScaleAspectFill
        option2Image.clipsToBounds = true
        
        option1Vote.frame = CGRectMake(0, 0, 25, 25)
        option1Vote.center = option1Image.center
        option1Vote.layer.cornerRadius = option1Vote.frame.width/2
        option1Vote.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        option1Vote.image = UIImage(named: "voteCheckmark.png")
        option1Vote.alpha = 0.0
        
        option2Vote.frame = CGRectMake(0, 0, 25, 25)
        option2Vote.center = option2Image.center
        option2Vote.layer.cornerRadius = option2Vote.frame.width/2
        option2Vote.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        option2Vote.image = UIImage(named: "voteCheckmark.png")
        option2Vote.alpha = 0.0
        
        option1Bar.frame = CGRectMake(option1Image.frame.origin.x, option1Image.center.y - option1Image.frame.height/2, option1Image.frame.width + imageBarExtraSpace, option1Image.frame.height)
        option1Bar.backgroundColor = mainColorBlue
        
        option2Bar.frame = CGRectMake(option2Image.frame.origin.x, option2Image.center.y - option2Image.frame.height/2, option2Image.frame.width + imageBarExtraSpace, option2Image.frame.height)
        option2Bar.backgroundColor = mainColorBlue
        
        questionZoom.frame = questionPicture.frame
        questionZoom.addTarget(self, action: "questionZoom:", forControlEvents: UIControlEvents.TouchUpInside)
        
        option1Zoom.frame = option1Image.frame
        option1Zoom.addTarget(self, action: "zoomImage1:", forControlEvents: UIControlEvents.TouchUpInside)
        
        option2Zoom.frame = option2Image.frame
        option2Zoom.addTarget(self, action: "zoomImage2:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var totalResponses = (self.QJoinObject["question"]!["option1Stats"] as! Int) + (QJoinObject["question"]!["option2Stats"] as! Int)
        var option1Percent = Float(0.0)
        var option2Percent = Float(0.0)
        
        if totalResponses != 0 {
            option1Percent = Float((self.QJoinObject["question"]!["option1Stats"] as! Int))/Float(totalResponses)*100
            option2Percent = Float((self.QJoinObject["question"]!["option2Stats"] as! Int))/Float(totalResponses)*100
        }
        
        option1Text.frame = CGRectMake(option1Image.frame.width + 2*horizontalSpace, option1Image.frame.origin.y, bounds.width - option1Image.frame.width - 4*horizontalSpace, 60)
        if let oText = self.QJoinObject["question"]!["option1Text"] as? String {
            if totalResponses > 0 {
                option1Text.text = oText + "  \(Int(option1Percent))%"
            } else {
                option1Text.text = oText
            }
        } else {
            if totalResponses > 0 {
                option1Text.text = "\(Int(option1Percent))%"
            } else {
                option1Text.text = ""
            }
        }
        option1Text.numberOfLines = 3
        option1Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option1Text.textAlignment = NSTextAlignment.Center
        option1Text?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
        option1Text?.textColor = UIColor.darkTextColor()
        
        option2Text.frame = CGRectMake(option2Image.frame.width + 2*horizontalSpace, option2Image.frame.origin.y, bounds.width - option2Image.frame.width - 4*horizontalSpace, 60)
        if let o2Text = self.QJoinObject["question"]!["option2Text"] as? String {
            if totalResponses > 0 {
                option2Text.text = o2Text  + "  \(100 - Int(option1Percent))%"
            } else {
                option2Text.text = o2Text
            }
            
        } else {
            if totalResponses > 0 {
                option2Text.text = "\(100 - Int(option1Percent))%"
            } else {
                option2Text.text = ""
            }
        }
        option2Text.numberOfLines = 3
        option2Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option2Text.textAlignment = NSTextAlignment.Center
        option2Text?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
        option2Text?.textColor = UIColor.darkTextColor()
        
        var resp = "responses"
        if totalResponses == 1 { resp = "response" }
        responsesText.frame = CGRectMake(bounds.width - horizontalSpace - 100, bounds.height - 21, 100, 20)
        responsesText.textAlignment = NSTextAlignment.Right
        responsesText?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(12))!
        responsesText?.textColor = UIColor.darkGrayColor()
        responsesText.text = "\(totalResponses) \(resp)"
    }
    
    
    func zoomImage1(sender: UIButton!) { println("Image1") }
    
    
    func zoomImage2(sender: UIButton!) { println("Image2") }
    
    
    func questionZoom(sender: UIButton!) { println("Question") }
    
    
    //MARK: - horizontal pan gesture methods
    func recognizerIdentifier1(recognizer: UIPanGestureRecognizer) { handlePan(recognizer, id: 1) }
    func recognizerIdentifier2(recognizer: UIPanGestureRecognizer) { handlePan(recognizer, id: 2) }
    func handlePan(recognizer: UIPanGestureRecognizer, id: Int) {
        
        let label = recognizer.view!
        let translation = recognizer.translationInView(self)
        var percentMoved = translation.x/(bounds.width - option1Image.frame.width - 2*horizontalSpace)
        
//        var scale: CGFloat = 1.0
//        if (percentMoved/0.5) <= 1.0 {
//            scale = abs(percentMoved/0.5) + 1
//        } else {
//            scale = abs(1 - (percentMoved/0.5 - 1)) + 1
//        }
//        println(scale)
        
        // MOVE THESE TO TO MAIN SCOPE SO NOT ALWAYS REDECLARED
        var textCenterStart = CGPoint(); textCenterStart.x = bounds.width - option1Text.frame.width/2 - 2*horizontalSpace
        var imageCenterStart = CGPoint(); imageCenterStart.x = option1Image.frame.width/2 + horizontalSpace
        var imageBarCenterStart = CGPoint(); imageBarCenterStart.x = option1Bar.frame.width/2 + horizontalSpace
        var voteCenterStart = CGPoint(); voteCenterStart.x = option1Vote.frame.width/2
            
        // Total amount the image view will move
        let a = bounds.width - option1Image.frame.width - 2*horizontalSpace
        
        // Total amount the text box needs to move
        let b = bounds.width - option1Text.frame.width - 4*horizontalSpace
        
        // Total amount the image bar BG will move
        let c = a - imageBarExtraSpace
        
        if id == 1 {
            
            label.center = CGPoint(x: option1Offset + translation.x, y: label.center.y)
            option1Image.center = label.center
            let percentMoved = (label.center.x - imageCenterStart.x) / a
            option1Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: option1Text.center.y)
            option1Bar.center = CGPoint(x: imageBarCenterStart.x + c*percentMoved, y: option1Bar.center.y)
            option1Vote.center = CGPoint(x: option1Offset + translation.x, y: label.center.y)
            option1Vote.alpha = percentMoved
            
        } else {
            
            label.center = CGPoint(x: option2Offset + translation.x, y: label.center.y)
            option2Image.center = label.center
            let percentMoved = (label.center.x - imageCenterStart.x) / a
            option2Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: option2Text.center.y)
            option2Bar.center = CGPoint(x: imageBarCenterStart.x + c*percentMoved, y: option2Bar.center.y)
            option2Vote.center = CGPoint(x: option2Offset + translation.x, y: label.center.y)
            option2Vote.alpha = percentMoved
        }
        
        let xFromCenter = label.center.x - bounds.width / 2
        var rotation = CGAffineTransformMakeRotation(0)
        var stretch = CGAffineTransformScale(rotation, 1, 1)
        
        label.transform = stretch
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            var endX: CGFloat = 0.0
            
            if xFromCenter <= 0 {
                endX = label.frame.width/2 + 8
            } else {
                endX = self.bounds.width - label.frame.width/2 - 8
            }
            
            if id == 1 {
                
                option1Offset = endX
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                    label.center = CGPoint(x: endX, y: label.center.y)
                    self.option1Image.center = label.center
                    
                    let percentMoved = (label.center.x - imageCenterStart.x) / a
                    self.option1Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: self.option1Text.center.y)
                    self.option1Bar.center = CGPoint(x: imageBarCenterStart.x + c*percentMoved, y: self.option1Bar.center.y)
                    self.option1Vote.center = CGPoint(x: endX, y: label.center.y)
                    self.option1Vote.alpha = percentMoved
                    
                    }, completion: { (isFinished) -> Void in
                })
                
            } else {
                
                option2Offset = endX
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    label.center = CGPoint(x: endX, y: label.center.y)
                    self.option2Image.center = label.center
                    
                    let percentMoved = (label.center.x - imageCenterStart.x) / a
                    self.option2Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: self.option2Text.center.y)
                    self.option2Bar.center = CGPoint(x: imageBarCenterStart.x + c*percentMoved, y: self.option2Bar.center.y)
                    self.option2Vote.center = CGPoint(x: endX, y: label.center.y)
                    self.option2Vote.alpha = percentMoved
                    
                    }, completion: { (isFinished) -> Void in
                })
            }
        }
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
