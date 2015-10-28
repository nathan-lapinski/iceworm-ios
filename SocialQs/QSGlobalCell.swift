//
//  QSGlobalCell.swift
//  SocialQs
//
//  Created by Brett Wiesman on 10/28/15.
//  Copyright © 2015 BookSix. All rights reserved.
//

import UIKit
import M13BadgeView

protocol GlobalTableViewCellDelegate {
    //func toDoItemDeleted()
    func segueToZoom()
}

class QSGlobalCell: UITableViewCell {
    
    var delegate: GlobalTableViewCellDelegate?
    
    var QJoinObject: PFObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
