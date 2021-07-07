//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/16.
//

import Foundation
import FirebaseDatabase

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
                "isRead": true/false,
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
    
    /// Create a new convo with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message_Type, completion: @escaping (Bool) -> Void) {
        // current cache has email that not the 'safe email'
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        // What is purpose of the 'safe email'?
            // The safe email is what the database needs because I can't have certain characters as keys
        let safeEamil = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        // What is purpose of observe 'safeEmail' that root value or current user?
            // because what I care about this convo for this user
        let ref = database.child("\(safeEamil)")
        ref.observeSingleEvent(of: .value) { snapShot in
            guard let userNode = snapShot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            // Once I found the user that 'userNode' will be excute which conversations code.
            // conversation should be something in user node with a key of conversations this should be return to array of dictories because if I recall per the schema that root of 'conversation', whole conversation points array and dictionary has keys and values
            /*
             ‼️ the conversations instance which is down below.
             I make as a variable instance, because if do have this conversation pointer, gonna append new convo to it
             */
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // convo array exists for current user, should append
            }
            else {
                // otherwise create new convo
            }
        }
        
    }
    
    /// Fetchs and returns all convos for the user with passed in email
    public func getAllConversation(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Get all message for a give convo
    public func getAllMessagesForConvo(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send a message with target convo and message
    public func sendMessage(to convo: String, message: Message_Type, completion: @escaping (Bool) -> Void){
        // can handle all the stuff in here in the database manager rather than doing all of that business logic in the view contorller
    }
}
