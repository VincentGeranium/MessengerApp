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
    
    /* this closure will be invoked with the collection of data sending back.*/
    /// c.f :  it's gonna be a closure that takes dictionary which String type key and value, not a arrry and it's return void and this whole things wrap prarenthesis for make optional
    public var completion: (([String: String]) -> (Void))?
    
    private let spinner: JGProgressHUD = JGProgressHUD(style: .dark)
    
    
    /// This is essentially gonna be the same thing that I have in the firebase remote
    /// So, it's going to be an array of  dictionary with a String key and String value.
    /// This property 's default value is empty.
    private var users = [[String: String]]()
    
    /// results is similar array and call it results and this is gonna hold the result that will be shown in the tableview
    private var results = [[String: String]]()
    
    
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
        view.addSubview(noResultLabel)
        view.addSubview(resultTableView)
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        searchBar.delegate = self
//        self.dismissVCDelegate = self
        view.backgroundColor = .white
        // put the searchBar imply into the navigatiaonBar
        // don't need to munually try to frame in it, the position.
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = cancelButton()
        
        searchBar.becomeFirstResponder()
    }
    
    // gonna set the frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // c.f : view.bounds meaning which is the entire of screen
        resultTableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4,
                                     y: (view.height-200)/2,
                                     width: view.width/2,
                                     height: 200)
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

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // text labels text be the elements in results
        // results is an array so, have to get the nth element at that position.
        // and then pull out the value useing key that i want to show in tabel view.
            // c.f : meaning of 'nth' is 'used to describe the most recent in a long series of things, when you do not know how many there are'
        
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
            // c.f : given postion => indexPaht.row
        
        // the dictionary in here at that given postion
        let targetUserData = results[indexPath.row]
        
        // what's gonna do in this block
        /*
         passes data back to the conversation list and then the converstation list automatically present or push on the chat view controller to start this new conversataion
         
         the other logicall handle
         -> if already have converstatio with someone that already converstation started, don't wanna duplicate conversation with the someone.
         -> if user tapped privious conversation tapped, have to get before converstaion otherwise make new converstatio view controller
         */
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
              
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
        
        // when user tapped enter or search button, have to get rid of keyboard
        // this will get rid of the keyboard inbounds searchBar parameter
        searchBar.resignFirstResponder()
        
        // reason of why results elements are all remove
        /*
         -> every time a new search is done, have to remove result.
         if not remove the data(elements) of results array table view will show all the data which stacked in results array.
         */
            
        results.removeAll()
        
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
            
                // c.f : term = query
            filterUsers(with: query)
        }
        else {
            // if not: fetch then filter.
            
            // MARK:-  why did i make [weak self]
            /*
             why do I typed [weak self]
             
             -> Because I need to reference itself to save result
             */
            DatabaseManager.shared.getAllUsers { [weak self] results in
                guard let strongSelf = self else {
                    return
                }
                
                switch results {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get user: \(error)")
                }
            }
        }
    }
    
    // basically pass term from the searchUser's query parameter
    func filterUsers(with term: String) {
        // update UI: either show result or show 'no result' text label
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter {
            // the $0 is enrty of Arrary that contain String Key and String Value's Dictionary.
                // c.f : [String: String] => $0
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        self.results = results
        
        updataUI()
    }
    
    // this function is based on if there are result. will shown in the table view or not shown no result lable
    func updataUI() {
        if results.isEmpty {
            // if results array is empty.
            self.noResultLabel.isHidden = false
            self.resultTableView.isHidden = true
        }
        else {
            // otherwise opposite with the if statement block code.
            self.noResultLabel.isHidden = true
            self.resultTableView.isHidden = false
            
            // refresh data for tableView
            self.resultTableView.reloadData()
        }
    }
}
