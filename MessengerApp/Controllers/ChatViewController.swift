//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
    
    // This property signify that who conversation with?
    public var otherUserEmail: String
    
    // This property signify that if this conversation is a new conversation?
    public var isNewConversation = false
    
    private var messages: [Message_Type] = []
    
    // computed property
    private var selfSender: Sender_Type? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender_Type(senderId: email,
                           displayName: "EunChae Lee",
                           photoURL: "")
        }
    
    // make constructor for otherUserEmail Property
    // this is custom costructor, so doesn't have override from superClass
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink

        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Why did i written this code in the viewDidAppear?
        // -> because I wanna present the keyboard once the views actually appeared and not the loaded state
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        print("Sending text: \(text)")
        
        // send message
        if isNewConversation {
            // Create convo in database
            let message = Message_Type(sender: selfSender,
                                       messageId: messageId,
                                       sentDate: Date(),
                                       kind: .text(text))
            // pass the message to this DatabaseManager call
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { result in
                if result == true {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            }
            
        } else {
            // Append to existing convo data
        }
    }
    
    private func createMessageId() -> String? {
        
        // date, otherUserEmail, senderEmail, randomInt
            // these three components should be sufficient to give us a random enough string.
            // the worst case I can also do random Int
        
        /*
         c.f
         'dateStrin'g is equals 'self' with a capital 's'
         -> because it's static
         */
        let dateString = Self.dateFormatter.string(from: Date())
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            // here make this return nil so basically if the current user email is not cast, just return gonna return nil
            return nil
        }
        
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("create message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // this function is return current user
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
            
        // return dummy sender
        return Sender_Type(senderId: "", displayName: "123", photoURL: "")
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
