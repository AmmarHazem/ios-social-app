//
//  ProfileViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 2/1/21.
//

import UIKit

class ProfileViewController: UIViewController {

    
    //MARK: - IBOutlets and variables
    @IBOutlet weak var profileImg: UIImageView!
    var authModel: AuthModel!

    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.title = "Profile"
    }

}
