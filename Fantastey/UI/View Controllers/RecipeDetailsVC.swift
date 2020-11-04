//
//  RecipeDetailsVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeDetailsVC: UITableViewController {
    private var SECTION_TITLE = 0
    private var SECTION_IMAGE = 1
    private var SECTION_INGREDIENTS = 2
    private var SECTION_INSTRUCTIONS = 3
    
    weak var recipeBasics: RecipeBasics?
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let basics = recipeBasics {
            let recipeId = basics.id
            
            recipe = Recipe(id: basics.id, title: basics.title, imageURL: basics.imageURL)
            
            retrieveIngredients(id: recipeId)
            //retrieveInstructions(id: recipeId)
        }
    }
    
    @IBAction func followAuthor(_ sender: Any) {
    }
    @IBAction func shareToTwitter(_ sender: Any) {
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_INGREDIENTS {
            return recipe?.ingredients.count ?? 0
        }
        
        if section == SECTION_INSTRUCTIONS {
            return 3
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_TITLE {
            
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "recipeTitleCell", for: indexPath) as! RecipeTitleCell
            
            if let basics = recipeBasics {
                titleCell.authorLabel.text = "Author: Spoonacular"
                titleCell.titleLabel.text = basics.title
                titleCell.followButton.isHidden = true
            }
            
            return titleCell
        }
        
        if indexPath.section == SECTION_IMAGE {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "recipeImageCell", for: indexPath) as! RecipeImageCell
            if let imageURL = recipeBasics?.imageURL {
                let jsonURL = URL(string: imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
                    if let error = error {
                        print(error)
                    } else {
                        DispatchQueue.main.async {
                            imageCell.recipeImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                task.resume()
            }
            
            return imageCell
        }
        
        if indexPath.section == SECTION_INGREDIENTS {
            let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "recipeIngredientCell", for: indexPath)
            let ingredient = recipe?.ingredients[indexPath.row]
            ingredientCell.textLabel?.text = ingredient?.name
            ingredientCell.detailTextLabel?.text = "\(ingredient!.value) " + ingredient!.unit
            
            return ingredientCell
        }
        
        let insructionsCell = tableView.dequeueReusableCell(withIdentifier: "recipeInstructionCell", for: indexPath)
        
        return insructionsCell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_INGREDIENTS {
            return "Ingredients"
        }
        
        if section == SECTION_INSTRUCTIONS {
            return "Instructions"
        }
        
        return nil
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Recipe Ingredients Retrieval
    private func retrieveIngredients(id: Int) {
        // Set query URL for recipe search from spoonacular API
        var queryURL = "https://api.spoonacular.com/recipes/"
        queryURL += "\(id)/"
        queryURL += "ingredientWidget.json?"
        queryURL += "apiKey=" + Secret.API_KEY
        
        let jsonURL = URL(string: queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            /*
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }*/
            
            if let error = error {
                print(error)
                return
            }
            
            
            do {
                let decoder = JSONDecoder()
                let ingredientsVolume = try decoder.decode(IngredientsVolume.self, from: data!)
                let ingredients = ingredientsVolume.ingredients
                self.recipe?.ingredients.append(contentsOf: ingredients)
                    
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let err {
                print(err)
            }
            
        }
        
        task.resume()
    }
    
    // MARK: - Recipe Instructions Retrieval
    private func retrieveInstructions(id: Int) {
        // Set query URL for recipe search from spoonacular API        
        var queryURL = "https://api.spoonacular.com/recipes/"
        queryURL += "\(id)/"
        queryURL += "analyzedInstructions?"
        queryURL += "apiKey=" + Secret.API_KEY
        
        let jsonURL = URL(string: queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            /*
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }*/
            
            if let error = error {
                print(error)
                return
            }
            
            /*
            do {
                let decoder = JSONDecoder()
                let resultsVolume = try decoder.decode(RecipeSearchVolume.self, from: data!)
                if let recipeResults = resultsVolume.results {
                    self.recipes.append(contentsOf: recipeResults)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } catch let err {
                print(err)
            }*/
            
        }
        
        task.resume()
    }
    


}
