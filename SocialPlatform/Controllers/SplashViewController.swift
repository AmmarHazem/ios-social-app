//
//  SplashViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/15/21.
//

import UIKit

class SplashViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let authModelData = self.userDefaults.value(forKey: K.authModelKey) as? [String: Any]
            {
                let authModel = AuthModel(fromDict: authModelData)
                Utils.configureAndNavigateToHomeTabView(navigationController: self.navigationController!, authModel: authModel)
            }
            else {
                let loginOrRegisterVC = self.storyboard!.instantiateViewController(identifier: "loginOrRegister")
                print("--- login nav")
                self.navigationController?.setViewControllers([loginOrRegisterVC], animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("--- prepare \(self.authModel.user.username) ")
//        print("--- destination \(segue.destination)")
//        if let homeVC = segue.destination as? HomeViewController {
//            print("--- homeVC")
//            homeVC.authModel = self.authModel
//        }
//        if let loginOrRegisterVC = segue.destination as? LoginOrRegisterViewController {
//            print("--- loginOrRegisterVC")
//            print(loginOrRegisterVC)
//        }
    }
}
