//
//  User.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 9.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import Foundation
class User
{
    private var username  : String
    private var userPhoto : String
    private var userId : String

    init(username : String, userPhoto : String, userId : String)
    {
        self.username = username
        self.userPhoto = userPhoto
        self.userId = userId
    }
    
    func getUsername() -> String {return self.username}
    func getUserPhoto() -> String {return self.userPhoto}
    func getUserId() -> String {return self.userId}
    
    
    
     
}
