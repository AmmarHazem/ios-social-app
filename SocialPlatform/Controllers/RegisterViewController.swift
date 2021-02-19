//
//  RegisterViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/8/21.
//

import UIKit

class RegisterViewController: UIViewController {

    
    //MARK: - IBOutlets and variables
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let userDefaults = UserDefaults.standard
    private let registerService = RegisterService()
    private var didPressSubmit = false
    private var isLoading = false
    private var textFields: [UITextField]!
    private var authModel: AuthModel?


    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [usernameField, passwordField, confirmPasswordField]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
        submitButton.isEnabled = false
        submitButton.isHidden = true
        
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }


    //MARK: - IBActions
    @IBAction func confirmPasswordTextDidChange(_ sender: UITextField) {
        showSubmitButton()
        if didPressSubmit {
            validateForm()
        }
    }


    @IBAction func usernameTextDidChange(_ sender: UITextField) {
        showSubmitButton()
        if didPressSubmit {
            validateForm()
        }
    }
    

    @IBAction func passwordTextDidChange(_ sender: UITextField) {
        showSubmitButton()
        if didPressSubmit {
            validateForm()
        }
    }

    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        submitForm()
    }
    
    
    //MARK: - Custom methods
    func submitForm() {
        didPressSubmit = true
        if !validateForm() { return }
        textFields.forEach { field in field.resignFirstResponder() }
        
        submitButton.isHidden = true
        loadingIndicator.startAnimating()
        isLoading = true
        
        let formData: [String: String] = ["username": usernameField.text!, "password1": passwordField.text!, "password2": confirmPasswordField.text!]
        registerService.submitForm(data: formData) { [weak self] authModel, error in
            self?.loadingIndicator.stopAnimating()
            self?.submitButton.isHidden = false
            self?.isLoading = false
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            guard let authModel = authModel else { return }
            self?.userDefaults.setValue(authModel.toDictionary(), forKey: K.authModelKey)
            Utils.configureAndNavigateToHomeTabView(navigationController: self!.navigationController!, authModel: authModel)
//            self?.authModel = authModel
//            let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
//            let homeVC = mainStoryboard.instantiateViewController(identifier: "home") as! HomeViewController
//            homeVC.authModel = authModel
//            self?.navigationController?.setViewControllers([homeVC], animated: true)
        }
    }


    @discardableResult func validateForm() -> Bool {
        let usernameErrorMsg = Utils.validateUsername(usernameField.text)
        let passwordErrorMsg = Utils.validatePassword(passwordField.text)
        let confirmPasswordErrorMsg = registerService.validatePasswordConfirmation(passwordConfermation: confirmPasswordField.text, password: passwordField.text)
        usernameErrorLabel.text = usernameErrorMsg
        passwordErrorLabel.text = passwordErrorMsg
        confirmPasswordErrorLabel.text = confirmPasswordErrorMsg
        return passwordErrorMsg.isEmpty && passwordErrorMsg.isEmpty && confirmPasswordErrorMsg.isEmpty
    }
    
    
    func showSubmitButton() {
        let allFieldsAreNotEmpty = !(usernameField.text?.isEmpty ?? true) && !(passwordField.text?.isEmpty ?? true) && !(confirmPasswordField.text?.isEmpty ?? true)
        if allFieldsAreNotEmpty && !submitButton.isEnabled {
            submitButton.isHidden = false
            submitButton.isEnabled = true
        }
        else if submitButton.isEnabled && !allFieldsAreNotEmpty {
            submitButton.isHidden = true
            submitButton.isEnabled = false
        }
    }
}


//MARK: - TextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        !isLoading
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            submitForm()
        }
        return true
    }
}
