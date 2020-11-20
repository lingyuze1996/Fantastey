//
//  Ingredient.swift
//  Fantastey
//
//  Created by Yuze Ling on 4/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class Ingredient: NSObject, Codable {
    var name: String
    var value: Float
    var unit: String
    
    private enum Keys: String, CodingKey {
        case name
        case amount
    }
    
    private struct Amount: Codable {
        var metric: Metric
    }
    
    private struct Metric: Codable {
        var value: Float
        var unit: String
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        name = try container.decode(String.self, forKey: .name)
        
        let amount = try container.decode(Amount.self, forKey: .amount)
        
        value = amount.metric.value
        unit = amount.metric.unit
    }
    
    init(name: String, value: Float, unit: String) {
        self.name = name
        self.value = value
        self.unit = unit
    }
}
