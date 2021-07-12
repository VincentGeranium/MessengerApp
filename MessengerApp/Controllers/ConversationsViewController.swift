//
//  ViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import MessageKit

/// Checked the User sign in, based UserDefult and if user have sign in show conversation screen or not show login screen,
/// Initialization ViewController, RootViewController.
class ConversationsViewController: UIViewController {
    
    private let spinner: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // This instance is contain array of 'Conversation' models
    private var conversation = [Conversation]()
    
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
        tableView.register(ConversationTableViewCell.self,
                           forCellReuseIdentifier: ConversationTableViewCell.identifire)
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
        startListeningForConversation()
    }
    
    /*
     What dose this function?
     -> 1. This function is going to attach a listener to that array in firebase database
     -> 2. This function is going to every time added that new conversation
     -> 3. This function is going to update table view the reason is (1, 2)
     */
    
    private func startListeningForConversation() {
        // c.f : Added this new message to use that data manager stuff
        
        // get the user's email from UserDefault
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        // transform the 'email' to 'safe email' -> the reason of can't use '., $, ect'
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        /*
         The reason of write '[weak self]'
         -> It's gonna refer to the table view if need to refresh the data, don't wanna memory leak and making cause the memory cycle.
        */
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result in
            // if result is success -> basically get conversation back
            // if result is failure -> get error
            
            // if convo is empty, there no reason to update the 'table view'
            // if convo is not empty, subsuite the this convo model to self convo
            switch result {
            case .success(let conversation):
                guard !conversation.isEmpty else {
                    return
                }
                
                // assigned new conversation
                self?.conversation = conversation
                
                /*
                 The reason of why did create DispatchQueue.main.async method in here
                 -> After assigned new convo, I wanna call reload data on the tableview
                 the Main thread is where all the UI operations should occur
                 So, create DispatchQueue.main.async method and into it the code 'self?.tableView.reloadData()'
                 */
                DispatchQueue.main.async {
                    /*
                     The reason of why the 'self' is optional in the 'self?.tableView.reloadData()'
                     -> Because it's 'weak self'
                     */
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get convos, the reason is : \(error)")
            }
            
        }
        
        
        
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
        // accese the vc's completion closure
        vc.completion = { [weak self] result in
            print("user's info that I search and tapped : \(result)")
            self?.createNewConversation(result: result)
            
        }
        
        let naviVC = UINavigationController(rootViewController: vc)
        present(naviVC, animated: true, completion: nil)
    }
    
    // this func is getting back data from the 'result' -> this func prarmeter will be result.
    // the result type is [String: String]
    private func createNewConversation(result: [String: String]) {
        
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        
        
        // essentially push the chat view controller
        
        // this gonna be push view controller
        /*
         what i wanna do in here
         is not actually create a database entry when the user taps this to create a new converstation.
         
         Reason is when start converstaion I don't wanna keep it in my db storage unless at minimum one message has been sent
         So, adis is good practices save money on db cost and be an empty converstaion isn't per se useful.
         
         */
        let vc = ChatViewController(with: email)
        // passing in the new user name
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
}



extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // model is at the end positioned item in array
        let model = conversation[indexPath.row]
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifire,
                                                       for: indexPath) as? ConversationTableViewCell else
        {
            return UITableViewCell()
        }
        
        let id = model.id
        let name = model.name
        let otherUserEmail = model.otherUserEmail
        let latestMessage = model.latestMessage
        
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversation[indexPath.row]
        
        // looking up UI 'chat bubble'
        // so, when user tapped someone of these cell, push that chat screen on the stack
        // implement 'didSelectRowAt' function
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newConversatiaonVC = NewConversationViewController()
        newConversatiaonVC.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            guard let email = result["email"] else {
                return
            }
            
            let vc = ChatViewController(with: model.otherUserEmail)
            vc.title = model.name
            vc.navigationItem.largeTitleDisplayMode = .never
            // push this vc on to the stack animation
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
         Why did substitute value 120 to height ?
         -> The reason of substitute 120 point to height is recall maybe image height will points 100.
         So, give 10-point buffer on both the bottom and top of it.
         */
        return 120
    }
}
