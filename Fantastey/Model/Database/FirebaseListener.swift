//
//  FirebaseListener.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import Foundation

enum ListenerType {
    case myRecipes
    case myFavourites
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    //func onExhibitionsChange(exhibitions: [Exhibition])
    //func onExhibitionPlantsChange(exhibitionPlants: [Plant])
    //func onPlantsChange(plants: [Plant])
    func onMyRecipesChange(recipes: [Recipe])
}
