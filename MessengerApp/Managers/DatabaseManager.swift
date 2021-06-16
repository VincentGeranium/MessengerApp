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
        
        var safeEmail: String {
            let safeEmail = email.replacingOccurrences(of: ".", with: "-")
            return safeEmail
        }
        
        // getting data out of the database, this is important things than other pieces.
        // c.f : firebase database is allow to observe the value change any enrty
        // c.f : get a value and return snapshot
        // snapshot has value property of it, it can be optional because it can be dose not exist.
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot, _ in
            // c.f : snapshot is Any so have to cast what u want
            // if pass the foundEmail guard let statement is the meaning about user email is exist.
            guard snapshot.value as? String != nil else {
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
    public func insertUser(with userInfo: UserInfo) {
        // insert database
        // key is user email
        // this is insert query.
        database.child(userInfo.safeEmail).setValue([
            "first_name": userInfo.firstName,
            "last_name": userInfo.lastName,
        ])
    }
}
