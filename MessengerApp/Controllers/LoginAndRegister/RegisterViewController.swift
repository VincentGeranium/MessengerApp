//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit

/// For create account
class RegisterViewController: UIViewController {
    
    // 화면이 작은 디바이스의 경우 키보드가 올라면 많은 화면을 가리게 된다 그러므로 그것을 위해 여러가지 방법이 있지만 이 곳에서는 스크롤 뷰를 사용한다.
    // c.f : scroll view 외의 다른 경우 stack view를 활용할수도 있다
    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()
    
    // reason of return key type is ".continue"
    // when user entered email and have to written password so, make ".continue"
    private let firstNameField: UITextField = {
        let field: UITextField = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "First Name...",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        //        field.placeholder = "Email Address..."
        // Apple 의 H.I.G에서 보면 textField의 left side의 flash가 바짝 붙지 않도록 하고 있다 그래서 아래의 코드를 만들어 flash가 user에게 보이도록 한다.
        //
        field.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 5,height: 0))
        field.leftViewMode = .always
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    // reason of return key type is ".continue"
    // when user entered email and have to written password so, make ".continue"
    private let lastNameField: UITextField = {
        let field: UITextField = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Last Name...",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        //        field.placeholder = "Email Address..."
        // Apple 의 H.I.G에서 보면 textField의 left side의 flash가 바짝 붙지 않도록 하고 있다 그래서 아래의 코드를 만들어 flash가 user에게 보이도록 한다.
        //
        field.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 5,height: 0))
        field.leftViewMode = .always
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    // reason of return key type is ".continue"
    // when user entered email and have to written password so, make ".continue"
    private let emailField: UITextField = {
        let field: UITextField = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Email Address...",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        //        field.placeholder = "Email Address..."
        // Apple 의 H.I.G에서 보면 textField의 left side의 flash가 바짝 붙지 않도록 하고 있다 그래서 아래의 코드를 만들어 flash가 user에게 보이도록 한다.
        //
        field.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 5,height: 0))
        field.leftViewMode = .always
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field: UITextField = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Password...",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    private let registerButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Register"
        view.backgroundColor = .white
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister)
        )
        
        // added Target Action button
        registerButton.addTarget(
            self,
            action: #selector(registerButtonTapped),
            for: .touchUpInside
        )
        
        // added scrollView in the view
        view.addSubview(scrollView)
        
        // added elements in to the scrollView
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        // user interaction code
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        // added UITapGestureRecognizer to imageView for change user Profile Picture.
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapChangeUserProfilePic)
        )
        // touch and tap required
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        
        imageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func didTapChangeUserProfilePic() {
        print("tapped user profile image view")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // scrollView frame is entire of the screen
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(
            x: (scrollView.width-size)/2,
            y: 20,
            width: size,
            height: size
        )
        
        firstNameField.frame = CGRect(
            x: 30,
            y: imageView.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        lastNameField.frame = CGRect(
            x: 30,
            y: firstNameField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        // c.f : generally "52" height size of textfield is standard.
        emailField.frame = CGRect(
            x: 30,
            y: lastNameField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        registerButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
    }
    
    /// when user tapped login button
    @objc private func registerButtonTapped() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // vaildation textfield
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        // implement code of log in used with firebase
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(
            title: "Woops",
            message: "Please enter all information to create a new account",
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "Dissmiss",
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Tapped Register button, Push RegisterViewController on the screen.
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // when user tapped return key
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}
