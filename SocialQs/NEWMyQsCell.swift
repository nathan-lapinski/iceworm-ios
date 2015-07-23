//
//  NEWMyQsCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/15/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class NEWMyQsCell: UITableViewCell {
    
    // Both Cells
    @IBOutlet var question: UILabel!
    @IBOutlet var questionNarrow: UILabel!
    @IBOutlet var questionImage: UIImageView!
    @IBOutlet var numberOfResponses: UILabel!
    @IBOutlet var option1BackgroundImage: UIImageView!
    @IBOutlet var option2BackgroundImage: UIImageView!
    @IBOutlet var option1Label: UILabel!
    @IBOutlet var option2Label: UILabel!
    @IBOutlet var myVote1: UILabel!
    @IBOutlet var myVote2: UILabel!
    @IBOutlet var stats1: UILabel!
    @IBOutlet var stats2: UILabel!
    @IBOutlet var background: UIImageView!
    @IBOutlet var questionZoom: UIButton!
    
    // Cell2
    @IBOutlet var option1Image: UIImageView!
    @IBOutlet var option2Image: UIImageView!
    @IBOutlet var option1Zoom: UIButton!
    @IBOutlet var option2Zoom: UIButton!
    
}
