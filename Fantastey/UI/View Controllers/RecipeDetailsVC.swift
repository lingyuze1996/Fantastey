//
//  RecipeDetailsVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Swifter

class RecipeDetailsVC: UITableViewController {
    private final var SECTION_TITLE = 0
    private final var SECTION_IMAGE = 1
    private final var SECTION_INGREDIENTS = 2
    private final var SECTION_INSTRUCTIONS = 3
    
    weak var recipeBasics: RecipeBasics?
    var recipe: Recipe?
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let basics = recipeBasics {
            let recipeId = basics.id
            
            recipe = Recipe(id: String(basics.id), title: basics.title, imageURL: basics.imageURL)
            
            retrieveIngredients(id: recipeId)
            retrieveInstructions(id: recipeId)
        }
    }
    
    @IBAction func shareToTwitter(_ sender: Any) {
        let swifter = Swifter(consumerKey: Secret.TWITTER_CONSUMER_KEY, consumerSecret: Secret.TWITTER_CONSUMER_SECRET)
        
        let url = URL(string: "Fantastey://")!
        swifter.authorize(withCallback: url, presentingFrom: self, success: { (token, response) in
            // Post tweet with recipe title and image
            swifter.postTweet(status: "\(self.recipe!.title) from Fantastey!\n", media: self.imageData!)
            
            // Success Message
            let alert = UIAlertController(title: "Success", message: "Recipe is shared to Twitter successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }, failure: { (error) in
            
            // Error Message
            let alert = UIAlertController(title: "Error", message: "Fail to share recipe to Twitter!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
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
            return recipe?.steps.count ?? 0
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Section Title
        if indexPath.section == SECTION_TITLE {
            
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "recipeTitleCell", for: indexPath) as! RecipeTitleCell
            
            if let basics = recipeBasics {
                titleCell.authorLabel.text = "Author: Spoonacular"
                titleCell.titleLabel.text = basics.title
                titleCell.followButton.isHidden = true
            }
            
            return titleCell
        }
        
        // Section Image
        if indexPath.section == SECTION_IMAGE {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "recipeImageCell", for: indexPath) as! RecipeImageCell
            if let imageURL = recipeBasics?.imageURL {
                let jsonURL = URL(string: imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.imageData = data
                        DispatchQueue.main.async {
                            imageCell.recipeImageView.image = UIImage(data: data!)
                        }
                    }
                }
                
                task.resume()
            }
            
            return imageCell
        }
        
        // Section Ingredients
        if indexPath.section == SECTION_INGREDIENTS {
            let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "recipeIngredientCell", for: indexPath)
            let ingredient = recipe?.ingredients[indexPath.row]
            ingredientCell.textLabel?.text = ingredient?.name
            ingredientCell.detailTextLabel?.text = "\(ingredient!.value) " + ingredient!.unit
            
            return ingredientCell
        }
        
        // Section Instructions
        let instructionCell = tableView.dequeueReusableCell(withIdentifier: "recipeInstructionCell", for: indexPath)
        let step = recipe?.steps[indexPath.row]
        instructionCell.textLabel?.numberOfLines = 0
        instructionCell.textLabel?.lineBreakMode = .byWordWrapping
        instructionCell.textLabel?.text = "Step " + "\(indexPath.row + 1):\n" + step!
        
        return instructionCell
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
        
        //let indexPath = tableView.indexPathForSelectedRow() //optional, to get from any UIButton for example
        
        let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        guard let searchTextArray = selectedCell.textLabel?.text!.split{$0 == " "}.map(String.init)else { return }
        
        var fullSearchText:String = ""
        
        if searchTextArray.count > 1 {
            for singleSearchText in searchTextArray {
                fullSearchText += "%20"
                fullSearchText += singleSearchText
            }
        }else{
            fullSearchText = searchTextArray.first!
        }
        
        let urlString = "https://www.woolworths.com.au/shop/search/products?searchTerm=" + fullSearchText
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
        
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
        queryURL += "apiKey=" + Secret.SPOONACULAR_API_KEY
        
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
            } catch let err {
                print(err)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadSections([self.SECTION_INSTRUCTIONS, self.SECTION_INGREDIENTS], with: .automatic)
                //self.tableView.reloadData()
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
        queryURL += "apiKey=" + Secret.SPOONACULAR_API_KEY
        
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
            
            let jsonRoot = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let root = jsonRoot as? [Any] {
                if root.count > 0, let rootDictionary = root[0] as? [String: Any] {
                    if let steps = rootDictionary["steps"] as? [Any], steps.count > 0 {
                        for step in steps {
                            if let step = step as? [String: Any] {
                                if let stepString = step["step"] as? String {
                                    self.recipe?.steps.append(stepString)
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                //self.tableView.reloadData()
                self.tableView.reloadSections([self.SECTION_INGREDIENTS, self.SECTION_INSTRUCTIONS], with: .automatic)
            }
        }
        
        task.resume()
    }
    
    
    
}
