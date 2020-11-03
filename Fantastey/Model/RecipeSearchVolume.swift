//
//  RecipeSearchVolume.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeSearchVolume: NSObject, Decodable {
    var results: [RecipeBasics]?
    var totalResults: Int?
    
    private enum CodingKeys: String, CodingKey {
        case results
        case totalResults
    }
}
