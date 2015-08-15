//
//  QsTheirCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/14/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class QsTheirCell: UITableViewCell {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var question: UILabel!
    @IBOutlet var questionImage: UIImageView!
    @IBOutlet var numberOfResponses: UILabel!
    @IBOutlet var option1BackgroundImage: UIImageView!
    @IBOutlet var option2BackgroundImage: UIImageView!
    @IBOutlet var vote1Button: UIButton!
    @IBOutlet var vote2Button: UIButton!
    @IBOutlet var option1Label: UILabel!
    @IBOutlet var option2Label: UILabel!
    @IBOutlet var myVote1: UILabel!
    @IBOutlet var myVote2: UILabel!
    @IBOutlet var stats1: UILabel!
    @IBOutlet var stats2: UILabel!
    @IBOutlet var background: UIImageView!
    @IBOutlet var questionZoom: UIButton!
    @IBOutlet var option1Image: UIImageView!
    @IBOutlet var option2Image: UIImageView!
    @IBOutlet var option1Zoom: UIButton!
    @IBOutlet var option2Zoom: UIButton!
    @IBOutlet var questionTextRightSpace: NSLayoutConstraint!
    @IBOutlet var option1TextLeftSpace: NSLayoutConstraint!
    @IBOutlet var option2TextLeftSpace: NSLayoutConstraint!
    @IBOutlet var progress1: UIImageView!
    @IBOutlet var progress2: UIImageView!
    @IBOutlet var progress1RightSpace: NSLayoutConstraint!
    @IBOutlet var progress2RightSpace: NSLayoutConstraint!
    
}
