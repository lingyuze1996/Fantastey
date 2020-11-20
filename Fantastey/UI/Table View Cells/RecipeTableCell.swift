//
//  RecipeTableCell.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeTableCell: UITableViewCell {
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeDifficulty: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
