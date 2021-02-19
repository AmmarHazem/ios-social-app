//
//  ViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/8/21.
//

import UIKit

class LoginOrRegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        if segue.destination is LoginViewController {
            backButtonItem.tintColor = .systemIndigo
        }
        else {
            backButtonItem.tintColor = .systemYellow
        }
        self.navigationItem.backBarButtonItem = backButtonItem
    }
}
