//
//  TabBarViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/18.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        
        setupViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupViewController() {
        let conversation = ConversationsViewController()
        let profile = ProfileViewController()
        
        conversation.title = "Chats"
        profile.title = "Profile"
        
        let nav1 = UINavigationController(rootViewController: conversation)
        let nav2 = UINavigationController(rootViewController: profile)
        
        // setup large title mode
        nav1.navigationBar.prefersLargeTitles = true
        nav1.navigationItem.largeTitleDisplayMode = .always
        
        nav2.navigationBar.prefersLargeTitles = true
        nav2.navigationItem.largeTitleDisplayMode = .always
        
        // setup tabBarItem
        nav1.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message.fill"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 2)
        
        
        
        setViewControllers([nav1, nav2], animated: false)
    }

}
