//
//  CreateEventTextTableViewCell.swift
//  iECalendar
//

import UIKit

class CreateEventTextTableViewCell: UITableViewCell {

    @IBOutlet weak var addEventTextView: UITextView!
    @IBOutlet weak var addEventTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
