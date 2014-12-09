//
//  MyTableViewCell.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet var img:UIImageView!
    @IBOutlet var title:UILabel!
    @IBOutlet var detail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
