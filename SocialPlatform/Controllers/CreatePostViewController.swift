//
//  CreatePostViewController.swift
//  SocialPlatform
//
//  Created by Ammar on 1/29/21.
//

import UIKit

class CreatePostViewController: UIViewController {


    //MARK: - IBOutlets and Variables
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var homeService = HomeService()
    private var addButtonIsEnabled = false
    
    var token: String!


    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextView.text = ""
        titleTextField.becomeFirstResponder()
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        setAddButtonAsDisabled()
        
        homeService.delegate = self
    }


    //MARK: - IBActions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        guard let titleText = titleTextField.text,
              let contentText = contentTextView.text else { return }
        if titleText.isEmpty || contentText.isEmpty { return }
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
        
        sender.isHidden = true
        loadingIndicator.startAnimating()
        homeService.createPost(token: token, title: titleText, content: contentText)
    }
    
    
    @IBAction func titleTextFieldChanged(_ sender: Any) {
        manageAddButtonState()
    }
    
    
    //MARK: - Custom Methods
    func setAddButtonAsDisabled() {
        addButtonIsEnabled = false
        addButton.backgroundColor = .clear
        addButton.setTitleColor(UIColor.gray, for: .normal)
    }
    
    func setAddButtonAsEnabled() {
        addButtonIsEnabled = true
        addButton.backgroundColor = .systemIndigo
        addButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func manageAddButtonState() {
        let titleTextFieldIsEmpty = titleTextField.text?.isEmpty ?? true
        let contentTextViewIsEmpty = contentTextView.text.isEmpty
        if !titleTextFieldIsEmpty && !contentTextViewIsEmpty {
            setAddButtonAsEnabled()
        }
        else {
            setAddButtonAsDisabled()
        }
    }
}


//MARK: - Text View Delegate
extension CreatePostViewController: UITextViewDelegate {
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        manageAddButtonState()
    }
}


//MARK: - Title Text Field Delegate
extension CreatePostViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty ?? true) {
            contentTextView.becomeFirstResponder()
            return true
        }
        return false
    }
}


//MARK: - Home Service Delegate
extension CreatePostViewController: HomeServiceDelegate {
    
    func didCreateNew(post: PostModel?) {
        if post != nil {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            loadingIndicator.stopAnimating()
            addButton.isHidden = false
        }
    }
}
