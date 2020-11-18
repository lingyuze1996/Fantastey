//
//  RecipeData.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeBasics: NSObject, Decodable {
    var id: Int
    var title: String
    var imageURL: String?
    
    private enum Keys: String, CodingKey {
        case id
        case title
        case imageURL = "image"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        imageURL = try? container.decode(String.self, forKey: .imageURL)
    }
    
    
    
    
}
