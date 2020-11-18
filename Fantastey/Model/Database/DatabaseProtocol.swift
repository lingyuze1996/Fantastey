//
//  DatabaseProtocol.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import Foundation

protocol Database: AnyObject {
    func registerUser(id: String, nickname: String, cookingLevel: String)
}
