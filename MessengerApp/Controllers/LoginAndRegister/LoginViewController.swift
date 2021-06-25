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
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    // create instance of spinner
    private let spinner: JGProgressHUD = JGProgressHUD(style: .dark)
    
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
    
    private let gidLoginButton: GIDSignInButton = {
        let button: GIDSignInButton = GIDSignInButton()
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make notification observer for dismiss navigation controller
        // notification is Design patterns for broadcasting information and for subscribing to broadcasts.
        /*
         explain
         we need to dismiss navi when user sign in with these two kind of sign in system(facebook, google)
         but i don't need make two dismiss code. just make and use notificatio pattern
         because the function what i need is same "when user sign in navi must be dismiss"
         */
        
        // this actually return result that we can a sign to discardable resutl
        /*
         this property is when controller deinit(a.k.a dismiss)
         we gonna get rid of this observation('present)
         memory clean things up
         */
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main) { [weak self] _ in
            // passing notification inside here
            // dismiss this viewcontroller
            guard let strongSelf = self else { return }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        // do specify
        GIDSignIn.sharedInstance().presentingViewController = self
        
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
        scrollView.addSubview(gidLoginButton)
    }
    
    // MARK:- deinit
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK:- viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // scrollView frame is entire of the screen
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        // c.f : generally "52" height size of textfield is standard.
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        fbLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom+10,
                                     width: scrollView.width-60,
                                     height: 28)
        
        gidLoginButton.frame = CGRect(x: 30,
                                      y: fbLoginButton.bottom+10,
                                      width: scrollView.width-60,
                                      height: 28)
        
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
        
        // spinner show
        spinner.show(in: view)
        
        // implement code of log in used with firebase(sign in)
        // c.f: the Firebase log in framework is caching log in state.
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            // get rid of spinner
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
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
            title: "Dismiss",
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
            
            /*
            var testString = "이은채"
            var testArray: [String] = []
            */
            
            var nameComponent = userName.components(separatedBy: " ")
            
            var firstName: String?
            var lastName: String?
            
            
            if nameComponent.count >= 2 {
                firstName = nameComponent[0]
                lastName = nameComponent[1]
                print("nameComponent conunt - 1: \(nameComponent.count)")
            } else if nameComponent.count < 2 && nameComponent.count != 0 {
                // 붙어있는 성과 이름을 각각 나누는 작업.
                
                /*
                 nameComponent 내 elements가 "이은채" 와 같이 성과 이름이 붙어 있는 경우
                 Array type인 nameComponent를 popLast를 통해 String 으로 바꾼다.
                 */
                guard let fullName = nameComponent.popLast() else {
                    print("Error : nameComponent is Empty")
                    return
                }
                
                print("fullName result: \(fullName)")
                
                /*
                 String인 fullName을 for 문으로 하나씩 나누어 "이", "은", "채" 와 같이 만들어 Array type인 nameComponent에 하나씩 append 한다.
                 result -> ["이","은","채"]
                 */
                for i in fullName {
                    nameComponent.append(String(i))
                }
                
                /*
                 nameCompoent의 첫 번째 element는 한국 이름의 성으로 쓰이므로 lastName에 넣어주는 동시에 Array에서 빼준다.
                 그러면 남는 것은 이름이 된다.
                 */
                lastName = nameComponent.remove(at: 0)
                
                /*
                 nameComponent에 남은 것은 이름 -> ["은","채"] 가 된다 그러나 각가의 element로 나뉘어져 있으므로 for 문을 통해 각 element를 임시 저장
                 instance를 만들어 자기 자신을 더해줌으로 인해 합쳐진 이름이 된다("은채"). 그럼 이것을 firstName에 저장하면 된다.
                 */
                var tempStr: String = ""
                for i in 0...(nameComponent.count - 1) {
//                    tempStr = String(nameComponent[i])
                    tempStr += String(nameComponent[i])
                }
                
                print("temp result: \(tempStr)")
                print("nameComponent result: \(nameComponent)")
                
                firstName = tempStr
                
                print("first : \(firstName), last : \(lastName)")
            }
            

            
            DatabaseManager.shared.userExist(with: email, completion: { exists in
                guard let firstName = firstName, let lastName = lastName else {
                    return
                }
                if !exists {
                    let userInfo = UserInfo(firstName: firstName,
                                            lastName: lastName,
                                            emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: userInfo) { success in
                        if success {
                            // upload image
                        }
                    }
                }
            })
            
            
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
                
                print("👏Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }

}

