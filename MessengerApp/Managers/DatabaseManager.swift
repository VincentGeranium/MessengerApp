//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/16.
//

import Foundation
import FirebaseDatabase
import MessageKit

// "final" is notation of no subClass

final class DatabaseManager {
    // Make this class by Singleton because of easy to read and write.
    static let shared = DatabaseManager()
    
    // reference of database
    // c.f : "private" is notation of nobody pull this property to externally.
    // c.f :  what did I called as 'CS' term of this 'database'? -> instance, instance member of this class.
    private let database = Database.database().reference()
    
    // get user email
    // email is using the image file name
    static func safeEmail(emailAddress: String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    private init() { }
}

/*
 Description:
 -> Create function here that will allow me to get any data out of database in a 'generic way'
 */
extension DatabaseManager {
    /*
     Description:
     -> The 'completion' of getFor function's param is escaping handler.
     -> It the completion takes 'Result', this is return 'Any' when success case. Because I don't want constrain it to type and otherwise return 'Error'
     -> This whole things which is 'Result' return 'Void'
     
     Description:
     -> This function is a generic function where I can pass in any child path
     -> It will return if successfully able to fetch in our compltion in the results success case it overturned that data.
     -> And at the call site I can go ahead and cast it.
     */
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            // if success passing the 'value'
            completion(.success(value))
        }
        
    }
}

// MARK:- Account Management

extension DatabaseManager {
    // ‼️ important : basically the way no SEQUEL database works is JSON
    // JSON is have key and value
    
    
    // validate the email that tring to use new user dose not exsit already
    /*
     ‼️ why this function have to exist completion handler?
     -> the function actually get data out of database as synchronize.
     */
    
    public func userExist(with email: String,
                          completion: @escaping((Bool) -> Void)) {
        
        //        var safeEmail: String {
        //            let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        //            return safeEmail
        //        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        // getting data out of the database, this is important things than other pieces.
        // c.f : firebase database is allow to observe the value change any enrty
        // c.f : get a value and return snapshot
        // snapshot has value property of it, it can be optional because it can be dose not exist.
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot, _ in
            // c.f : snapshot is Any so have to cast what u want
            // if pass the foundEmail guard let statement is the meaning about user email is exist.
            guard snapshot.value as? [String: Any] != nil else {
                // email dose not exist, we can create new accout
                completion(false)
                return
            }
            // if return true email dose exist otherwise false is dose not exist
            completion(true)
        }
        
    }
    
    // write func about insert data to database
    /// Inserts new user to database, this is insert query
    /// - Parameter userInfo: infomation about user for insert to database.
    public func insertUser(with userInfo: UserInfo, compltion: @escaping (Bool) -> Void) {
        
        // insert database
        // key is user email
        // this is insert query.
        // make the root entry
        database.child(userInfo.safeEmail).setValue([
            "first_name": userInfo.firstName,
            "last_name": userInfo.lastName,
            // completion for the failer
            // if error is 'nil' meaning that 'nothing went wrong'
            // after passing error statement, make childe nood name of 'users'
            // 'users' is array of users which has just 'name' which has both the first name and last name and 'email'
            // I gonna check first, if colletcion exists -> append other else (dosen't exists) -> create
            // 'newCollection' only occur for the very first user thag sign up
        ]) { [weak self] error, _ in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("failed to write to database")
                compltion(false)
                return
            }
            
            /*
             discription about inner struct the userCollection
             
             one root child pointer is 'users'
             
             users ->    [
             [
             "name":
             "safe_email":
             ],
             [
             "name":
             "safe_email":
             ],
             ]
             
             why do this?
             -> when users try to start conversation, I have to pull out all users one request.
             -> It's save the 'database cost' and it's clean to pretty as well
             */
            
            // first try to get a reference exsisting user array
            // if it doesn't exist when they create it
            // if it dose exist I gonna append to it
            // get reference from database
            // the child I care about is 'users'
            strongSelf.database.child("users").observeSingleEvent(of: DataEventType.value) { snapShot, previousKey in
                // snapShot is not the value itself
                if var userCollection = snapShot.value as? [[String: String]] {
                    // append to user dictionary
                    // does exist
                    let newElement: [String: String] = [
                        // key: value
                        "name": userInfo.firstName + " " + userInfo.lastName,
                        "email": userInfo.safeEmail
                    ]
                    
                    userCollection.append(newElement)
                    
                    strongSelf.database.child("users").setValue(userCollection) { error, dbReference in
                        guard error == nil else {
                            compltion(false)
                            return
                        }
                        print("💜 database reference result : \(dbReference)")
                        compltion(true)
                    }
                }
                else {
                    // create that array
                    // doesn't exist
                    // this is thing that I will add to firebase for that users reference
                    let newCollection: [[String: String]] = [
                        [
                            // key: value
                            "name": userInfo.firstName + " " + userInfo.lastName,
                            "email": userInfo.safeEmail
                        ]
                    ]
                    
                    strongSelf.database.child("users").setValue(newCollection) { error, dbReference in
                        guard error == nil else {
                            compltion(false)
                            return
                        }
                        print("💜 database reference result : \(dbReference)")
                        compltion(true)
                    }
                    // root completion
                    /*
                     ‼️ 
                     */
                    //                    compltion(true)
                }
            }
        }
    }
    
    /// get user data
    ///  - Parameters:
    ///  - completion: send back results with a Array of those dictionary otherwise it will hand an error back and hole tihing will return void
    ///  - Result<[[String: String]]>: [[String: String]] is same format with firebase user data format,  it's String key - String value,
    /// -  Result<Error>: It will handle an error back
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            // suffice what I need to do in here for the database manager
            
            // if pass the guard statments, simply pass the value which hand back all the user
            completion(.success(value))
        }
    }
}

// MARK:- Sending messages / conversation
extension DatabaseManager {
    
    /*
     ‼️ Notation about this extension
     
     Basically the schema that I want in the database needs to scale two ways.
     1. Observe all the conversation for a given user.
     -> So, as new conversation comes in, I want update the conversation list by real time
     
     2. Observe given conversation
     -> So, whenever a new message comes in that also update real time
     
     About schema
     The schema that I have in mind it looks something like that.
     Also updates real time.
     
     schema look like, check down below code.
     
     This schema root element is value of 'conversation_id' that 'unique id'
     (down below schema code I will give example unique id that random string.)
     
     c.f : 'content' element will content these three thing which the text, photo url, video url.
     So, the content element must variable string.
     
     "asdaskdj" => {
     "message": [
     {
     "id": String,
     "type": text, photo, video,
     "content": String,
     "date": Date(),
     "sender_email": String,
     "is_read": true/false,
     }
     ]
     }
     
     Each of these element is will be in each user
     So each user which every users will have conversation key with
     array of this minimal conversation object that below of schema code.
     
     The object has not message data with exception of the latest message.
     
     conversation => [
     [
     "conversation_id": "unique id"
     "other_user_email": "email"
     "latest_message": => {
     "date": Date(),
     "latest_message": "latest_message",
     "is_read": true/false,
     }
     ],
     ]
     */
    
    // MARK:- Create New Conversation function
    /// Create a new convo with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message_Type, completion: @escaping (Bool) -> Void) {
        // current cache has email that not the 'safe email'
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            return
        }
        
        print("‼️ createNewConversation func ‼️ senderName is : \(currentName)")
        
        // What is purpose of the 'safe email'?
        // The safe email is what the database needs because I can't have certain characters as keys
        let safeEamil = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        // What is purpose of observe 'safeEmail' that root value or current user?
        // because what I care about this convo for this user
        let ref = database.child("\(safeEamil)")
        ref.observeSingleEvent(of: .value) { [weak self] snapShot in
            /*
             c.f:
             Why did define by variable?
             Because I gonna add a new key into here.
             */
            guard var userNode = snapShot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            
            /*
             c.f :
             How can calling the 'dateFormatter' instance from the 'ChatViewController'?
             Because when I defined the 'dateFormatter', make by 'public static'(Type property)
             So, can calling from the 'ChatViewController'
             */
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            

            
            /* ‼️ c.f :
             If make instance type have 'Any', must insert type explicit and certainly.
             Because complier dosen't know about 'Any', the 'Any' can be all type like bool, Date(), String, ect....
             So, complier wanna insert explicit type.
             
             ‼️ c.f :
             Why did I definition outside of if-else state?
             Because enve if I have conversation array before
             I'm still gonna want to creat this and append it to that array
             */
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEamil,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // MARK:- Update recipient current conversation entry
            // get thire current conversation for recipient
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapShot in
                if var conversations = snapShot.value as? [[String: Any]] {
                    // append
                    // include new convo in the 'conversations'
                    conversations.append(recipient_newConversationData)
                    // insert new convo at the database
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    // Recipient user dose not have conversation, therefore go ahead and just create it
                    
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            }
            
            
            // MARK:- Update current user conversation entry
            // Once I found the user that 'userNode' will be excute which conversations code.
            // conversation should be something in user node with a key of conversations this should be return to array of dictories because if I recall per the schema that root of 'conversation', whole conversation points array and dictionary has keys and values
            /*
             ‼️ the conversations instance which is down below.
             I make instance which 'conversations' as a variable, why did I make variable? because if I do have this conversation pointer, I'm gonna append a new convo to it
             */
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // convo array exists for current user, should append
                
                // description: taking conversation data
                conversations.append(newConversationData)
                
                // description: update 'user node conversation' to point to 'conversations'
                // c.f: why did i assign conversations to userNode? because I did append new conversation.
                userNode["conversations"] = conversations
                
                ref.setValue(userNode) { [weak self] error, databaseRef in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    // c.f: completion parameter of this function dose take root function(ref.setValue) parameter the completion
                    self?.finishCreateConversation(name: currentName,
                                                   conversationID: conversationID,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                    print("database Ref result in 'if' block from root function's that the 'createNewConversation' : \(databaseRef)")
                    
                }
            }
            else {
                // convo array dose not exist, create new convo.
                
                /*
                 Description:
                 Basically in userNode create this new conversation piece and assign it to array
                 */
                userNode["conversations"] = [
                    newConversationData
                ]
                
                // c.f: the 'ref' is reference to the current users node
                // Description: insert in database
                ref.setValue(userNode) { [weak self] error, databaseRef in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    // c.f: completion parameter of this function dose take root function(ref.setValue) parameter the completion
                    self?.finishCreateConversation(name: currentName,
                                                   conversationID: conversationID,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                    
                    print("database Ref result in 'else' block from root function's that the 'createNewConversation' : \(databaseRef)")
                }
            }
        }
    }
    
    /*
     Description:
     The reason of I want to do it in here is because I can call this function in both of these if-else cases and duplicate less code.
     And it's private because this is private to this class
     */
    private func finishCreateConversation(name: String, conversationID: String, firstMessage: Message_Type, completion: @escaping (Bool) -> Void) {
        //        {
        //            "id": String,
        //            "type": text, photo, video,
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "is_read": true/false,
        //        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        // ‼️ c.f: senderEmail data is pull out from UserDefault
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        // ‼️ c.f: Create message instance to match the schema that I have defined.
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKidString,
            "content": message,
            "date": dateString,
            "sender_email": senderEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "message": [
                collectionMessage
            ]
        ]
        
        print("‼️adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, databaseRef in
            guard error == nil else {
                completion(false)
                return
            }
            print("database Ref result in trailing closure block from 'finishCreateConversation' function : \(databaseRef)")
            completion(true)
        }
        
    }
    
    /*
     Why this function parameter which is completion that Reasult have 'Converstation'?
     -> The reason of Reasult have 'Conversation' is when this completion 'Reasult' is get 'success' case bsck, wanna return the an array of 'Conversation' Models
     */
    /// Fetchs and returns all convos for the user with passed in email
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        /*
         Description:
         About oberve
         -> The reason of added oberver method which is observe(_ eventType, with:)
         -> Observe the value continuously the 'value'
         -> And every time that the 'value' of this changes(a.k.a new converstion is created)
         will get this completion handler call
         */
        
        // Attach the listener to firebase database
        database.child("\(email)/conversations").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                // before compactMap this 'dictionary', I want to validate that all the keys and present
                // So,create this guard let statement
                guard let conversationId = dictionary["id"] as? String,
                      let senderName = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let sentDate = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool
                else {
                    print("‼️Failed to down casting‼️")
                    return nil
                }
                
                // create return the model and latest message object
                let latestMessageObject = LatestMessage(date: sentDate,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: senderName,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
                
            }
            
            completion(.success(conversations))
            
        }
    }
    
    /// Get all message for a give convo
    public func getAllMessagesForConvo(with id: String, completion: @escaping (Result<[Message_Type], Error>) -> Void) {
        database.child("\(id)/message").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            // This structure's root node is 'message' that in realtime database
            // This parent's node type is Array and each Array have onw number.
            /*
             content:
             date:
             id:
             is_read:
             receiver_name:
             sender_email:
             type:
             */
            
            // Computed property
            // Using Compact map for spit out message
            let messages: [Message_Type] = value.compactMap { dictionary in
                guard let content = dictionary["content"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let messageID = dictionary["id"] as? String,
                      let is_read = dictionary["is_read"] as? Bool,
                      let receiver_name = dictionary["receiver_name"] as? String,
                      let sender_email = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    // if dosen't have all these that from 'content' value to 'type' value, return nil
                    return nil
                }
                
                var kind: MessageKind?
                
                // Vaildate of type.
                if type == "photo" {
                    // photo
                    guard let imageURL = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: imageURL,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    
                    kind = .photo(media)
                }
                else if type == "video" {
                    // photo
                    guard let videoURL = URL(string: content),
                          let placeHolder = UIImage(named:"video_placeholder") else {
                        return nil
                    }
                    
                    let media = Media(url: videoURL,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    
                    kind = .video(media)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender_Type(senderId: sender_email,
                                         displayName: receiver_name,
                                         photoURL: "")
                
                /*
                 Description:
                 -> If dose have all the things that from 'content' value to 'type' value.
                 Want to basically instantiate a message object which is a strut that the 'Message_Type'
                 */
                return Message_Type(sender: sender,
                                    messageId: messageID,
                                    sentDate: date,
                                    kind: finalKind)
            }
            completion(.success(messages))
        }
        
    }
    
    // MARK:- Send Message Function.
    /// Send a message with target convo and message
    public func sendMessage(to conversationID: String, otherUserEmail: String, name: String, newMessage: Message_Type, completion: @escaping (Bool) -> Void) {
        // can handle all the stuff in here in the database manager rather than doing all of that business logic in the view contorller
        
        /*
         Description:
         -> Create three things in this function.
         1, Add new message to messages.
         2, Update sender latest message.
         3, Update recipient latest message.
         
         -> To be clear the latest message both the 'sender' and 'recipient' are specific to this conversation key
         */
        
        // get current user email
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        // Grap of 'message' data from 'conversationID' which is in the realtime firebase, root query that create when user start conversation at first time
        // fetch the conversation message
        database.child("\(conversationID)/message").observeSingleEvent(of: .value) { [weak self] snapShot in
            
            guard let strongSelf = self else {
                return
            }
            
            /*
             c.f:
             -> why 'currentMessaage' type is '[[String: Any]]'
             Because I downcasting by '[[String: Any]]'
             The code write like this 'as? [[String: Any]]'
             Also snapshot is pointing the value of "conversationID/message"
             */
            guard var currentMessaage = snapShot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            print("‼️ sendMessage func ‼️ currentMessaage is : \(currentMessaage)")
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                // if photo based message should get a media item here
                // mediaItem to do assign the URL which is the message.
                /*
                 Discussion
                 Assign it to which will basically allow to reference the photos uploads postion that for render
                 */
                if let targetMessageURL = mediaItem.url?.absoluteString {
                    message = targetMessageURL
                }
                break
            case .video(let mediaItem):
                if let targetMessageURL = mediaItem.url?.absoluteString {
                    message = targetMessageURL
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            // ‼️ c.f: senderEmail data is pull out from UserDefault
            guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            print("‼️ sendMessage func ‼️ senderEmail is : \(senderEmail)")
            
            let senderSafeEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
            
            // ‼️ c.f: Create message instance to match the schema that I have defined.
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKidString,
                "content": message,
                "date": dateString,
                "sender_email": senderSafeEmail,
                "is_read": false,
                "receiver_name": name
            ]

            currentMessaage.append(newMessageEntry)
            
            print("‼️ sendMessage func ‼️ newMessageEntry is : \(newMessageEntry)")
            
            // insert messages that the collection which is 'currentMessage' that append the 'newMessageEntry'.
            // This is insertion.
            // MARK: - Insert current Message
            // below '/conversationID/message'(realtime db path).
            // update message at database
            strongSelf.database.child("\(conversationID)/message").setValue(currentMessaage) { error, dbRef in
                guard error == nil else {
                    print("Failed to set value : \(error)")
                    completion(false)
                    return
                }
                
                /*
                 two updates for the latest messages.
                 -> 1, get the conversation node for each user
                 */
                // get current users conversation node
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                    guard var currentUserConversation = snapShot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    /*
                     two updates for the latest messages.
                     -> 2. Find in the conversation the entry where the conversationID and validate a way of compare between conversationID and current conversationID.
                     And Update latest message
                     */
                    
                    let updateLatestMessage: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var postion = 0
                    
                    for conversationDictionary in currentUserConversation {
                        /*
                         ‼️ Description: About 'currentId' and 'conversationID'
                         -> currentId and conversaitonID is for validate message.
                         */
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversationID {
                            // Update laatest message for update UI which is conversation view
                            targetConversation = conversationDictionary
                            break
                        }
                        postion += 1
                    }
                    targetConversation?["latest_message"] = updateLatestMessage
                    
                    guard let unwrapTargetConvo = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversation[postion] = unwrapTargetConvo
                    
                    // update
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversation) { error, dbRef in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        // This 'print state' is Database Reference of update latest messages for sender user(current user)
                        print("‼️Database Reference of update latest messages for sender user(current user)- \(dbRef)")
                        
                        // MARK:- Update latest message for recipient user
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                            guard var otherUserConversation = snapShot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            /*
                             two updates for the latest messages.
                             -> 2. Find in the conversation the entry where the conversationID and validate a way of compare between conversationID and current conversationID.
                             And Update latest message
                             */
                            
                            let updateLatestMessage: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var targetConversation: [String: Any]?
                            
                            var postion = 0
                            
                            for conversationDictionary in otherUserConversation {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversationID {
                                    // Update laatest message for update UI which is conversation view
                                    targetConversation = conversationDictionary
                                    break
                                }
                                postion += 1
                            }
                            targetConversation?["latest_message"] = updateLatestMessage
                            
                            guard let unwrapTargetConvo = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversation[postion] = unwrapTargetConvo
                            
                            // update
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversation) { error, dbRef in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                // This print state is Database Reference of update latest messages for recipient user
                                print("‼️Database Reference of update latest messages for recipient user - \(dbRef)")
                                completion(true)
                            }
                        }
                    }
                }
                
                print("Database reference in the func 'sendMessage': \(dbRef)")
            }
        }
    }
    // c.f: This function for allow to delete convertaion
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        // get current user email address
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Error : Failed get current user Email")
            return completion(false)
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        // the 'conversationId' which is parameter that this function.
        print("Deleting conversation with id: \(conversationId)")
        
        /*
         Workflow
         -  Get all conversation for current user.
         -  Delete conversation in collection with target id.
         -  Reset those conversations for the user in datebase.
         */
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapShot in
            // If snapShot's valus is Array that contain which is dictionary that 'String: Any' type, code will excute
            if var conversations = snapShot.value as? [[String: Any]] {
                // positionToRemove is index that for delete element in the array
                var positionToRemove = 0
                
                // iterate over
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       // the conversationId which is parameter this func passing in
                       id == conversationId {
                        print("Found conversation to delete")
                        // If this block excute, It will meaning that found the position which is I want to use to delete
                        // If found the position simple 'break'
                        break
                    }
                    // not found position that I want to use to delete
                    positionToRemove += 1
                }
                // conversation collection remove conversation that index 'positionToRemove' pointing
                conversations.remove(at: positionToRemove)
                
                // Update the 'ref' with this new value
                ref.setValue(conversations) { error, databaseRef in
                    // validate error
                    guard error == nil else {
                        // error occur
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    // error doesn't occur
                    print("Success to delete conversation")
                    completion(true)
                }
            }
        }
    }
    
}
