//
//  SearchUser.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 9.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit

class SearchUser: UITableViewCell {

   
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var usernameCell: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        imageCell.layer.cornerRadius = imageCell.frame.height/2
        imageCell.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
}
