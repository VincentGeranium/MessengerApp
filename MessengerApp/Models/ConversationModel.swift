//
//  ConversationModel.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/07/11.
//

import Foundation
import UIKit

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
    
}
