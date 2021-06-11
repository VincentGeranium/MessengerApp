//
//  ViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit

/// Checked the User sign in, based UserDefult and if user have sign in show conversation screen or not show login screen
class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // setting UserDefault
        // UserDefault is save in the disk
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged-in")
        
        if !isLoggedIn {
            // show login screen
            let vc = LoginViewController()
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: false, completion: nil)
        }
    }


}

