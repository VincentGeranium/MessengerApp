//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

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
        
        // c.f: the datebase is bring only safe email.
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender_Type(senderId: safeEmail,
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputBarButton()
    }
    
    private func setupInputBarButton() {
        let button: InputBarButtonItem = InputBarButtonItem()
        // the button figure
        /*
         c.f : Reason of figure the button cgsize that 35 which width and height.
         -> I create a constant width 36, So, give to one point buffer.
         */
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        
        // Setup button's Image.
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        
        
        // Setup InputBarButton Action
        button.onTouchUpInside { [weak self] inputBarButton in
            // This closure is Action that when user touch the button.
            self?.presentInputActionSheet()
        }
        
        // setup leftStackViewWidthConstant.
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        // setup InputBarAccesoryView property of InputBarButtoItem.
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    // MARK:- Showing Action Sheet
    private func presentInputActionSheet() {
        let alertController = UIAlertController(title: "Attach Media",
                                                message: "What would you like to attach?",
                                                preferredStyle: .actionSheet)
        /*
         Description:
         -> Instead of just show take photo or choose photo.
         Because 'Action Sheet' can also include other things like videos.
         */
        alertController.addAction(UIAlertAction(title: "Photo",
                                                style: .default,
                                                handler: { [weak self] alertAction in
                                                    self?.presentPhotoActionSheet()
                                                }))
        
        alertController.addAction(UIAlertAction(title: "Video",
                                                style: .default,
                                                handler: { alertAction in
                                                    print("")
                                                }))
        
        alertController.addAction(UIAlertAction(title: "Audio",
                                                style: .default,
                                                handler: { alertAction in
                                                    print("")
                                                }))
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentPhotoActionSheet() {
        let alertController = UIAlertController(title: "Attach Photo",
                                                message: "Where would you like to attach a photo from?",
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera",
                                                style: .default,
                                                // reason of '[weak self]', because present the 'picker'
                                                handler: { [weak self] alertAction in
                                                    // Create UIImagePickerController for pick camera or photo library that choise to use when user send image.
                                                    let picker = UIImagePickerController()
                                                    picker.sourceType = .camera
                                                    picker.delegate = self
                                                    // give to 'true', It can be force the user crop out a square image.
                                                    picker.allowsEditing = true
                                                    self?.present(picker, animated: true, completion: nil)
                                                }))
        
        alertController.addAction(UIAlertAction(title: "Photo Library",
                                                style: .default,
                                                handler: { [weak self] alertAction in
                                                    // Create UIImagePickerController for pick camera or photo library that choise to use when user send image.
                                                    let picker = UIImagePickerController()
                                                    picker.sourceType = .photoLibrary
                                                    picker.delegate = self
                                                    // give to 'true', It can be force the user crop out a square image.
                                                    picker.allowsEditing = true
                                                    self?.present(picker, animated: true, completion: nil)
                                                }))
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK:- listen for message
    private func listenForMessage(id: String, shouldScrolleToBottom: Bool) {
        /*
         Description:
         -> Every time that completion is called I want to update to this collection view of message.
         So, that the messages array has been updated to the new instance that it return
         */
        DatabaseManager.shared.getAllMessagesForConvo(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                // message collection is not empty when doing this
                guard !messages.isEmpty else {
                    // if dosen't have any messages no need to continue
                    return
                }
                
                // the message array has been updated to the new instance that it return valuse which is success case.
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

// MARK:- Extension
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        print("Sending text: \(text)")
        
        // MARK:- Message Object
        /*
         Description:
         -> Create message in here that outside of the 'if-else' because want to user both cases
         */
        let message = Message_Type(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .text(text))
        
        // MARK:- Send message
        if isNewConversation {
            // This block is what I to do for new conversation
            
            // Create convo in database
            // pass the message to this DatabaseManager call
            /*
             Description:
             When create new convo, title of the screen will be the other users name
             */
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] result in
                if result == true {
                    print("message sent")
                    // it's not longer new conversation so, false
                    self?.isNewConversation = false
                }
                else {
                    print("failed to send")
                }
            }
        }
        else {
            
            // c.f : unwraped optional string value which is'conversationID' for using sendMessage's parameter.
            // c.f : name is self.title and this is other user name
            guard let conversationID = conversationID,
                  let name = self.title else {
                return
            }
            
            // This block is what I to do to do for existing convo
            
            // MARK:- Append to existing convo data
            // Sending a text base message.
            // c.f : Should refresh user interface if the message successfully sent
            // c.f : The functiocn sendMessage's parameter that 'to' is 'String' type.
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            }
        }
    }
    
    
    
    private func createMessageId() -> String? {
        
        // date, otherUserEmail, senderEmail, randomInt
        // these three components should be sufficient to give us a random enough string.
        // the worst case I can also do random Int
        
        /*
         c.f
         'dateString' is equals 'self' with a capital 's'
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
 -> The way that this determines(결정) that down below code the extension are how to layout to the messages in terms of right or left
 */

// MARK:- Extension of MessageKit.
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
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Here is actually download and update the imageView that parameter of this function
        
        // Get the message as create my Message_Type structure.
        guard let message = message as? Message_Type else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            // Grap Image url
            guard let imageURL = media.url else {
                return
            }
            
            // assign imageURL to imageView
            imageView.sd_setImage(with: imageURL, completed: nil)
        default:
            break
        }
    }
}

// MARK:- Extension of UIImagePickerController and UINavigationController.
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // dismiss picker
        picker.dismiss(animated: true, completion: nil)
        
        // get the image out of it that user's pick
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        // Trens form UIImage to pndData.
        guard let imageData = image.pngData(),
              let messageId = createMessageId(),
              let conversationID = conversationID,
              let name = self.title,
              let selfSender = selfSender else {
            return
        }
        
        // All file name has to unique. So, using createMessageId function's
        
        /*
         Work flow
         - Upload Image
         - Send Message
         */
        
        // Create unique file name
        let fileName = "photo_message" + messageId.replacingOccurrences(of: " ", with: ".") + ".png"
        
        
        
        
        /// Upload Image
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
            // Create strong reference
            guard let strongSelf = self else {
                return
            }
            
            /*
             Discussion:
             The parameter which is 'fileName' need to unique string with a suffix of PNG
             Because I get out PNG data of it
             */
            
            // switch of the 'result'
            switch result {
            case .success(let urlString):
                // Ready to send message
                // Send the message which tranlates to update the datebase
                    // -> c.f : So, use DatabaseManager
                print("Uploaded Message Photo: \(urlString)")
                
                /*
                 Discussion:
                 MediaItem is actually a protocol that messageKit
                 */
                
                // c.f : create a URL from the 'urlString'
                // c.f : 'urlString' is download postion, download URL for in firebase where that uploaded image exist
                // c.f : Don't really care about 'size' parameter for uploading the image because this is rendering perposes
                
                // c.f : the URL(string:) is URL Object with a string constant
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "plus") else {
                    return
                }
                
                let media = Media(url: url,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)
                
                let message = Message_Type(sender: selfSender,
                                           messageId: messageId,
                                           sentDate: Date(),
                                           kind: .photo(media))
                
                // c.f : parameter value which is 'otherUserEmail' is property of class
                // c.f : name parameter is the title of this controller which is the other users name, user chatting with
                // c.f : meaning of newMessage parameter is actual message user want to send
                DatabaseManager.shared.sendMessage(to: conversationID,
                                                   otherUserEmail: strongSelf.otherUserEmail,
                                                   name: name,
                                                   newMessage: message) { result in
                    if result == true {
                        print("📸sent photo image")
                    }
                    else {
                        print("failed to send photo image")
                    }
                }
                
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        }
    }
}
 
extension ChatViewController: MessageCellDelegate {
    // Allow the user to tap the photo to go to PhotoViewerController for the user see photo bigger.
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        // pull out message
        // c.f : MessageKit think the indexPath.section to one message. -> 메시지 킷은 인덱스 패스의 하나의 섹션을 하나의 메시지로 생각한다.
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageURL)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
     
}
