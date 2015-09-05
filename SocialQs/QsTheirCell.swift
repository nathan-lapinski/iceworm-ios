//
//  QsTheirCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/14/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsTheirCell: UITableViewCell {
    
//    @IBOutlet var profilePicture: UIImageView!
//    @IBOutlet var username: UILabel!
//    @IBOutlet var question: UILabel!
//    @IBOutlet var questionImage: UIImageView!
//    @IBOutlet var option1BackgroundImage: UIImageView!
//    @IBOutlet var option2BackgroundImage: UIImageView!
//    @IBOutlet var vote1Button: UIButton!
//    @IBOutlet var vote2Button: UIButton!
//    @IBOutlet var option1Label: UILabel!
//    @IBOutlet var option2Label: UILabel!
//    @IBOutlet var myVote1: UILabel!
//    @IBOutlet var myVote2: UILabel!
//    @IBOutlet var stats1: UILabel!
//    @IBOutlet var stats2: UILabel!
//    @IBOutlet var background: UIImageView!
//    @IBOutlet var questionZoom: UIButton!
//    @IBOutlet var option1Image: UIImageView!
//    @IBOutlet var option2Image: UIImageView!
//    @IBOutlet var option1Zoom: UIButton!
//    @IBOutlet var option2Zoom: UIButton!
//    @IBOutlet var checkmark1: UIImageView!
//    @IBOutlet var checkmark2: UIImageView!
//    @IBOutlet var progress1: UIImageView!
    //    @IBOutlet var progress2: UIImageView!
    
    var originalCenter1 = CGPoint()
    
    // NEW CELL
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var option1Container: UIImageView!
    @IBOutlet var option2Container: UIImageView!
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var username: UILabel!
    
    @IBOutlet var questionImage: UIButton!
    @IBOutlet var option1Image: UIButton!
    @IBOutlet var option2Image: UIButton!
    
    @IBOutlet var questionText: UILabel!
    @IBOutlet var option1Text: UILabel!
    @IBOutlet var option2Text: UILabel!
    @IBOutlet var numberOfResponses: UILabel!
    
    @IBOutlet var questionBackground: UIImageView!
    @IBOutlet var option1Background: UIImageView!
    @IBOutlet var option2Background: UIImageView!
    
    @IBOutlet var option1VoteButton: UIButton!
    @IBOutlet var option2VoteButton: UIButton!
    
    @IBOutlet var questionTextRightSpace: NSLayoutConstraint!
    @IBOutlet var option1TextLeftSpace: NSLayoutConstraint!
    @IBOutlet var option2TextLeftSpace: NSLayoutConstraint!
    @IBOutlet var progress1RightSpace: NSLayoutConstraint!
    @IBOutlet var progress2RightSpace: NSLayoutConstraint!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        option1Image = UIButton()
        option1Image.setImage(UIImage(named: "camera.png"), forState: UIControlState.Normal)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var gesture1 = UIPanGestureRecognizer(target: self, action: Selector("drag1:"))
        gesture1.delegate = self
        
        self.addGestureRecognizer(gesture1)
        option1Image.userInteractionEnabled = true
    }
    
    func drag1(gesture: UIPanGestureRecognizer) {
        
        println("3feJKbKBJYg6rUx5ric6T^V%E$^$WX&%R79R(%&%tPUOCUY(DOP:FO*V*Y(&*(^OV:")
        
        if gesture.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter1 = self.center
        }
        
        let translation = gesture.translationInView(self)
        let label = gesture.view!
        let option1TopSpace: CGFloat = 101.5
        
        label.center = CGPoint(x: originalCenter1.x + translation.x, y: option1TopSpace)//self.view.bounds.height / 2)// + translation.y)
        
        let xFromCenter = label.center.x - self.frame.size.width / 2
        //        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransformMakeRotation(0)
        var stretch = CGAffineTransformScale(rotation, 1, 1)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var endX: CGFloat = 0.0
            
            if xFromCenter <= 0 {
                endX = label.frame.width/2 + 8
            } else {
                endX = self.frame.width - label.frame.width/2 - 8
            }
            
            originalCenter1.x = endX
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                label.center = CGPoint(x: endX, y: option1TopSpace)//self.view.bounds.height / 2)
                
                }, completion: { (isFinished) -> Void in })
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
