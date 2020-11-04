//
//  IngredientsVolume.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class IngredientsVolume: NSObject, Decodable {
    var ingredients: [Ingredient]
    private enum CodingKeys: String, CodingKey {
        case ingredients
    }
}
