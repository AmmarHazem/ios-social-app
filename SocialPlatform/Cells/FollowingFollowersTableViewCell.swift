//
//  FollowingFollowersTableViewCell.swift
//  SocialPlatform
//
//  Created by Ammar on 2/1/21.
//

import UIKit

class FollowingFollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }


    @IBAction func followingPressed(_ sender: UIButton) {
    }

    @IBAction func followersPressed(_ sender: UIButton) {
    }
    
    
    func configure(userModel: UserModel?) {
        if let userModel = userModel {
            followersButton.setTitle(String(userModel.followers.count), for: .normal)
            followingButton.setTitle(String(userModel.following.count), for: .normal)
        }
        else {
            followersButton.setTitle("", for: .normal)
            followingButton.setTitle("", for: .normal)
        }
    }
}
