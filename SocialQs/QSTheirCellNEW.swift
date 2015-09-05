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
//    var originalCenter1 = CGPoint()
    var optionIdentifier: Int = 0
    var option1Offset: CGFloat = 38.0
    var option2Offset: CGFloat = 38.0
    var horizontalSpace: CGFloat = 8.0
    
    var questionBackground: UIImageView! = UIImageView()
    var profilePicture: UIImageView! = UIImageView()
    var questionPicture: UIImageView! = UIImageView()
    
    var option1Background: UIImageView = UIImageView()
    var option1Image: UIImageView! = UIImageView()
    
    var option2Background: UIImageView = UIImageView()
    var option2Image: UIImageView! = UIImageView()
    
    var usernameLabel: UILabel! = UILabel()
    var questionText: UILabel! = UILabel()
    var option1Text: UILabel! = UILabel()
    var option2Text: UILabel! = UILabel()
    
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
        
        self.addSubview(option1Image)
        self.addSubview(option2Image)
        
        // Make cell non-selectable
        selectionStyle = .None
        
        // add a pan recognizers
        var recognizer1 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier1:")
        recognizer1.delegate = self
        option1Image.addGestureRecognizer(recognizer1)
        option1Image.userInteractionEnabled = true
        
        var recognizer2 = UIPanGestureRecognizer(target: self, action: "recognizerIdentifier2:")
        recognizer2.delegate = self
        option2Image.addGestureRecognizer(recognizer2)
        option2Image.userInteractionEnabled = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        questionBackground.frame = CGRectMake(8, 8, bounds.width - 16, 60)
        questionBackground.layer.cornerRadius = questionBackground.frame.height/2
        questionBackground.backgroundColor = mainColorBlue
        
        profilePicture.frame = CGRectMake(8, 8, 60, 60)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.backgroundColor = UIColor.whiteColor()
        
        usernameLabel.frame = CGRectMake(68, 6, 150, 20)
        usernameLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(12))!
        usernameLabel?.textColor = UIColor.whiteColor()
        usernameLabel.text = "usernameTest"
        
        questionText.frame = CGRectMake(76, 24, bounds.width - 120 - 16, 50)
        questionText.numberOfLines = 2
        questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
        questionText.textAlignment = NSTextAlignment.Center
        questionText?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
        questionText?.textColor = UIColor.whiteColor()
        questionText.text = "How much wood would a woodchuck fuck if a fuckchuck could wood wood?"
        questionText.sizeToFit()
        
        questionPicture.frame = CGRectMake(bounds.width - 60 - horizontalSpace, 8, 60, 60)
        questionPicture.layer.cornerRadius = questionPicture.frame.width/2
        questionPicture.backgroundColor = UIColor.whiteColor()
        
        option1Background.frame = CGRectMake(horizontalSpace, 71, bounds.width - 2*horizontalSpace, 60)
        option1Background.layer.cornerRadius = 10
//        option1Background.layer.borderWidth = 1.0
//        option1Background.layer.borderColor = UIColor.whiteColor().CGColor
        option1Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        option2Background.frame = CGRectMake(horizontalSpace, 134, bounds.width - 2*horizontalSpace, 60)
        option2Background.layer.cornerRadius = 10
//        option2Background.layer.borderWidth = 1.0
//        option2Background.layer.borderColor = UIColor.whiteColor().CGColor
        option2Background.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        option1Image.frame = CGRectMake(horizontalSpace, 71, 60, 60)
        option1Image.layer.cornerRadius = 10
        option1Image.backgroundColor = UIColor.whiteColor()
        
        option2Image.frame = CGRectMake(horizontalSpace, 134, 60, 60)
        option2Image.layer.cornerRadius = 10
        option2Image.backgroundColor = UIColor.whiteColor()
        
        option1Text.frame = CGRectMake(option1Image.frame.width + 2*horizontalSpace, option1Image.frame.origin.y, bounds.width - option1Image.frame.width - 4*horizontalSpace, 60)
        option1Text.backgroundColor = UIColor.greenColor()
        option1Text.numberOfLines = 3
        option1Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option1Text.textAlignment = NSTextAlignment.Center
        option1Text?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
        option1Text?.textColor = UIColor.whiteColor()
        option1Text.text = "A wood chuck would fuck wood chuck fuck nut chuck butt could chuck what a fuck chuck could chuck."
        
        option2Text.frame = CGRectMake(option2Image.frame.width + 2*horizontalSpace, option2Image.frame.origin.y, bounds.width - option2Image.frame.width - 4*horizontalSpace, 60)
        option2Text.backgroundColor = UIColor.greenColor()
        option2Text.numberOfLines = 3
        option2Text.lineBreakMode = NSLineBreakMode.ByWordWrapping
        option2Text.textAlignment = NSTextAlignment.Center
        option2Text?.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))!
        option2Text?.textColor = UIColor.whiteColor()
        option2Text.text = "A wood chuck would fuck wood chuck fuck nut chuck butt could chuck what a fuck chuck could chuck."
    }
    
    
    //MARK: - horizontal pan gesture methods
    func recognizerIdentifier1(recognizer: UIPanGestureRecognizer) { println("1");handlePan(recognizer, id: 1) }
    func recognizerIdentifier2(recognizer: UIPanGestureRecognizer) { println("2");handlePan(recognizer, id: 2) }
    func handlePan(recognizer: UIPanGestureRecognizer, id: Int) {
        
        //var image: UIImageView
        let label = recognizer.view!
        let translation = recognizer.translationInView(self)
        var percentMoved = translation.x/(bounds.width - option1Image.frame.width - 2*horizontalSpace)
//        var originalCenter: CGPoint = CGPoint()
        var textCenterStart = CGPoint()
        textCenterStart.x = bounds.width - option1Text.frame.width/2 - 2*horizontalSpace
        var imageCenterStart = CGPoint()
        imageCenterStart.x = option1Image.frame.width/2 + horizontalSpace
        
        // Total amount the image view will move
        let a = bounds.width - option1Image.frame.width - 2*horizontalSpace
        
        // Total amount the text box needs to move
        let b = bounds.width - option1Text.frame.width - 4*horizontalSpace
        
        //if recognizer.state == .Began { originalCenter = label.center }
        
        if id == 1 {
            
            label.center = CGPoint(x: option1Offset + translation.x, y: label.center.y)
            let percentMoved = (label.center.x - imageCenterStart.x) / a
            option1Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: option1Text.center.y)
            
        } else {
            
            label.center = CGPoint(x: option2Offset + translation.x, y: label.center.y)
            let percentMoved = (label.center.x - imageCenterStart.x) / a
            option2Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: option2Text.center.y)
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
                    
                    if xFromCenter <= 0 {
                        label.center = CGPoint(x: endX, y: label.center.y)
                    } else {
                        label.center = CGPoint(x: endX, y: label.center.y)
                    }
                    
                    let percentMoved = (label.center.x - imageCenterStart.x) / a
                    self.option1Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: self.option1Text.center.y)
                    
                    }, completion: { (isFinished) -> Void in
                })
            }
            else {
                option2Offset = endX
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    if xFromCenter <= 0 {
                        label.center = CGPoint(x: endX, y: label.center.y)
                    } else {
                        label.center = CGPoint(x: endX, y: label.center.y)
                    }
                    
                    let percentMoved = (label.center.x - imageCenterStart.x) / a
                    self.option2Text.center = CGPoint(x: textCenterStart.x - b*percentMoved, y: self.option2Text.center.y)
                    
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
