//
//  CommentCell.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 22.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func likeClicked(_ sender: Any) {
    }
    @IBAction func dislikeClickedd(_ sender: Any) {
    }
    
}
