//
//  HomeViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/10/21.
//

import UIKit

enum SortBy {
    case alphbetical
    case date
}


class HomeViewController: UIViewController {
    
    
    //MARK: - IBOutlets and variables
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!

    private let sectionHeaderDateFormatter = DateFormatter()

    private var homeService = HomeService()
    private var sortBy = SortBy.date
    private var timelineModel: TimelineModel?
    private var datePostsSections: [PostsSectionModel<Date>]?
    private var alphabeticalPostsSections: [PostsSectionModel<String>]?

    var authModel: AuthModel!
    private var selectedPost: PostModel?


    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tabBarController?.navigationController?.navigationBar.largeContentTitle = "Home"
//        self.tabBarController?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]

        tableView.isHidden = true
        loadingIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        homeService.delegate = self
        
        sectionHeaderDateFormatter.dateFormat = "dd MMMM yyyy"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("--- home did appear")
        let logoutIcon = UIImage(systemName: "arrowshape.turn.up.backward.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        let logoutBarButton = UIBarButtonItem(image: logoutIcon, style: .plain, target: self, action: #selector(showLogoutAlert))
        
        let sortIcon = UIImage(systemName: "arrow.up.arrow.down")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        let sortBarButton = UIBarButtonItem(image: sortIcon, style: .plain, target: self, action: #selector(sortPosts))
        
        let createPostIcon = UIImage(systemName: "plus.circle.fill")?.withTintColor(.systemIndigo ,renderingMode: .alwaysOriginal)
        let createPostButton = UIBarButtonItem(image: createPostIcon, style: .plain, target: self, action: #selector(segueToCreatePost))
        
        let navItemButtons = [logoutBarButton, sortBarButton, createPostButton]
        self.tabBarController?.navigationItem.setRightBarButtonItems(navItemButtons, animated: true)

//        self.navigationItem.setRightBarButtonItems(navItemButtons, animated: true)
        self.tabBarController?.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]
        self.tabBarController?.title = "Home"
        homeService.getHomeTimeline(token: authModel.token)
    }
    
    
    //MARK: - Custom Methods
    
    @objc func segueToCreatePost() {
        self.performSegue(withIdentifier: K.homeToCreatePostSegue, sender: self)
    }
    
    @objc func sortPosts() {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { aciton in
            if let posts = self.timelineModel?.results,
               self.sortBy != .date {
                self.sortBy = .date
                self.datePostsSections = self.homeService.groupIntoSectionsByDate(posts: posts)
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Alphabetical", style: .default, handler: { action in
            if let posts = self.timelineModel?.results,
               self.sortBy != .alphbetical {
                self.sortBy = .alphbetical
                self.alphabeticalPostsSections = self.homeService.groupIntoSectionsAlphabetically(posts: posts, sortDesc: false)
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postDetailsTableViewController = segue.destination as? PostDetailsTableViewController {
            postDetailsTableViewController.authModel = authModel
            postDetailsTableViewController.post = selectedPost
        }
        else if let createPostVC = segue.destination as? CreatePostViewController {
            createPostVC.token = authModel.token
        }
    }
}


//MARK: - Home service delegate
extension HomeViewController: HomeServiceDelegate {
    func didFetchTimeline(model: TimelineModel?, error: Error?) {
        loadingIndicator.stopAnimating()
        tableView.isHidden = false
        
        if let error = error {
            errorLabel.text = "error: \(error.localizedDescription)"
            errorLabel.isHidden = false
            tableView.isHidden = true
            return
        }
        
        datePostsSections = homeService.groupIntoSectionsByDate(posts: model!.results)
        timelineModel = model
        tableView.reloadData()
    }
}


//MARK: - Table view data source
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sortBy == .date {
            return datePostsSections?.count ?? 0
        }
        return alphabeticalPostsSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sortBy == .date {
            guard let sections = datePostsSections else { return "" }
            return sectionHeaderDateFormatter.string(from: sections[section].section)
        }
        guard let sections = alphabeticalPostsSections else { return "" }
        return sections[section].section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortBy == .date {
            guard let sections = datePostsSections else { return 0 }
            return sections[section].posts.count
        }
        guard let sections = alphabeticalPostsSections else { return 0 }
        return sections[section].posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: K.postCellID) as! PostTableViewCell
        let post: PostModel
        if sortBy == .date {
            post = datePostsSections![indexPath.section].posts[indexPath.row]
        }
        else {
            post = alphabeticalPostsSections![indexPath.section].posts[indexPath.row]
        }
        let username = post.user.absoluteString.split(separator: "/").last
        cell.titleLabel.text = post.title
        cell.dateLabel.text = String(username ?? "")
        cell.likesLabel.text = "\(post.likes.count)"
        cell.commentsLabel.text = "\(post.comments.count)"
        return cell
    }
}


//MARK: - Table View Delegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if sortBy == .alphbetical {
            selectedPost = alphabeticalPostsSections![indexPath.section].posts[indexPath.row]
        }
        else {
            selectedPost = datePostsSections![indexPath.section].posts[indexPath.row]
        }
        self.performSegue(withIdentifier: K.homeToPostDetailsTableView, sender: self)
    }
}
