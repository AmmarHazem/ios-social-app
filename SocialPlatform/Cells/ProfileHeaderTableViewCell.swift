//
//  ProfileHeaderTableViewCell.swift
//  SocialPlatform
//
//  Created by Ammar on 2/1/21.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(userModel: UserModel?, img data: Data?, authModel: AuthModel) {
        if let userModel = userModel {
            nameLabel.text = userModel.name.isEmpty ? userModel.username : userModel.name
            if userModel.bio.isEmpty {
                bioLabel.isHidden = true
            }
            else {
                bioLabel.text = userModel.bio
            }
        }
        else {
            nameLabel.text = authModel.user.name.isEmpty ? authModel.user.username : authModel.user.name
            bioLabel.text = authModel.user.bio
        }
        if let data = data {
            profileImg.image = UIImage(data: data)
        }
//        if let imgURLStr = authModel.user.image,
//           let imgURL = URL(string: imgURLStr) {
//            print("--- fetching img data")
//            guard let imgData = try? Data(contentsOf: imgURL) else { return }
//            print("--- done fetching")
//            profileImg.image = UIImage(data: imgData)
//        }
    }

}
