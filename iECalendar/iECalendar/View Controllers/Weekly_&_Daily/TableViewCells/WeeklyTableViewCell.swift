//
//  WeeklyTableViewCell.swift
//  iECalendar
//
//  Created by Shalini on 29/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class WeeklyTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var minutesStackView: UIStackView!
    @IBOutlet weak var fifteenMinLabel: UILabel!
    @IBOutlet weak var thirtyMinLabel: UILabel!
    @IBOutlet weak var fourtyFiveMinLabel: UILabel!
    @IBOutlet weak var currentTimeView: UIView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var currentTimeTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
