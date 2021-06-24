//
//  Message.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/24.
//

import Foundation
import MessageKit

struct Message_Type: MessageType {
    var sender: SenderType
    // useage the duplicate
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
}
