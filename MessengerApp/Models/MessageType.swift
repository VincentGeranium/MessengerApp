//
//  Message.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/24.
//

import Foundation
import MessageKit

struct Message_Type: MessageType {
    public var sender: SenderType
    // useage the duplicate
    public var messageId: String
    
    public var sentDate: Date
    
    public var kind: MessageKind
}

extension MessageKind {
    var messageKidString: String {
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return  "emoji"
        case .audio(_):
            return  "audio"
        case .contact(_):
            return  "contact"
        case .linkPreview(_):
            return  "link_preview"
        case .custom(_):
            return  "custom"
        }
    }
}
