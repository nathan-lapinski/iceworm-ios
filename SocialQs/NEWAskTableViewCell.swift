//
//  NEWAskTableViewCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/7/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class NEWAskTableViewCell: UITableViewCell {

    // qCell1
    @IBOutlet var questionTextField: UITextField!
    
    // qCell2
    @IBOutlet var questionImageView: UIImageView!
    
    // qCell1 and qCell2
    @IBOutlet var whatQLabel1: UILabel!
    @IBOutlet var whatQLabel2: UILabel!
    
    // oCell1
    @IBOutlet var optionTextField: UITextField!
    
    // oCell2
    @IBOutlet var optionImageView: UIImageView!
    
    // oCell1 and oCell2
    @IBOutlet var cameraOutlet: UIButton!
    @IBOutlet var photoOutlet: UIButton!
    @IBOutlet var textOutlet: UIButton!
    

}
