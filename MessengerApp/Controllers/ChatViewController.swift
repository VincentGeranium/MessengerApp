//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/23.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    
    private var messages: [Message_Type] = []
    
    private let mockSender = Sender_Type(senderId: "1",
                                         displayName: "Eun Chea Lee",
                                         photoURL: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        
        messages.append(Message_Type(sender: mockSender,
                                    messageId: "1",
                                    sentDate: Date(),
                                    kind: .text("What are you doing babe :)")))
        messages.append(Message_Type(sender: mockSender,
                                    messageId: "1",
                                    sentDate: Date(),
                                    kind: .text("Babe I Love you soooooooooooo much and wanna see you :). Plz give me your love babe!!")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // this function is return current user
    func currentSender() -> SenderType {
        return mockSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        // the item at indexPath.section
        /* why use 'section'? -> Traditionally tableview use rows.
         messages is simply collection of messages.
         the messagekit framework use it section to seperate every single message.
         the reasoning is why they internal, because a message on the screen multiple picese, it might date time under the message
         
         */
        
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        // number of message
        return messages.count
    }
    
    
}
