//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
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
        imageView.image = UIImage(named: "logo")
        return imageView
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
    
    private let loginButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let fbLoginButton: FBLoginButton = {
        let button: FBLoginButton = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Log-in"
        view.backgroundColor = .white
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister)
        )
        
        // added Target Action button
        loginButton.addTarget(
            self,
            action: #selector(loginButtonTapped),
            for: .touchUpInside
        )
        
        // added scrollView in the view
        view.addSubview(scrollView)
        
        // added elements in to the scrollView
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
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
        
        // c.f : generally "52" height size of textfield is standard.
        emailField.frame = CGRect(
            x: 30,
            y: imageView.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        loginButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        fbLoginButton.frame = CGRect(
            x: 30,
            y: loginButton.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        
        
        
    }
    
    /// when user tapped login button
    @objc private func loginButtonTapped() {
        // dismiss keybord when user hit the button
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // vaildation textfield
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // implement code of log in used with firebase(sign in)
        // c.f: the Firebase log in framework is caching log in state.
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                print("Faild logged in with email: \(email)")
                return
            }
            
            let user = result.user
            print("Success to logged in user: \(user)")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(
            title: "Woops",
            message: "Please enter all information to log in",
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // when user tapped return key
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        // if user logged in used by facebook, get user name and email for tray credential to firebase database.
        // Graph request
        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields": "email, name"],
            tokenString: token,
            version: nil,
            httpMethod: .get
        )
        
        facebookRequest.start { requestConnection, result, error in
            // if memory serve result should be dictionary
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request.")
                return
            }
            
            // we wanna graph email, name out of that dictionary
            // facebook request result.
            print("\(result)")
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Faild to get email and name from fb result.")
                return
            }
            
            
            // Need tray this token to firebase to get a credential
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed - \(error)")
                        return
                    }
                    return
                }
                
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }

}
