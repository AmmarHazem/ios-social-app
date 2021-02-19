//
//  CommentTableViewCell.swift
//  SocialPlatform
//
//  Created by Ammar on 1/23/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let postDetailsService = PostDetailsService()
    
    var delegate: CommentTableViewCellDelegate?
    var cellIndex: IndexPath!

    
    func configureCell(for commentModel: CommentModel?, url: URL, token: String) {
        commentLabel.text = ""
        usernameLabel.text = ""
        dateLabel.text = ""
        guard let model = commentModel else {
            fetchComment(url: url, token: token)
            return
        }
        self.loadingIndicator.stopAnimating()
        self.commentLabel.text = model.content
        self.usernameLabel.text = model.username
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        dateLabel.text = dateFormatter.string(from: model.created)
    }


    func fetchComment(url: URL, token: String) {
        postDetailsService.fetch(comment: url, token: token) { commentModel in
            self.delegate?.didFinishFetchingComment(model: commentModel, index: self.cellIndex)
        }
    }

}

protocol CommentTableViewCellDelegate {
    func didFinishFetchingComment(model: CommentModel?, index: IndexPath)
}
