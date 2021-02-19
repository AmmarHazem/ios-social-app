//
//  PostDetailsViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/22/21.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    
    //MARK: - IBOutlets and Variables
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    let postDetailsService = PostDetailsService()
    
    var post: PostModel!
    var authModel: AuthModel!
    var postLikesCount: Int!
    var likedByCurrentUser: Bool?

    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = post.title
        contentLabel.text = post.content
        postLikesCount = post.likes.count
        likesLabel.text = String(postLikesCount)
        
        if post.likes.contains(authModel.user.username) {
            likedByCurrentUser = true
            likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        else {
            likedByCurrentUser = false
            likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
    }


    //MARK: - IBActions
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if likedByCurrentUser ?? false {
            unlikePost(button: sender)
        }
        else {
            likePost(button: sender)
        }
    }
    
    
    //MARK: - Custom Methods
    func unlikePost(button: UIButton) {
        likedByCurrentUser = false
        button.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        postLikesCount -= 1
        likesLabel.text = String(postLikesCount)
        postDetailsService.toggleLike(for: post.url, token: authModel.token) { success in
            if !success {
                self.likedByCurrentUser = true
                button.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }
        }
    }
    
    func likePost(button: UIButton) {
        likedByCurrentUser = true
        button.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        postLikesCount += 1
        likesLabel.text = String(postLikesCount)
        postDetailsService.toggleLike(for: post.url, token: authModel.token) { success in
            if !success {
                self.likedByCurrentUser = false
                button.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }
    }
}
