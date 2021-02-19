//
//  LoginViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/8/21.
//

import UIKit

class LoginViewController: UIViewController {

    
    //MARK: - IBOutlits and variables
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var usernameErrorField: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    private let userDefaults = UserDefaults.standard
    private let loginService = LoginService()
    private var pressedLogin = false
    private var textFields: [UITextField]!

    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [usernameField, passwordField]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]
        usernameField.delegate = self
        passwordField.delegate = self
    }


    //MARK: - IBActions
    @IBAction func usernameChanged(_ sender: UITextField) {
        if pressedLogin {
            validForm()
        }
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        if pressedLogin {
            validForm()
        }
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        textFields.forEach { $0.resignFirstResponder()}
        submitForm()
    }
    
    
    //MARK: - Custom methods
    @discardableResult func validForm() -> Bool {
        let userNameErrorMsg = Utils.validateUsername(usernameField.text)
        let passwordErrorMsg = Utils.validatePassword(passwordField.text)
        usernameErrorField.text = userNameErrorMsg
        passwordErrorLabel.text = passwordErrorMsg
        return userNameErrorMsg.isEmpty && passwordErrorMsg.isEmpty
    }
    
    func submitForm() {
        pressedLogin = true
        if !validForm() { return }
        loadingIndicator.startAnimating()
        loginButton.isHidden = true
        
        loginService.login(username: usernameField.text!, password: passwordField.text!) { [weak self] (error, authModel) in
            self?.pressedLogin = false
            self?.loadingIndicator.stopAnimating()
            self?.loginButton.isHidden = false
            
            if let error = error {
                let alert = UIAlertController(title: "Something went wrong", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            if let authModel = authModel {
                self?.userDefaults.setValue(authModel.toDictionary(), forKey: K.authModelKey)
//                let mainStoryBoard = UIStoryboard(name: "Home", bundle: nil)
//                let homeVC = mainStoryBoard.instantiateViewController(identifier: "home") as! HomeViewController
//                homeVC.authModel = authModel
//                self?.navigationController?.setViewControllers([homeVC], animated: true)
                Utils.configureAndNavigateToHomeTabView(navigationController: self!.navigationController!, authModel: authModel)
            }
        }
    }
}


//MARK: - Text field delegate extension
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !loadingIndicator.isAnimating
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }
        else {
            submitForm()
            textField.resignFirstResponder()
        }
        return true
    }
}
