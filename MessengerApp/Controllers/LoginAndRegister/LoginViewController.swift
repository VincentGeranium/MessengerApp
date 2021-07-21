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
    
    /*
     Description:
     -> 'loginButtonTapped' function is doing to vaildatio 'email' and 'password'
     */
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
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "Failed to log in", message: "Check again your email or password", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(action)
                    
                    self?.present(alertVC, animated: true, completion: nil)
                }
                print("Faild logged in with email: \(email)")
                return
            }
            
            let user = result.user
            
            // Create Safe Eamil which mean's the email is convert to fitted email that match by the rule of firebase email rule.
            let safaEmail = DatabaseManager.safeEmail(emailAddress: email)
            
            /*
             Description:
             -> the 'path' which is param of getDataFor, I pass safeEmail.
             So, the 'safeEmail' is the child at which this users data exist
             
             -> Grap data from realtime database used by 'safe eamil'
             Safe Email dose the 'path' that grap from 'realtime database'
             So, follow the 'safeEmail' query and grap data what I want which is below the 'safeEamil' root query.
             */
            // MARK:-
            DatabaseManager.shared.getDataFor(path: safaEmail) { [weak self] result in
                switch result {
                case .success(let data):
                    // The data I expect this to be a dictionary.
                    // The Dictionary is with String and value can be Any
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String
                    else {
                        return
                    }
                    
                    /*
                     Description:
                     -> First of all, grap user's 'first_name' and 'last_name' from the query in 'Realtime Database' that I create which is about 'user's info.
                     -> So, create 'safe email' property first and grap the name data used by 'safe eamil'
                     ->
                     */
                    // cache user's first name, last name
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to read data with this error: \(error)")
                }
            }
            
            // before dismiss navigationController, save the user email.
                // cache user's email to userDefault
                // if i wanna to show these data which somewhere in the device, i can cache data use by userDefault
            UserDefaults.standard.setValue(email, forKey: "email")
            
            print("💜 Success to logged in user: \(user)")
            
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
    
    // MARK:- facebook graph request, loginButton()
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        // if user logged in used by facebook, get user name and email for tray credential to firebase database.
        // Graph request
        /*
         when we request facebook, can see that getting data from them
            -> parameters: ["fields": "email, name"]
                -> particular is here the data is "email and name".
                    -> c.f : if fixing 'the parameters' can getting another data for what I want.
         */
        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields":
                            "email, first_name, last_name, picture.type(large)"],
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
            // log of data back
            /*
             This is the 'facebook graph request result'
             -> example
             
             ["email": mvp4462@naver.com, "first_name": 준, "last_name": 김, "id": 4122317491155025, "picture": {
                 data =     {
                     height = 200;
                     "is_silhouette" = 0;
                     url = "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=4122317491155025&height=200&width=200&ext=1627362242&hash=AeQmFXNg2267LjkNGLs";
                     width = 200;
                 };
             }]
             
             if grap data for '[]', which the data is 'Array'
             if grap data for '{}', which the data is 'Object'
             */
            print("❤️ -> \(result)")

            
            
            /*
             why insert code 'return' ?
             -> jsut debug perpose
                -> actually when I checking the print state about 'result', I will not register user. so, insert code the 'return' commned
             */
            //            return
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String else {
                print("Faild to get names from fb result.")
                return
            }
            
            guard let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  // data는 4개의 키 값을 가지고 있는 object.
                  // c.f : objcet는 순서가 없는 이름/값 쌍의 집합으로, 이름(키)이 문자열이다.
                  let data = picture["data"] as? NSDictionary,
                  // c.f :  let data = picture["data"] as? NSDictionary == let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("Faild to get pictureUrl from fb result.")
                return
            }

            // cache user's first name, last name and email to userDefault
            // if i wanna to show these data which somewhere in the device, i can cache data use by userDefault
            UserDefaults.standard.setValue(email, forKey: "email")
            
            // Create UserDefault to cache the user's full-name
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userExist(with: email, completion: { exists in
//                guard let firstName = firstName, let lastName = lastName else {
//                    return
//                }
                if !exists {
                    let userInfo = UserInfo(firstName: firstName,
                                            lastName: lastName,
                                            emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: userInfo) { success in
                        
                        if success {
                            // download bytes from the facebook image url
                            
                            // grap picture url from facebook
                                // -> if not able to create url object just return
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data")
                            
                            // URLSession for download bytes the image
                            URLSession.shared.dataTask(with: url) { data, urlResponse, error in
                                guard let data = data else {
                                    print("failed to get data from facebook")
                                    return
                                }
                                
                                print("got data from facebook, uploading...")
                                
                                guard let urlResponse = urlResponse else {
                                    return
                                }
                                print("URLSession dataTask func result of URLResponse : \(urlResponse)")
                                
                                guard error == nil else {
                                    print("URLSession Error : \(error)")
                                    return
                                }
                                
                                // upload data to firebase
                                let fileName = userInfo.profilePictureFileName
                                
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }.resume()
                            
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
