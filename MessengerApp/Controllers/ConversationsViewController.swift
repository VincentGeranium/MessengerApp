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
    
    private var loginObserver: NSObjectProtocol?
    
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
        
        // If notification fired this block will get excuted
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] noti in
            guard let strongSelf = self else {
                return
            }
            print("🎯NotificationCenter 'didLogInNotification' is working🎯")
            strongSelf.startListeningForConversation()
            
        })
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
        
        if let observer = loginObserver {
            // get rid of this observer because user already signd in now
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("🎯starting conversation fetch...🎯")
        
        // transform the 'email' to 'safe email' -> the reason of can't use '., $, ect'
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("What is the safe email from ‼️startListeningForConversation‼️ : \(safeEmail)")
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
                print("‼️failed to get convos, the reason is‼️ : \(error)")
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
    private func createNewConversation(result: SearchReslut) {
        
        let name = result.name
        let email = result.email
        
        
        
        // essentially push the chat view controller
        
        // this gonna be push view controller
        /*
         what i wanna do in here
         is not actually create a database entry when the user taps this to create a new converstation.
         
         Reason is when start converstaion I don't wanna keep it in my db storage unless at minimum one message has been sent
         So, adis is good practices save money on db cost and be an empty converstaion isn't per se useful.
         
         */
        
        /*
         Description:
         Why did I pass a value which is 'nil' at the 'ChaViewController' initializer param that 'id'?
         -> Because this function is for create new convo so,there was no ID yet.
         */
        let vc = ChatViewController(with: email, id: nil)
        // passing in the new user name
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
}


// MARK:- Extension UITableViewDelegate, UITableViewDataSource
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
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversation[indexPath.row]
        
        // looking up UI 'chat bubble'
        // so, when user tapped someone of these cell, push that chat screen on the stack
        // implement 'didSelectRowAt' function
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let newConversatiaonVC = NewConversationViewController()
//        newConversatiaonVC.completion = { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//            
//            guard let email = result["email"] else {
//                return
//            }
//        }
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        // push this vc on to the stack animation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
         Why did substitute value 120 to height ?
         -> The reason of substitute 120 point to height is recall maybe image height will points 100.
         So, give 10-point buffer on both the bottom and top of it.
         */
        return 120
    }
    
    /*
     Discussion: About this methods.
     
     When I deleting conversation It’s a two directional system in DB.
     So, if me and someone having a conversation in my app, when I delete it that doesn’t necessarily mean it should disappearear from app.
     That’s the reason that I set up my DB which is conversation root.
     But DB not only have a root conversation that hold all message but for each user to have conversation collection.
     So if user delete a conversation I can delete the reference  in root conversation collection.
     And it will remove it from their list but not necessarily the other user list.
     */
    
    /*
     Discussion: about 'tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle' method
     
     This method is returned editing style for the give it indexPath.
     And 'UITableViewCell.EditingStyle' this object back.
     */
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // memory serve three things which 'delete', 'insert' and 'none'.
        // c.f : especially 'none' is use when customizing.
        return .delete
    }
    
    /*
     Discussion: When 'tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)' this method is get call??
     
     When user swiped the row away this method will get call
     */
    
    // c.f : This method parameter which is 'indexPath' that refereces which row user swiping on
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        /*
         Discussion : Basically this function action
         
         Basically this function handle that delete action.
         So this function entail two things.
         
         1. Actually getting rid of the row.
         2. Updating the backing model
         */
        
        /*
         Discussion: If did not update model what happend?
         
         If did not update model after row the app is gonna crash.
         Because there's going to be a mismatch of the model array that is driving the tableview will have one additional entry where as my row will have one less.
         So there will be a collision there and it will crash.
         */
        
        if editingStyle == .delete {
            // get convo id from conversation collection that postion is indexPath.row
            // c.f : this code is simply grap id by 'String' type
            let conversationId = conversation[indexPath.row].id
            
            // begin delete
            
            // first allow the tableView to start updating
            tableView.beginUpdates()
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { [weak self] success in
                // the reason I can use row directly is because in this tableview is only one section
                self?.conversation.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            // end update
            tableView.endUpdates()
        }
    }
}
