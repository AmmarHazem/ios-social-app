//
//  PostTableViewCell.swift
//  SocialPlatform
//
//  Created by Ammar on 1/15/21.
//

import UIKit

class PostTableViewCell: UITableViewCell {


    //MARK: - IBOutlets and variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var delegate: PostTableViewCellDelegate?


    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
        dateLabel.text = ""
        likesLabel.text = ""
        commentsLabel.text = ""
    }
    
    
    func fetch(post: PostModel?, with url: URL?) {
        if let post = post {
            titleLabel.text = post.title
            likesLabel.text = "\(post.likes.count)"
            commentsLabel.text = "\(post.comments.count)"
        }
        else if let url = url {
            PostDetailsService().fetchPost(with: url) { post in
                if let post = post {
                    self.delegate?.didFetch(post: post)
                }
            }
        }
    }
}


protocol PostTableViewCellDelegate {
    
    func didFetch(post: PostModel)
}
