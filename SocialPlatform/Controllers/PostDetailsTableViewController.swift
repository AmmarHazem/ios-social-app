//
//  PostDetailsTableViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/23/21.
//

import UIKit

class PostDetailsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets and Variables
    let postDetailsService = PostDetailsService()
    
    var post: PostModel!
    var authModel: AuthModel!
    var postLikesCount: Int!
    var likedByCurrentUser: Bool?
    var commentModels: [CommentModel?] = []

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = post.title
        commentModels = post.comments.map({ (url) -> CommentModel? in
            nil
        })
    }

    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return postContentCell(tableView, cellForRowAt: indexPath)
        }
        else if indexPath.row == 1 {
            return postLikesAndCommentsCell(tableView, cellForRowAt: indexPath)
        }
        return postCommentCell(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    //MARK: - Custom Methods
    func postContentCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postContentCellID, for: indexPath) as! PostContentTableViewCell
        cell.contentLabel.text = post.content
        return cell
    }
    
    func postLikesAndCommentsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postLikesAndCommentsCellID, for: indexPath) as! PostLikesAndCommentsTableViewCell
        cell.configureCell(post: post, with: authModel, index: indexPath)
        cell.delegate = self
        return cell
    }

    func postCommentCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row - 2
        let cell = tableView.dequeueReusableCell(withIdentifier: K.commentCellID, for: indexPath) as! CommentTableViewCell
        cell.cellIndex = indexPath
        cell.delegate = self
        cell.configureCell(for: commentModels[index], url: post.comments[index], token: authModel.token)
        return cell
    }
}


//MARK: - Comment cell delegate
extension PostDetailsTableViewController: CommentTableViewCellDelegate {
    func didFinishFetchingComment(model: CommentModel?, index: IndexPath) {
        if let model = model {
            self.commentModels[index.row - 2] = model
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }
}


//MARK: - Likes and Comments Cell Delegate
extension PostDetailsTableViewController: LikesAndCommentCellDelegate {
    func didAdd(comment model: CommentModel) {
        self.commentModels.insert(nil, at: 0)
        self.post.addComment(url: model.url)
        self.tableView.reloadData()
    }
    
    func reloadCell(in indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
