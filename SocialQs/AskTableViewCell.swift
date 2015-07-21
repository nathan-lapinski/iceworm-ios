//
//  AskTableViewCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 7/20/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class AskTableViewCell: UITableViewCell {
    
    // qCell
    @IBOutlet var questionTextField: UITextField!
    @IBOutlet var addQPhoto: UIButton!
    @IBOutlet var questionImageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    
    // oCell
    @IBOutlet var option1TextField: UITextField!
    @IBOutlet var option2TextField: UITextField!
    @IBOutlet var addO1Photo: UIButton!
    @IBOutlet var addO2Photo: UIButton!
    @IBOutlet var option1ImageView: UIImageView!
    @IBOutlet var option2ImageView: UIImageView!
    
    // Buttons Cell
    @IBOutlet var groupies: UIButton!
    @IBOutlet var submit: UIButton!
    @IBOutlet var clear: UIButton!
    @IBOutlet var privacy: UIButton!
    
}