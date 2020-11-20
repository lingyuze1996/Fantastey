//
//  Recipe.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class Recipe: NSObject, Codable {
    var id: String?
    var title: String
    var imageURL: String?
    var difficulty: String?
    var ingredients: [Ingredient]
    var steps: [String]
    
    init(id: String?, title: String, imageURL: String?) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.ingredients = []
        self.steps = []
    }
    
    func setDifficulty(difficulty: String) {
        self.difficulty = difficulty
    }
    
    private enum Keys: String, CodingKey {
        case id
        case title
        case imageURL
        case difficulty
        case ingredients
        case steps
    }
    
}
