//
//  Chats.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 7.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import Foundation
class Chat
{
    private var id : String
    private var time  : String
    private var numberOfPerson: String
    private var currentNumberOfPerson : Int
    private var title : String

    init(id : String, time : String, numberOfPerson : String, currentNumberOfPerson : Int, title:String)
    {
        self.id = id
        self.time = time
        self.numberOfPerson = numberOfPerson
        self.currentNumberOfPerson = currentNumberOfPerson
        self.title = title
    }
    
    func getId() -> String {return self.id}
    func getTime() -> String {return self.time}
    func getNumberOfPerson() -> String {return self.numberOfPerson}
    func getCurrentNumberOfPerson() -> Int {return self.currentNumberOfPerson}
    func getTitle() -> String{return self.title}
}
