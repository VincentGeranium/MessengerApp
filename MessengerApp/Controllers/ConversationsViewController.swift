//
//  ViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth

/// Checked the User sign in, based UserDefult and if user have sign in show conversation screen or not show login screen,
/// Initialization ViewController, RootViewController.
class ConversationsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // c.f : UserDefault is save in the disk
        
        validateAuth()
    }
    
    // Chacked Authentication State
    private func validateAuth() {
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // show login screen
            let vc = LoginViewController()
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: false, completion: nil)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
