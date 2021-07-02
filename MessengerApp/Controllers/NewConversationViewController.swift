//
//  NewConversationViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import JGProgressHUD

protocol NewConversationViewControllerDelegate {
    func composeButton() -> UIBarButtonItem
}

class NewConversationViewController: UIViewController {
//    var dismissVCDelegate: DissmissBarButtonDelegate?
    
    private let spinner: JGProgressHUD = JGProgressHUD(style: .dark)
    
    
    /// This is essentially gonna be the same thing that I have in the firebase remote
    /// So, it's going to be an array of  dictionary with a String key and String value.
    /// This property 's default value is empty.
    private var users = [[String: String]]()
    
    
    /// Check the users array, If the users array is empty which will signify the fetch has completed
    /// The edge case of that is if this app only has one user this is gonna be  empty because will gonna filter out the current searching user. So, always want to check.
    /// In another way if the way if the fetch has been performed.
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let resultTableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noResultLabel: UILabel = {
        let label: UILabel = UILabel()
        label.isHidden = true
        label.text = "No Result."
        label.textAlignment = .center
        label.textColor = .green
        label.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    var delegate: NewConversationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
//        self.dismissVCDelegate = self
        view.backgroundColor = .systemGray
        // put the searchBar imply into the navigatiaonBar
        // don't need to munually try to frame in it, the position.
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = cancelButton()
        searchBar.becomeFirstResponder()
    }
    
    private func cancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Cancel",
                               style: .done,
                               target: self,
                               action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // grap the text from search bar
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            /*
             '!text.replacingOccurrences(of: " ", with: "").isEmpty' descripte.
             if the user just presses a space the spacebar and hit's the enter there's no alphanumeric characters
             in there's couple ways can write a regex(regular expression) to make validation is correct
             'this is the simplest form', this is precaution.
             */
            
            return
        }
        
        // when user tapped return key or enter the 'spinner' will be showing
            // ‼️ this 'view' is view cotroller's view.
        spinner.show(in: view)
        
        // it's gonna search the user and update tableview
        self.searchUser(query: text)
    }
    
    // this function is take query and it's not gonna return
    func searchUser(query: String) {
        /*
         How to searching user
         The simple way is use query firebase for all the users and then can filter out the user is based on the name
         But that is not efficient
         ‼️ 'Because the user searches, gonna have to read from firebase again and a bit expensive(overhead)
         therefore will be get lots of loading time and latency
         
         So, make Array which gonna do hold user object.
         It's gonna hold rather then collection for these users the put in to firebase.
         But first time, will pull it from firebase ant the second time it will be there.
         So, will not have to read user data from firebase again, just searh data at local.
         */
        
        
        // check if array has firebase result.
        if hasFetched {
            // if it dose: filter.
            // -> use fetch function from my database manager
            
            // have the users I can essentially take the user's initial search term and filter out the user that I wanna show in the table view based on what they typed in
        }
        else {
            // if not: fetch then filter.
            
            // MARK:-  why did i make [weak self]
            /*
             why do I typed [weak self]
             
             -> Because I need to reference itself to save result
             */
            DatabaseManager.shared.getAllUsers { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let userCollection):
                    self?.users = userCollection
                case .failure(let error):
                    print("Failed to get user: \(error)")
                }
                
            }
        }
        
        // update UI: either show result or show 'no result' text label
    }
    
}
