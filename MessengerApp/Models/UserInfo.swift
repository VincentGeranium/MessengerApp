//
//  UserInfo.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/16.
//

import Foundation

// c.f : Omitted Password in this structure because password is have to encrypted.

struct UserInfo {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    
    // computed property for email
    // InvalidatePathValidation have to none empty string and not contain '.', '#', '$', '[' or ']'
    // so thi computed property is replacing the string for insert email in database.
    var safeEmail: String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
//        safeEmail.replacingOccurrences(of: "#", with: "-")
//        safeEmail.replacingOccurrences(of: "$", with: "-")
        
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
