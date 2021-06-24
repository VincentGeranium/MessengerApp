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
        
    }
    
}
