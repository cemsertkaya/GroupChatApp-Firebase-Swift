//
//  Message.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 9.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import Foundation
import MessageKit
class Message
{
    
    public struct MessageIn: MessageType
    {
        public var sender: SenderType
        public var messageId: String
        public var sentDate: Date
        public var kind: MessageKind
    }
    public var messages  :  [Chatroom.MessageIn]
    init(){self.messages = [Chatroom.MessageIn]()}
}

