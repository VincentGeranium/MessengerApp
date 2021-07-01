//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeaderView()
    }
    
    // reason of return type is optional
    /*
     -> because if I don't have user email saved.
     I don't need create header for the table to show the avatar
     */
    func createTableHeaderView() -> UIView? {
        // get email from device
        /*
         c.f : email instance value must do typeCast, convert to String type because this value using in the 'safeEmail' function
         */
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("can't get user email from device")
            return nil
        }
        
        /*
         ‼️ c.f : don't need to import FirebaseStorage
         
         because I have own my storage manager which will handle the fetch for us
         I'm going to create a function there to make sure I keep things modular
         */
        
        /*
         ‼️ c.f : workflow
         1. I give it a path, I get the URL
         2. I gonna have to use the download URL to download image itself
         */
        
        // email convert to safeEmail format
            // c.f : I can access to 'function' which name of safeEmail
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        // make instance 'fileName'
            // c.f : have to same format with storage image file name.
        let fileName = safeEmail + "_profile_picture.png"
        
        // directory structure that I want to get
        // I can use the 'path' instance to fetch the 'download URL'
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.frame.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.borderWidth = 3
        
        headerView.addSubview(imageView)
        
        // create function from StorageManager that return 'download url' for this asset in the bucket
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                // want download image itself
                    // passing the 'imageView' up above that I created.
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download URL, Error log -> \(error)")
            }
        }
        
        return headerView
    }
    
    // creat function, keep things moduler
        // passing imageView as well as url
    func downloadImage(imageView: UIImageView, url: URL) {
        // donwload image
        URLSession.shared.dataTask(with: url) { data, urlResponse, error in
            guard let data = data, error == nil else {
                return
            }
            
            // Anything UI related should occur on the main thread
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
            // c.f : '.resume' is when kick off the operation
        }.resume()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // make frame the screen, for tableview
        tableView.frame = view.bounds
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // c.f : The element about "cell.textLabel?.text" is in the "data" array
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    // when user select cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This is simply Unhighlight the cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Alert for user about make sure to log out
        let alert = UIAlertController(
            title: "",
            message: "",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
                            title: "Log out",
                            style: .destructive,
                            // Handler is gonna be the action that get fire after selected
                            handler: { [weak self] _ in
                                // ‼️ Unwrap "self" by "strongSelf"
                                guard let strongSelf = self else {
                                    return
                                }
                                
                                // Log out facebook session
                                FBSDKLoginKit.LoginManager().logOut()
                                
                                // Log out Google session
                                GIDSignIn.sharedInstance().signOut()
                                
                                // When user sign out
                                do {
                                    // Log out FirebaseAuth session.
                                    try FirebaseAuth.Auth.auth().signOut()
                                    // After sign out present log in viewcontroller
                                    
                                    let vc = LoginViewController()
                                    let nav = UINavigationController(rootViewController: vc)
                                    nav.modalPresentationStyle = .fullScreen
                                    strongSelf.present(nav, animated: true, completion: nil)
                                }
                                catch {
                                    // If sign out is failed
                                    print("Failed Log out")
                                }
                            }))
        
        alert.addAction(UIAlertAction(
                            title: "Cancel",
                            style: .cancel,
                            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
    }
    
}
