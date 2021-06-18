//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth

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
        
        // When user sign out
        do {
            try FirebaseAuth.Auth.auth().signOut()
            // After sign out present log in viewcontroller
            
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false, completion: nil)
        }
        catch {
            // If sign out is failed
            print("Failed Log out")
        }
        
    }
    
}
