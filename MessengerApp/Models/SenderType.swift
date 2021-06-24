//
//  SenderType.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/24.
//

import Foundation
import MessageKit

struct Sender_Type: SenderType {
    // basic instance of SenderType protocol
    var senderId: String    
    var displayName: String
    // extend Sender_Type
    var photoURL: String
}
