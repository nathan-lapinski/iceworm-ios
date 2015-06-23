//
//  StandardSignUpCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/23/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class StandardSignUpCell: UITableViewCell {

    @IBOutlet var standardTextLabel: UILabel!
    @IBOutlet var standardTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()    
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
