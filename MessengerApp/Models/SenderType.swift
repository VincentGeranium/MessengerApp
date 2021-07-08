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
    public var senderId: String
    public var displayName: String
    // extend Sender_Type
    public var photoURL: String
}
