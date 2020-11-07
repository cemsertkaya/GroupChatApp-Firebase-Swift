//
//  Entry.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 19.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import Foundation

class Entry
{
    private var id : String
    private var time  : String
    private var title : String
    private var commentCount : String

    init(id : String, time : String, title : String,commentCount : String)
    {
        self.id = id;self.time = time
        self.title = title;self.commentCount = commentCount
    }
    func getId() -> String {return self.id}
    func getTime() -> String {return self.time}
    func getTitle() -> String {return self.title}
    func getCommentCount() -> String{return self.commentCount}
}


class Comment
{
    
    private var sender : String
    private var time : String
    private var senderUsername : String
    private var commentMessage : String
    private var likesArray : [String]
    private var dislikesArray : [String]
    
    init(sender: String, time : String, senderUsername: String, commentMessage:String, likesArray: [String], dislikesArray : [String])
    {
        self.sender = sender
        self.time = time
        self.senderUsername = senderUsername
        self.commentMessage = commentMessage
        self.likesArray = likesArray
        self.dislikesArray = dislikesArray
    }
    
    func getSender() -> String {return self.sender}
    func getTime()  -> String {return self.time}
    func getSenderUsername() -> String {return self.senderUsername}
    func getCommentMessage() -> String {return self.commentMessage}
    func getLikesArray()  -> [String] {return self.likesArray}
    func getDislikesArray()  -> [String] {return self.dislikesArray}
    
    
}
    
