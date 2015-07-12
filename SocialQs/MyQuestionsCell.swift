//
//  MyQuestionsCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/18/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class MyQuestionsCell: UITableViewCell {

    // myCell
    @IBOutlet var asker: UILabel!
    @IBOutlet var question: UILabel!
    @IBOutlet var option1Text: UILabel!
    @IBOutlet var option2Text: UILabel!
    @IBOutlet var option1ImageView: UIImageView!
    @IBOutlet var option2ImageView: UIImageView!
    @IBOutlet var numberOfResponses: UILabel!
    
    // myCell2
    @IBOutlet var option1Photo: UIImageView!
    @IBOutlet var option2Photo: UIImageView!
    @IBOutlet var question2: UILabel!
    @IBOutlet var asker2: UILabel!
    @IBOutlet var numberOfResponses2: UILabel!
}
