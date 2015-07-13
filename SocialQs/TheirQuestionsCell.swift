//
//  TheirQuestionsCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/16/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class TheirQuestionsCell: UITableViewCell {
    
    // Cell1/Cell2/Cell3
    @IBOutlet var asker: UILabel!
    @IBOutlet var question: UILabel!
    
    // Cell2/Cell3
    @IBOutlet var numberOfResponses: UILabel!
    @IBOutlet var myVote1: UILabel!
    @IBOutlet var myVote2: UILabel!
    
    // Cell1
    @IBOutlet var option1: UIButton!
    @IBOutlet var option2: UIButton!
    
    // Cell2
    @IBOutlet var option1ImageView: UIImageView!
    @IBOutlet var option2ImageView: UIImageView!
    @IBOutlet var option1Text: UILabel!
    @IBOutlet var option2Text: UILabel!
    @IBOutlet var bar1Width: NSLayoutConstraint!
    @IBOutlet var bar2Width: NSLayoutConstraint!
    
    // Cell3
    //@IBOutlet var myVotePhoto1: UILabel!
    //@IBOutlet var myVotePhoto2: UILabel!
    @IBOutlet var option1Image: UIImageView!
    @IBOutlet var option2Image: UIImageView!
    
}