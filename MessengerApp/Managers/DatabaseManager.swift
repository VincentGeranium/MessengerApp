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
