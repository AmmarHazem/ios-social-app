//
//  PostLikesAndCommentsTableViewCell.swift
//  SocialPlatform
//
//  Created by Ammar on 1/23/21.
//

import UIKit

class PostLikesAndCommentsTableViewCell: UITableViewCell {

    //MARK: - IBOutlets and Variables
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    
    let postDetailsService = PostDetailsService()
    
    var delegate: LikesAndCommentCellDelegate?
    var likedByCurrentUser = false
    var likesCount = 0
    var indexPath: IndexPath?
    var post: PostModel!
    var authModel: AuthModel!
    
    var likedButtonImg: UIImage? {
        UIImage(systemName: "hand.thumbsup.fill")
    }
    var notLikedButtonImg: UIImage? {
        UIImage(systemName: "hand.thumbsup")
    }


    //MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentTextField.delegate = self
    }


    //MARK: - IBActions
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if likedByCurrentUser {
            unlikePost(sender)
        }
        else {
            likePost(sender)
        }
    }

    @IBAction func commentButtonPressed(_ sender: UIButton) {
        guard let commentText = commentTextField.text,
              !commentText.isEmpty else { return }
        sender.isHidden = true
        loadingIndicator.startAnimating()
        commentTextField.text = ""
        commentTextField.resignFirstResponder()
        postDetailsService.addComment(token: authModel.token, postURL: post.url, content: commentText) { commentModel in
            if let commentModel = commentModel {
                sender.isHidden = false
                self.loadingIndicator.stopAnimating()
                self.delegate?.didAdd(comment: commentModel)
            }
        }
    }
    
    
    //MARK: - Custom Methods
    
    func likePost(_ button: UIButton) {
        likedByCurrentUser = true
        likesCount += 1
        likesLabel.text = "\(likesCount)"
        likeButton.setBackgroundImage(likedButtonImg, for: .normal)
        postDetailsService.toggleLike(for: post.url, token: authModel.token) { success in
            if !success {
                DispatchQueue.main.async {
                    self.unlikePost(button)
                }
            }
        }
    }
    
    func unlikePost(_ button: UIButton) {
        likedByCurrentUser = false
        likesCount -= 1
        likesLabel.text = "\(likesCount)"
        likeButton.setBackgroundImage(notLikedButtonImg, for: .normal)
        postDetailsService.toggleLike(for: post.url, token: authModel.token) { success in
            if !success {
                DispatchQueue.main.async {
                    self.likePost(button)
                }
            }
        }
    }
    
    func configureCell(post: PostModel, with authModel: AuthModel, index: IndexPath?) {
        self.authModel = authModel
        self.post = post
        indexPath = index
        likesCount = post.likes.count
        likesLabel.text = "\(likesCount)"
        
        if post.likes.contains(authModel.user.username) {
            likedByCurrentUser = true
            likeButton.setBackgroundImage(likedButtonImg, for: .normal)
        }
        else {
            likedByCurrentUser = false
            likeButton.setBackgroundImage(notLikedButtonImg, for: .normal)
        }
    }
}


//MARK: - Comment field delegate
extension PostLikesAndCommentsTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentButtonPressed(commentButton)
        return true
    }
}


//MARK: - LikesAndCommentCellDelegate
protocol LikesAndCommentCellDelegate {
    func reloadCell(in indexPath: IndexPath)
    
    func didAdd(comment model: CommentModel)
}
