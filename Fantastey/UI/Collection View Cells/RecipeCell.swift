//
//  RecipeCell.swift
//  Fantastey
//
//  Created by Yuze Ling on 3/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    
    //reference:https://medium.com/dev-genius/swift-how-to-create-a-rounded-collectionviewcell-with-shadow-d696bd46c43f
    //for beautifying the cell - zoe
    override func layoutSubviews() {
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        //        let View=UIView()
        //        View.backgroundColor = UIColor(patternImage:UIImage(named:"searchCollectionViewCell.png")!)
        self.contentView.backgroundColor = UIColor(patternImage:UIImage(named:"searchCollectionViewCell.png")!)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    
    
}
