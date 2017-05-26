//
//  TodayItemCell.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/5/26.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit

class TodayItemCell: UITableViewCell {

    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
