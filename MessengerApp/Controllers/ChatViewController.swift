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
    public let otherUserEmail: String
    
    private let conversationID: String?
    
    // This property signify that if this conversation is a new conversation?
    public var isNewConversation = false
    
    private var messages: [Message_Type] = []
    
    // computed property
    private var selfSender: Sender_Type? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender_Type(senderId: email,
                           displayName: "Me",
                           photoURL: "")
    }
    
    // make constructor for otherUserEmail Property
    // this is custom costructor, so doesn't have override from superClass
    /*
     Description :
     Why did i create 'id' parameter type by 'Optional' which is in initializer constructor?
     -> The reason is when creating new conversation there is no identifier yet.
     -> But when user click on or tap on a conversation that's in list, It has an ID and that identifier is basically how going to observe in the database as to what things are changing
     -> So, assign that 'conversationID' property to 'id' parameter of initializer constructor.
     */
    init(with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
        //c.f: -> if dosen't have a conversataionID there's no reason to listen for database update.
        if let conversationId = conversationID {
            /*
             Description:
             
             -> 'shouldScrolleToBottom' Parameter is for UI which is the bug that message is hidden due to navigationBar.
             So, at first load time, 'shouldScrolleToBottom' value have to 'true' because user is just tap the conversation
             And want to see first message which hidden by navigationBar.
             Also that is mean's to user first tap the conversation.
             
             -> The 'shouldScrolleToBottom' is initialized value by 'true'
             So, It should scroll itself to the bottom.
             */
            listenForMessage(id: conversationId, shouldScrolleToBottom: true)
        }
        
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
    
    private func listenForMessage(id: String, shouldScrolleToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConvo(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
            // message collection is not empty when doing this
                guard !messages.isEmpty else {
                    // if dosen't have any messages no need to continue
                    return
                }
                
                // the message array has been updated to the new instance that it return
                self?.messages = messages
                /*
                 Description: About 'reloadDataAndKeepOffset'
                 -> If the user has scroll to the top and they'er reading older messages
                 And a new messages comes in.
                 If new messages comes in users don't want it to scroll down that for reading new message.
                 That is pretty bad exprience to user.
                 
                 c.f : About Main theread
                 UI operation, want to all of those to occur on the main queue
                 So, did I wrap it in a 'DispatchQueue.main.async'
                */
                DispatchQueue.main.async {
                    /*
                     Description:
                     -> Must not scroll to bottom when user reading older messages
                     */
                    
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrolleToBottom {
                        // .scrollToLastItem() will scroll it to bottom
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                
            case .failure(let error):
                print("failed to get messages, the reason is : \(error)")
            }
        }
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
            /*
             Description:
             When create new convo, title of the screen will be the other users name
             */
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { result in
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
        
        // c.f: currentUserEmail should be 'String' type. So do typecasting use 'as?'
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            // here make this return nil so basically if the current user email is not cast, just return gonna return nil
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("create message id: \(newIdentifier)")
        return newIdentifier
    }
}


/*
 Description:
 -> The way that this determines how to layout to the messages in terms of right or left is the current user here
 */
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // this function is return current user
    func currentSender() -> SenderType {
        // the curren sender, i did create by 'selfSender'
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
            
        // return dummy sender
//        return Sender_Type(senderId: "", displayName: "123", photoURL: "")
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
