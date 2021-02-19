//
//  Utils.swift
//  SocialPlatform
//
//  Created by Ammar on 1/11/21.
//

import UIKit


struct Utils {
    
    static func logout(viewController: UIViewController) {
        UserDefaults.standard.setValue(nil, forKey: K.authModelKey)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginOrRegisterVC = mainStoryboard.instantiateViewController(identifier: "loginOrRegister")
        viewController.navigationController?.setViewControllers([loginOrRegisterVC], animated: true)
    }
    
    static func configureAndNavigateToHomeTabView(navigationController: UINavigationController, authModel: AuthModel) {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeTabBar = homeStoryboard.instantiateViewController(identifier: "homeTabBar") as! UITabBarController
        
        if let homeVC = homeTabBar.viewControllers?.first as? HomeViewController {
            homeVC.authModel = authModel
        }
        if let profileVC = homeTabBar.viewControllers?.last as? ProfileTableViewController {
            profileVC.authModel = authModel
        }
        navigationController.setViewControllers([homeTabBar], animated: true)
    }
    
    static func validateUsername(_ username: String?) -> String {
        if username?.isEmpty ?? true {
            return " - Please enter your user name"
        }
        else if username?.count ?? 0 < 3 {
            return " - Username can't be less than 3 characters"
        }
        return ""
    }
    
    static func validatePassword(_ password: String?) -> String {
        if password?.isEmpty ?? true {
            return " - Please enter your password"
        }
        else if password?.count ?? 0 < 6 {
            return " - Password can't be less than 6 characters"
        }
        return ""
    }
}
