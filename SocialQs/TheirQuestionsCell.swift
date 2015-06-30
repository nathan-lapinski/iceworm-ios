//
//  TheirQuestionsCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/16/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class TheirQuestionsCell: UITableViewCell {
    
    // Both Cell1 and Cell2
    @IBOutlet var asker: UILabel!
    @IBOutlet var question: UILabel!
    
    // Cell1
    @IBOutlet var option1: UIButton!
    @IBOutlet var option2: UIButton!
    //@IBOutlet var results: UIButton!
    
    // Cell2
    @IBOutlet var option1ImageView: UIImageView!
    @IBOutlet var option2ImageView: UIImageView!
    @IBOutlet var option1Text: UILabel!
    @IBOutlet var option2Text: UILabel!
    @IBOutlet var numberOfResponses: UILabel!
    @IBOutlet var myVote1: UILabel!
    @IBOutlet var myVote2: UILabel!
    @IBOutlet var bar1Width: NSLayoutConstraint!
    @IBOutlet var bar2Width: NSLayoutConstraint!
    
}
