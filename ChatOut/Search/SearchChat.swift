//
//  SearchChat.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 9.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit

class SearchChat: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var numberOfPerson: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
