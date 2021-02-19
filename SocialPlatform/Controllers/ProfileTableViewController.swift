//
//  ProfileTableViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 2/1/21.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets and Variables
    let profileService = ProfileService()
    var authModel: AuthModel!
    var imgData: Data?
    var userModel: UserModel?
    var posts = [PostModel?]()
    var selectedPost: PostModel?
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.title = "Profile"

        let logoutIcon = UIImage(systemName: "arrowshape.turn.up.backward.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        let logoutBarButton = UIBarButtonItem(image: logoutIcon, style: .plain, target: self, action: #selector(showLogoutAlert))
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([logoutBarButton], animated: true)
        
    }
    
    
    //MARK: - Custom Methods
    
    func fetchProfile() {
        print("--- fetchProfile")
        profileService.fetchProfile(with: authModel.token) { userModel in
            self.userModel = userModel
            if let userModel = userModel {
                self.fetchImgData()
                self.posts = userModel.posts?.map({ (url) -> PostModel? in
                    if let post = self.posts.first(where: { post -> Bool in
                        post?.url == url
                    }) {
                        return post
                    }
                    return nil
                }) ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchImgData() {
        print("--- fetchImgData")
        guard let imgURLStr = userModel?.image,
              let imgURL = URL(string: imgURLStr),
              imgData == nil else { return }
        DispatchQueue.global().async { [weak self] in
            self?.imgData = try? Data(contentsOf: imgURL)
//            print("--- img data \(String(describing: self?.imgData))")
            if self?.imgData != nil {
                DispatchQueue.main.async {
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    @objc func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            alert.dismiss(animated: true, completion: nil)
            Utils.logout(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.profileCellID, for: indexPath) as! ProfileHeaderTableViewCell
            cell.configureCell(userModel: self.userModel, img: imgData, authModel: authModel)
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.followersFollowingCellID, for: indexPath) as! FollowingFollowersTableViewCell
            cell.configure(userModel: userModel)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postCellID, for: indexPath) as! PostTableViewCell
        cell.delegate = self
        let urlIndex = indexPath.row - 2
        let postURL = userModel?.posts?[urlIndex]
        let post = self.posts[urlIndex]
        if let post = post {
            cell.titleLabel.text = post.title
            cell.likesLabel.text = "\(post.likes.count)"
            cell.commentsLabel.text = "\(post.comments.count)"
        }
        else {
            cell.fetch(post: nil, with: postURL)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row > 1 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.selectedPost = self.posts[indexPath.row - 2]
        self.performSegue(withIdentifier: K.profileToPostDetailsSegue, sender: self)
//        let postDetailsTVC = PostDetailsTableViewController()
//        postDetailsTVC.post = selectedPost
//        self.navigationController?.pushViewController(postDetailsTVC, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("--- prepare")
        if let postDetailsTVC = segue.destination as? PostDetailsTableViewController {
            print("--- for post details")
            postDetailsTVC.authModel = self.authModel
            postDetailsTVC.post = self.selectedPost
        }
    }

}


//MARK: - Post Cell Delegate
extension ProfileTableViewController: PostTableViewCellDelegate {
    
    func didFetch(post: PostModel) {
        guard let index = self.posts.firstIndex(where: { $0 == nil }) else { return }
        print("--- insert index \(index)")
        self.posts[index] = post
        self.tableView.reloadData()
    }
}
