//
//  ViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

/// Checked the User sign in, based UserDefult and if user have sign in show conversation screen or not show login screen,
/// Initialization ViewController, RootViewController.
class ConversationsViewController: UIViewController {
    
    private let spinner: JGProgressHUD = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        /*
         reason of hidden tableview for default
         will first fetched conversataion the current log in user
         if dosen't exsist converstaion, don't need to table just being empty.
         so, make label center of screen scene "no conversation"
         if have converstation show tableview.
         */
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noConversationLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "No Conversation !!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        // hidden is default -> because don't wanna showing this while loaded converstion.
        label.isHidden = true
        return label
    }()
    
    private let composeViewModel = ComposeButtonViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = composeViewModel.composeButton(vc: self,
                                                                           action: #selector(didTapComposeButton))
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setupTableView()
        fetchConverstation()
        //        vc.delegate = self
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setup frame to the tableview after add as subview
        // make tableview frame entire view
        tableView.frame = view.bounds
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
    
    private func fetchConverstation() {
        // default value (hidden) is false
        tableView.isHidden = false
    }
    
    @objc private func didTapComposeButton() {
        // for create new converstation viewcontroller
        // simply present vc
        /* this vc is root vc of navigation because when user tapped compose button, why reason of make new converstion so make new navigation vc and root vc is new converstion vc
         */
        let vc = NewConversationViewController()
        let naviVC = UINavigationController(rootViewController: vc)
        present(naviVC, animated: true, completion: nil)
    }
}



extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // looking up UI 'chat bubble'
        // so, when user tapped someone of these cell, push that chat screen on the stack
        // implement 'didSelectRowAt' function
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "Eun Chae Lee"
        vc.navigationItem.largeTitleDisplayMode = .never
        // push this vc on to the stack animation
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
