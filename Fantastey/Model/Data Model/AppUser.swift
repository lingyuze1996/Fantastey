//
//  AppUser.swift
//  Fantastey
//
//  Created by Yuze Ling on 19/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class AppUser: NSObject {
    var id: String
    var nickname: String
    var cookingLevel: String
    var followings: [String]
    
    init(id: String, nickname: String, cookingLevel: String, followings: [String]) {
        self.id = id
        self.nickname = nickname
        self.cookingLevel = cookingLevel
        self.followings = followings
    }
}
