//
//  Recipe.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    var id: Any
    var title: String
    var imageURL: String?
    var ingredients: [Ingredient]
    
    init(id: Any, title: String, imageURL: String?) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.ingredients = []
    }
    
}
