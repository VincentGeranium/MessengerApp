//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD

/// For create account
class RegisterViewController: UIViewController {
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
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "person.circle")
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
        presentPhotoActionSheets()
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
        
        // make image view look like circle round
        imageView.layer.cornerRadius = imageView.width/2
        
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
        
        // spinner show
        // the 'view' is the 'viewController' own view
        spinner.show(in: view)
        
        // implement code below about log in used with firebase
        
        // trying to validate of email -> user exist or not
        DatabaseManager.shared.userExist(with: email) { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // user already exist
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
                return
            }
            
            // try to create account
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                // About Error and authResult
                guard authResult != nil, error == nil else {
                    print("Error occur: Creating User")
                    return
                }
                
                // this will be database entry -> (firstName, lastName and email)
                let userInfo = UserInfo(firstName: firstName,
                                        lastName: lastName,
                                        emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: userInfo) { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        // create file name
                        let fileName = userInfo.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data,
                                                                   fileName: fileName) { result in
                            switch result {
                            case .success(let downloadURL):
                                // save the disk -> (cache)
                                UserDefaults.standard.set(downloadURL,
                                                          forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print("Storage Manager Error: \(error)")
                            }
                        }
                    }
                }
                
                
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /*
     c.f :
     
     this function message parameter have default value that is "Please enter all information to create a new account"
     and can be passing message our own.
    */
    private func alertUserLoginError(message: String = "Please enter all information to create a new account") {
        let alert = UIAlertController(
            title: "Woops",
            message: message,
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
// c.f : UIImagePickerControllerDelegate는 UINavigationControllerDelegate가 없으면 동작하지 않는다.
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // this  delegate is get the result user taking a picture or selecting a picture
    
    /// This function is own function, about  action sheets.
    /// When user tapped the profile imageview, this function will call
    func presentPhotoActionSheets() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "How would you like to select a picture?",
            preferredStyle: .actionSheet
        )
        // three button of action sheet.
        // 1. cancel
        // 2. take photo
        // 3. select photo
        
        
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                // the parameter of handler is comes to action it self.
                handler: { [weak self] _ in
                    self?.presentCamera()
                    
                }
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "Chose Photo",
                style: .default,
                // the parameter of handler is comes to action it self.
                handler: { [weak self] _ in
                    self?.presentPhotoPicker()
                }
            )
        )

        present(actionSheet, animated: true, completion: nil)
    }
    
    /// this functions for call two actionSheet about "Take Photo" and "Chose Photo"
    // why am i make functions for the these actionSheets?
        // reason of for moduler
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        // for crop out picture
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        // for crop out picture
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    // reseult capture from here, "imagePickerController" and "imagePickerControllerDidCancel"
    /// This function call  when user taking photo or selecting a photo.
    ///   - info: Actually can grap the image inside of this Dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        // for figure out the key of grap image
        print(info)
        
        // get image from the info and get into user profile imageView
        // c.f : the "editImage" is user make crop or somthing to image and "originalImage" is the notting changed image.
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
    }
    
    /// This function call did cancel when user taking photo or selecting a photo.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
