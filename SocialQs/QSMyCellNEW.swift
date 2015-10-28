//
//  QSMyCellNEW.swift
//  SocialQs
//
//  Created by Brett Wiesman on 9/26/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit
import M13BadgeView

protocol MyTableViewCellDelegate {
    //func toDoItemDeleted()
    func segueToZoom()
}

class QSMyCellNEW: UITableViewCell {
    
    var delegate: MyTableViewCellDelegate?
    var optionIdentifier: Int = 0
    var option1Offset: CGFloat = 38.0
    var option2Offset: CGFloat = 38.0
    var horizontalSpace: CGFloat = 8.0
    var imageBarExtraSpace: CGFloat = 3.0
    
    var indicatorAlpha = CGFloat(0.6)
    var optionRadius = CGFloat(10)
    
    var textCenterStart = CGPoint()
    var textCenterEnd = CGPoint()
    var imageCenterStart = CGPoint()
    var imageCenterEnd = CGPoint()
    var imageBarCenterStart = CGPoint()
    var voteCenterStart = CGPoint()
    
    var totalResponses: Int = 0
    var resp = "responses"
    var option1Percent = Float(0.0)
    var option2Percent = Float(0.0)
    
    var layout = false
    
    var recognizer1 = UIPanGestureRecognizer()
    var recognizer2 = UIPanGestureRecognizer()
    
    var questionBackground: UIImageView! = UIImageView()
    var profilePicture: UIImageView! = UIImageView()
    
    var badgeViewFrame: UIImageView! = UIImageView()
    var badgeView: M13BadgeView! = M13BadgeView()
    
    var questionPicture: UIImageView! = UIImageView()
    
    var option1Background: UIImageView = UIImageView()
    var option2Background: UIImageView = UIImageView()
    
    var option1Stats: UIImageView = UIImageView()
    var option2Stats: UIImageView = UIImageView()
    
    var option1Image: UIImageView! = UIImageView()
    var option2Image: UIImageView! = UIImageView()
    
    var option1Checkmark: UIImageView! = UIImageView()
    var option2Checkmark: UIImageView! = UIImageView()
    
    var option1VoteArrow: UIImageView! = UIImageView()
    var option2VoteArrow: UIImageView! = UIImageView()
    
    var questionZoom: UIButton = UIButton()
    var option1Zoom: UIButton = UIButton()
    var option2Zoom: UIButton = UIButton()
    
    var usernameLabel: UILabel! = UILabel()
    var questionText: UILabel! = UILabel()
    var option1Text: UILabel! = UILabel()
    var option2Text: UILabel! = UILabel()
    var option1PercentText: UILabel! = UILabel()
    var option2PercentText: UILabel! = UILabel()
    var responsesText: UILabel! = UILabel()
    
    let maxStatsBarAlpha: CGFloat = 0.7
    
    var QJoinObject: PFObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(option1Background)
        self.addSubview(questionBackground)
        self.addSubview(option2Background)
        
        self.addSubview(profilePicture)
        self.addSubview(questionPicture)
        
        self.addSubview(option1Stats)
        self.addSubview(option2Stats)
        
        self.addSubview(usernameLabel)
        self.addSubview(questionText)
        self.addSubview(option1Text)
        self.addSubview(option2Text)
        self.addSubview(option1PercentText)
        self.addSubview(option2PercentText)
        self.addSubview(responsesText)
        
        self.addSubview(option1Image)
        self.addSubview(option2Image)
        
        self.addSubview(option1VoteArrow)
        self.addSubview(option2VoteArrow)
        
        self.addSubview(option1Checkmark)
        self.addSubview(option2Checkmark)
        
        self.addSubview(questionZoom)
        self.addSubview(option1Zoom)
        self.addSubview(option2Zoom)
        
        // Make cell non-selectable
        selectionStyle = .None
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (myOption1LastWidth[QJoinObject.objectId!] == nil) {
            myOption1LastWidth[QJoinObject.objectId!] = 0.0
        }
        
        if (myOption2LastWidth[QJoinObject.objectId!] == nil) {
            myOption2LastWidth[QJoinObject.objectId!] = 0.0
        }
        
        questionBackground.frame = CGRectMake(8, 8, bounds.width - 16, 60)
        questionBackground.layer.cornerRadius = 30
        questionBackground.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)//mainColorBlue
        
        profilePicture.frame = CGRectMake(8, 8, 60, 60)
        if (QJoinObject["asker"]!["profilePicture"] as? PFFile != nil) {
            getImageFromPFFile(QJoinObject["asker"]!["profilePicture"]!! as! PFFile, completion: { (image, error) -> () in
                if error == nil {
                    self.profilePicture.image = image
                }
            })
        }
        profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
        profilePicture.layer.masksToBounds = false
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        
        usernameLabel.frame = CGRectMake(67, 7, 150, 20)
        usernameLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(12))!
        usernameLabel?.textColor = UIColor.whiteColor() // winColor // UIColor.lightGrayColor()
        let usernameString = QJoinObject["asker"]!["name"] as? String
        usernameLabel.text = "From \(usernameString!)"
        
        if let questionPhotoThumb = QJoinObject["question"]!["questionImageThumb"] as? PFFile {//self.QJoinObject["question"]!["questionPhotoThumb"] as? PFFile {
            questionPicture.frame = CGRectMake(bounds.width - 60 - horizontalSpace, 8, 60, 60)
            getImageFromPFFile(questionPhotoThumb, completion: { (image, error) -> () in
                if error == nil {
                    self.questionPicture.image = image
                } else {
                    print("There was an error downloading a questionPhoto")
                }
            })
            questionPicture.contentMode = UIViewContentMode.ScaleAspectFill
            questionPicture.clipsToBounds = true
            questionPicture.hidden = false
            
            questionZoom.enabled = true
            questionZoom.frame = questionPicture.frame
            questionZoom.addTarget(self, action: "questionZoom:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            questionPicture.image = nil
            questionPicture.frame = CGRectMake(bounds.width - 60 - horizontalSpace, 8, 0, 60)
            questionPicture.hidden = true
            questionZoom.enabled = false
        }
        questionPicture.layer.cornerRadius = questionPicture.frame.width/2
        
        questionText.frame = CGRectMake(profilePicture.center.x + profilePicture.frame.width/2 + horizontalSpace, 24, bounds.width - profilePicture.frame.width - questionPicture.frame.width - 4*horizontalSpace, 40)
        if let qText = self.QJoinObject["question"]!["questionText"] as? String {
            questionText.text = qText
            questionText.numberOfLines = 0
            questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
            questionText.textAlignment = NSTextAlignment.Left
            questionText?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(14))!
            questionText?.textColor = UIColor.whiteColor()
            //questionText.sizeToFit()
        } else {
            questionText.text = ""
        }
        
        option1Background.frame = CGRectMake(horizontalSpace, questionBackground.frame.origin.y + 60 + 3, bounds.width - 2*horizontalSpace, 60)
        option1Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)//mainColorTeal
        option1Background.layer.cornerRadius = optionRadius
        
        option2Background.frame = CGRectMake(horizontalSpace, option1Background.frame.origin.y + 60, bounds.width - 2*horizontalSpace, 60)
        option2Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)//mainColorTeal
        option2Background.layer.cornerRadius = optionRadius
        
        option1Image.frame = CGRectMake(option1Background.frame.origin.x, option1Background.frame.origin.y, 60, 60)
        option1Zoom.frame = option1Image.frame
        if let option1PhotoThumb = QJoinObject["question"]!["option1ImageThumb"] as? PFFile {//self.QJoinObject["question"]!["option1PhotoThumb"] as? PFFile {
            
            getImageFromPFFile(option1PhotoThumb, completion: { (image, error) -> () in
                if error == nil {
                    self.option1Image.image = image
                } else {
                    print("There was an error downloading an option1Photo")
                }
            })
            
            option1Zoom.addTarget(self, action: "image1Zoom:", forControlEvents: UIControlEvents.TouchUpInside)
            option1Image.alpha = 1.0
            
        } else {
            option1Image.image = nil
            option1Image.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            //option1Image.frame = CGRectMake(option1Background.frame.origin.x, option1Background.frame.origin.y, 0, 60)
        }
        option1Image.layer.cornerRadius = 10
        option1Image.contentMode = UIViewContentMode.ScaleAspectFill
        option1Image.clipsToBounds = true
        
        option2Image.frame = CGRectMake(option2Background.frame.origin.x, option2Background.frame.origin.y, 60, 60)
        option2Zoom.frame = option2Image.frame
        if let option2PhotoThumb = QJoinObject["question"]!["option2ImageThumb"] as? PFFile {//self.QJoinObject["question"]!["option2PhotoThumb"] as? PFFile {
            getImageFromPFFile(option2PhotoThumb, completion: { (image, error) -> () in
                if error == nil {
                    self.option2Image.image = image
                } else {
                    print("There was an error downloading an option2Photo")
                }
            })
            
            option2Zoom.addTarget(self, action: "image2Zoom:", forControlEvents: UIControlEvents.TouchUpInside)
            option2Image.alpha = 1.0
        } else {
            option2Image.image = nil
            option2Image.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            //option2Image.frame = CGRectMake(option2Background.frame.origin.x, option2Background.frame.origin.y, 0, 60)
        }
        option2Image.layer.cornerRadius = 10
        option2Image.contentMode = UIViewContentMode.ScaleAspectFill
        option2Image.clipsToBounds = true
        
        option1Checkmark.frame = CGRectMake(0, 0, 30, 30)
        option1Checkmark.center = CGPoint(x: profilePicture.center.x, y: option1Image.center.y)
        option1Checkmark.layer.cornerRadius = option1Checkmark.frame.width/2
        option1Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
        option1Checkmark.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(indicatorAlpha)
        option1Checkmark.image = UIImage(named: "voteCheckmark.png")
        option1Checkmark.alpha = 0.0
        
        option2Checkmark.frame = CGRectMake(0, 0, 30, 30)
        option2Checkmark.center = CGPoint(x: profilePicture.center.x, y: option2Image.center.y)
        option2Checkmark.layer.cornerRadius = option2Checkmark.frame.width/2
        option2Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
        option2Checkmark.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(indicatorAlpha)
        option2Checkmark.image = UIImage(named: "voteCheckmark.png")
        option2Checkmark.alpha = 0.0
        
        
        
        
        option1VoteArrow.frame = option1Checkmark.frame
        //option1VoteArrow.center = CGPoint(x: option1Image.center.x + option1Image.frame.width/2, y: option1Image.center.y)
        option1VoteArrow.layer.cornerRadius = option1Checkmark.frame.width/2
        option1VoteArrow.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(indicatorAlpha)
        option1VoteArrow.image = UIImage(named: "voteArrow.png")
        option1VoteArrow.alpha = 0.0
        
        option2VoteArrow.frame = option2Checkmark.frame
        //option2VoteArrow.center = CGPoint(x: option2Image.center.x + option2Image.frame.width/2, y: option2Image.center.y)
        option2VoteArrow.layer.cornerRadius = option2Checkmark.frame.width/2
        option2VoteArrow.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(indicatorAlpha)
        option2VoteArrow.image = UIImage(named: "voteArrow.png")
        option2VoteArrow.alpha = 0.0
        
        
        
        
        if let _ = QJoinObject["vote"] as? Int {
            
            if badgeView.isDescendantOfView(self) {
                badgeView.removeFromSuperview()
            }
            if badgeViewFrame.isDescendantOfView(self) {
                badgeViewFrame.removeFromSuperview()
            }
            
            option1VoteArrow.alpha = 0.0
            option2VoteArrow.alpha = 0.0
            
        } else {
            
            // Add badge for NEW Q
            badgeView.text = "!"
            //badgeView.font = UIFont(name: "Helvetica", size: CGFloat(12.0))
            badgeView.badgeBackgroundColor = mainColorRed
            badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentLeft
            badgeViewFrame.frame = CGRectMake(bounds.width - 2*horizontalSpace, 2*horizontalSpace, 0, 0)
            self.addSubview(badgeViewFrame)
            badgeViewFrame.addSubview(badgeView)
            
            // add a pan recognizers
            recognizer1 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier1:")
            recognizer1.delegate = self
            option1Zoom.addGestureRecognizer(recognizer1)
            
            recognizer2 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier2:")
            recognizer2.delegate = self
            option2Zoom.addGestureRecognizer(recognizer2)
            
            option1VoteArrow.alpha = 0.8
            option2VoteArrow.alpha = 0.8
        }
        
        totalResponses = (self.QJoinObject["question"]!["option1Stats"] as! Int) + (QJoinObject["question"]!["option2Stats"] as! Int)
        if totalResponses != 0 {
            option1Percent = computePercents(1)
            option2Percent = 100 - option1Percent//computePercents(2)
        }
        
        option1Stats.backgroundColor = winColor
        option2Stats.backgroundColor = winColor
        option1Stats.alpha = 0.0
        option2Stats.alpha = 0.0
        if option1Percent < option2Percent {
            option1Stats.backgroundColor = mainColorBlue
        } else if option2Percent < option1Percent {
            option2Stats.backgroundColor = mainColorBlue
        }
        
        setOptionText()
        
        resp = "responses"
        if totalResponses == 1 { resp = "response" }
        responsesText.frame = CGRectMake(bounds.width - horizontalSpace - 100, bounds.height - 21, 100, 20)
        responsesText.textAlignment = NSTextAlignment.Right
        responsesText?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(12))!
        responsesText?.textColor = UIColor.darkGrayColor()
        responsesText.text = "\(totalResponses) \(resp)"
        
        textCenterStart.x = bounds.width/2 // bounds.width - option1Text.frame.width/2 - 2*horizontalSpace
        textCenterEnd.x = textCenterStart.x // bounds.width - textCenterStart.x
        voteCenterStart.x = option1Checkmark.frame.width/2
        
        imageCenterStart.x = option1Image.frame.width/2 + horizontalSpace
        imageCenterEnd.x = bounds.width - option1Image.frame.width/2 - 8
        option1PercentText.alpha = 0.0
        option2PercentText.alpha = 0.0
        if let test = QJoinObject["vote"] as? Int {
            option1PercentText.hidden = false
            option2PercentText.hidden = false
            option1VoteArrow.alpha = 0.0
            option2VoteArrow.alpha = 0.0
            if test == 1 {
                option1Checkmark.layer.borderWidth = 2.0
                option1Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
                option1Checkmark.alpha = 0.8
            } else if test == 2 {
                option2Checkmark.layer.borderWidth = 2.0
                option2Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
                option2Checkmark.alpha = 0.8
            }
        }
        
        if totalResponses > 0 { animateStatsBars(1.0) }
    }
    
    
    func animateStatsBars(duration: NSTimeInterval) {
        
        print("Animating stats bars")
        
        let statsHeight: CGFloat = option1Text.frame.height
        option1Stats.frame = CGRectMake(8, option1Text.frame.origin.y, myOption1LastWidth[QJoinObject.objectId!]! + option1Image.frame.width, statsHeight)
        option2Stats.frame = CGRectMake(8, option2Text.frame.origin.y, myOption2LastWidth[QJoinObject.objectId!]! + option2Image.frame.width, statsHeight)
        
        option1Stats.center.y = option1Image.center.y
        option2Stats.center.y = option2Image.center.y
        option1Stats.layer.cornerRadius = optionRadius
        option2Stats.layer.cornerRadius = optionRadius
        
        if myOption1LastWidth[QJoinObject.objectId!] == 0 && myOption2LastWidth[QJoinObject.objectId!] == 0 {
            
            option1Stats.alpha = 0.0
            option2Stats.alpha = 0.0
            
        } else {
            
            option1Stats.alpha = maxStatsBarAlpha
            option2Stats.alpha = maxStatsBarAlpha
        }
        
        
        // Animate if there is a change to animate, else change not
        let test1 = abs(myOption1LastWidth[QJoinObject.objectId!]! - CGFloat(self.option1Percent/100)*(self.option1Background.frame.width - self.option1Image.frame.width))
        let test2 = abs(myOption2LastWidth[QJoinObject.objectId!]! - CGFloat(self.option2Percent/100)*(self.option1Background.frame.width - self.option1Image.frame.width))
        
        if test1 > 0.05 || test2 > 0.05 {
            
            myOption1LastWidth[QJoinObject.objectId!] = CGFloat(self.option1Percent/100)*(self.option1Background.frame.width - self.option1Image.frame.width)
            myOption2LastWidth[QJoinObject.objectId!] = CGFloat(self.option2Percent/100)*(self.option1Background.frame.width - self.option1Image.frame.width)
            
            UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.option1Stats.frame = CGRectMake(8, self.option1Text.frame.origin.y, myOption1LastWidth[self.QJoinObject.objectId!]! + self.option1Image.frame.width, statsHeight)
                self.option2Stats.frame = CGRectMake(8, self.option2Text.frame.origin.y, myOption2LastWidth[self.QJoinObject.objectId!]! + self.option1Image.frame.width, statsHeight)
                self.option1Stats.center.y = self.option1Image.center.y
                self.option2Stats.center.y = self.option2Image.center.y
                self.option1Stats.alpha = self.maxStatsBarAlpha
                self.option2Stats.alpha = self.maxStatsBarAlpha
                self.option1PercentText.alpha = 1.0
                self.option2PercentText.alpha = 1.0
                
                }) { (isFinished) -> Void in }
        }
    }
    
    
    func computePercents(id: Int) -> Float {
        
        var optionPercent:Float = 0.0
        
        if id == 1 {
            optionPercent = Float((self.QJoinObject["question"]!["option1Stats"] as! Int))/Float(totalResponses)*100
        } else {
            optionPercent = Float((self.QJoinObject["question"]!["option2Stats"] as! Int))/Float(totalResponses)*100
        }
        
        return optionPercent
    }
    
    
    func setOptionText() {
        
        option1Text.frame = CGRectMake(option1Image.frame.width + 2*horizontalSpace, option1Image.frame.origin.y, bounds.width - 2*option1Image.frame.width - 4*horizontalSpace, 60)
        if let oText = self.QJoinObject["question"]!["option1Text"] as? String {
            option1Text.text = oText
        } else {
            option1Text.text = ""
        }
        option1Text.numberOfLines = 3
        option1Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option1Text.textAlignment = NSTextAlignment.Left
        option1Text?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(14))!
        option1Text?.textColor = UIColor.darkTextColor()
        
        option1PercentText.frame = CGRectMake(bounds.width - horizontalSpace - 60, option1Text.frame.origin.y, 60, 60)
        option1PercentText?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(18))!
        option1PercentText.textAlignment = NSTextAlignment.Center
        option1PercentText?.textColor = UIColor.darkTextColor()
        
        option2Text.frame = CGRectMake(option2Image.frame.width + 2*horizontalSpace, option2Image.frame.origin.y, bounds.width - 2*option2Image.frame.width - 4*horizontalSpace, 60)
        if let o2Text = self.QJoinObject["question"]!["option2Text"] as? String {
            option2Text.text = o2Text
            
        } else {
            option2Text.text = ""
        }
        option2Text.numberOfLines = 3
        option2Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option2Text.textAlignment = NSTextAlignment.Left
        option2Text?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(14))!
        option2Text?.textColor = UIColor.darkTextColor()
        
        option2PercentText.frame = CGRectMake(bounds.width - horizontalSpace - 60, option2Text.frame.origin.y, 60, 60)
        option2PercentText?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(18))!
        option2PercentText.textAlignment = NSTextAlignment.Center
        option2PercentText?.textColor = UIColor.darkTextColor()
        
        if totalResponses > 0 {
            option1PercentText.text = "\(Int(option1Percent))%"
            option2PercentText.text = "\(100 - Int(option1Percent))%"
        } else {
            option1PercentText.text = ""
            option2PercentText.text = ""
        }
        
    }
    
    
    func questionZoom(sender: UIButton!) {
        zoomPage = 0
        questionToView = QJoinObject["question"]! as? PFObject
        self.delegate?.segueToZoom()
    }
    
    func image1Zoom(sender: UIButton!) {
        if (QJoinObject["question"]!["option1ImageThumb"] as? PFFile != nil) {
            zoomPage = 0
            questionToView = QJoinObject["question"]! as? PFObject
            if (QJoinObject["question"]!["questionImageThumb"] as? PFFile != nil) { zoomPage++ }
            self.delegate?.segueToZoom()
        }
    }
    
    func image2Zoom(sender: UIButton!) {
        if (QJoinObject["question"]!["option2ImageThumb"] as? PFFile != nil) {
            zoomPage = 0
            questionToView = QJoinObject["question"]! as? PFObject
            if (QJoinObject["question"]!["questionImageThumb"] as? PFFile != nil) { zoomPage++ }
            if (QJoinObject["question"]!["option1ImageThumb"] as? PFFile != nil) { zoomPage++ }
            self.delegate?.segueToZoom()
        }
    }
    
    
    //MARK: - horizontal pan gesture methods
    func recognizerIdentifier1(recognizer: UIPanGestureRecognizer) {
        if(QJoinObject["vote"] as? Int) == nil {
            //disabled when first gesture recognized, to prevent swiping both options
            option2Zoom.enabled = false
            handlePan(recognizer, id: 1)
        }
    }
    func recognizerIdentifier2(recognizer: UIPanGestureRecognizer) {
        if(QJoinObject["vote"] as? Int) == nil {
            //disabled when first gesture recognized, to prevent swiping both options
            option1Zoom.enabled = false
            handlePan(recognizer, id: 2)
        }
    }
    func handlePan(recognizer: UIPanGestureRecognizer, id: Int) {
        
        let label = recognizer.view!
        let translation = recognizer.translationInView(self)
        let percentMoved = translation.x/(bounds.width - profilePicture.frame.width - 2*horizontalSpace)
        
        // Total amount the image view will move
        //let a = bounds.width - option1Image.frame.width - 2*horizontalSpace
        
        // Total amount the text box needs to move
        //let b = bounds.width - option1Text.frame.width - 4*horizontalSpace
        
        // Total amount the image bar BG will move
        //let c = a - imageBarExtraSpace
        
        if id == 1 {
            
            label.center = CGPoint(x: option1Offset + translation.x, y: label.center.y)
            option1Image.center = label.center
            option1Checkmark.center = CGPoint(x: option1Offset + translation.x, y: label.center.y)
            option1VoteArrow.center = option1Checkmark.center
            
            if percentMoved >= 0.5 {
                option1Checkmark.alpha = 0.8
                option1Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
                option1Checkmark.layer.borderWidth = 2.0
                option1VoteArrow.alpha = 0.0
            } else if percentMoved < 0.5 {
                option1Checkmark.alpha = 0.0
                option1VoteArrow.alpha = 0.8
            }
            
        } else {
            
            label.center = CGPoint(x: option2Offset + translation.x, y: label.center.y)
            option2Image.center = label.center
            option2Checkmark.center = CGPoint(x: option2Offset + translation.x, y: label.center.y)
            option2VoteArrow.center = option2Checkmark.center
            
            if percentMoved >= 0.5 {
                option2Checkmark.alpha = 0.8
                option2Checkmark.layer.borderColor = UIColor.whiteColor().CGColor
                option2Checkmark.layer.borderWidth = 2.0
                option2VoteArrow.alpha = 0.0
            } else if percentMoved < 0.5 {
                option2Checkmark.alpha = 0.0
                option2VoteArrow.alpha = 0.8
            }
        }
        
        //let xFromCenter = label.center.x - bounds.width / 2
        let rotation = CGAffineTransformMakeRotation(0)
        let stretch = CGAffineTransformScale(rotation, 1, 1)
        
        label.transform = stretch
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            // Had to move this from inside the animation block - didn't work there
            if percentMoved >= 0.5 { castVote(id) }
            
            // Re-enable buttons (disabled when first gestre recognized, to prevent swiping both options)
            option1Zoom.enabled = true
            option2Zoom.enabled = true
            
            let endX: CGFloat = label.frame.width/2 + 8
            
            if id == 1 {
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    label.center = CGPoint(x: endX, y: label.center.y)
                    self.option1Image.center = label.center
                    
                    self.option1Checkmark.center = CGPoint(x: endX, y: label.center.y)
                    self.option1VoteArrow.center = CGPoint(x: endX, y: label.center.y)
                    
                    if percentMoved >= 0.5 {
                        self.option1Checkmark.alpha = 0.8
                        self.option1VoteArrow.alpha = 0.0
                    } else if percentMoved < 0.5 {
                        self.option1Checkmark.alpha = 0.0
                        self.option1VoteArrow.alpha = 0.8
                    }
                    
                    }, completion: { (isFinished) -> Void in
                })
                
            } else {
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    label.center = CGPoint(x: endX, y: label.center.y)
                    self.option2Image.center = label.center
                    
                    self.option2Checkmark.center = CGPoint(x: endX, y: label.center.y)
                    self.option2VoteArrow.center = CGPoint(x: endX, y: label.center.y)
                    
                    if percentMoved >= 0.5 {
                        self.option2Checkmark.alpha = 0.8
                    } else {
                        self.option1Checkmark.alpha = 0.0
                    }
                    
                    }, completion: { (isFinished) -> Void in
                })
            }
        }
    }
    
    
    func castVote(optionId: Int) {
        
        print("CASTING VOTE")
        
        QJoinObject!.setObject(optionId, forKey: "vote")
        QJoinObject!["question"]!.incrementKey("option\(optionId)Stats")
//        QJoinObject.pinInBackgroundWithBlock { (success, error) -> Void in
//            
//            if error == nil {
//                print("Vote has been pinned from MyQs")
//            }
//        }
        
        QJoinObject!.saveEventually { (success, error) -> Void in
            if error == nil {
                
                print("Successful vote cast in SocialQs!")
                
                // SEND BADGE INCREMENT PUSH
                // Pull all "to" users
                let toUsersQuery = PFQuery(className: "QJoin")
                toUsersQuery.whereKey("question", equalTo: self.QJoinObject["question"])
                
                toUsersQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        if let temp = objects {
                            
                            print(temp)
                            
                            var toChannels: [String] = []
                            toChannels.removeAll(keepCapacity: true)
                            
                            for object in temp {
                                
                                toChannels.append("user_\(object["to"].objectId!!)")
                            }
                            
                            print(toChannels)
                            
                            let pushGeneral:PFPush = PFPush()
                            pushGeneral.setChannels(toChannels)
                            
                            // Create dictionary to send JSON to parse/to other devices
                            let dataGeneral: Dictionary = ["alert":"", "badge":"Increment", "content-available":"1", "action":"newVote", "qid":"\(self.QJoinObject.objectId!)"]
                            
                            pushGeneral.setData(dataGeneral)
                            
                            pushGeneral.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                
                                if error == nil {
                                    
                                    print("Badge for \(toChannels) sent!")
                                }
                            })
                        }
                    }
                })
            }
        }

        totalResponses++
        if totalResponses == 1 { resp = "response" }
        responsesText.text = "\(totalResponses) \(resp)"
        
        // Lock Q cell for voting
        if option1Zoom.gestureRecognizers != nil {
            option1Zoom.removeGestureRecognizer(recognizer1)
        }
        if option2Zoom.gestureRecognizers != nil {
            option2Zoom.removeGestureRecognizer(recognizer2)
        }

        // Update percentage stats and option text
        computePercents(optionId)
        setOptionText()
        animateStatsBars(2.0)
        
        // Remove badges!
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.badgeView.alpha = 0.0
            
            }) { (isFinished) -> Void in
                
                if self.badgeView.isDescendantOfView(self) {
                    self.badgeView.removeFromSuperview()
                }
                if self.badgeViewFrame.isDescendantOfView(self) {
                    self.badgeViewFrame.removeFromSuperview()
                }
        }
        
        // Update badge
        updateBadge("my")
        //NSNotificationCenter.defaultCenter().postNotificationName("refreshMyQsBadge", object: nil)
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
