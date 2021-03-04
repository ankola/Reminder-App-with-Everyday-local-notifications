//
//  reminderTblCell.swift
//  reminderApp
//
//  Created by Savan Ankola on 03/03/21.
//

import UIKit

class reminderTblCell: UITableViewCell {

//    @IBOutlet weak var lblTitle: UILable!
//    @IBOutlet weak var lblDate: UILable!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
