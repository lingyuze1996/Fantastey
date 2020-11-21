//
//  RecipeDetailsVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Swifter
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

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
        
        // From Spoonacular API
        if let basics = recipeBasics {
            let recipeId = basics.id
            
            recipe = Recipe(id: String(basics.id), title: basics.title, imageURL: basics.imageURL)
            
            retrieveIngredients(id: recipeId)
            retrieveInstructions(id: recipeId)
        }
        
        // From Firebase
        else {
            guard self.recipe != nil else { return }
            tableView.reloadData()
        }
    }
    
    @IBAction func actionList(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "Select Option: ", preferredStyle: .actionSheet)
        
        // For iPad
        //actionSheet.popoverPresentationController?.sourceView = self.tableView
        //actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.tableView.bounds.midX, y: self.tableView.bounds.minY, width: 20, height: 20)
        
        let addCommentAction = UIAlertAction(title: "Add a Comment", style: .default) { action in
            let alert = UIAlertController(title: "New Comment", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            
            let commentTextField = alert.textFields![0]
            
            commentTextField.placeholder = "Please Enter a Comment"
            
            alert.addAction(UIAlertAction(title: "Save Comment", style: .destructive, handler: { (action) in
                
                var valid = true
                var msg = ""
                
                if alert.textFields![0].text!.count == 0  {
                    msg += "- Name is empty!\n"
                    valid = false
                }
                
                if alert.textFields![0].text!.count > 100  {
                    msg += "- Comment shouldn't exceed 100 characters!"
                    valid = false
                }
                
                guard valid else {
                    let alertError = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertError, animated: true, completion: nil)
                    return
                }
                    
                let comment = alert.textFields![0].text!
                print("success")
                //self.recipe.comment
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let addToFavouritesAction = UIAlertAction(title: "Add to Favourites", style: .default) { action in
            let alert = UIAlertController(title: "Confirmation", message: "Add this recipe to Favourites?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("233")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let twitterShareAction = UIAlertAction(title: "Share Recipe to Twitter", style: .default) { action in
            let alert = UIAlertController(title: "Confirmation", message: "Share this recipe to Twitter?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.shareToTwitter()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        /*
        let saveAction = UIAlertAction(title: "Save Recipe", style: .destructive) { (action) in
            guard self.validateRecipe() else { return }
            
            let title = self.titleTextField.text
            let difficulty = self.difficultySC.titleForSegment(at: self.difficultySC.selectedSegmentIndex)!
            
            let date = UInt(Date().timeIntervalSince1970)
            let imageURL = "\(date)\(Auth.auth().currentUser!.uid).jpg"
            
            let recipe = Recipe(id: nil, title: title!, imageURL: imageURL)
            recipe.setDifficulty(difficulty: difficulty)
            recipe.setIngredients(ingredients: self.ingredients)
            recipe.setSteps(steps: self.steps)
            
            self.indicator.startAnimating()
            self.indicator.backgroundColor = UIColor.clear
            
            self.dbController.uploadRecipeDetails(recipe: recipe)
            self.uploadRecipeImage(imageURL: recipe.imageURL!, data: self.recipeImage.image!.jpegData(compressionQuality: 0.6)!)
        }
 */
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(addCommentAction)
        actionSheet.addAction(addToFavouritesAction)
        //actionSheet.addAction(saveAction)
        actionSheet.addAction(twitterShareAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func followAuthor(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "Add to Following Authors Successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareToTwitter() {
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
            
            // From Spoonacular
            if let basics = recipeBasics {
                titleCell.authorLabel.text = "Author: Spoonacular"
                titleCell.titleLabel.text = basics.title
                titleCell.followButton.isHidden = true
            }
            
            // From Firebase
            else {
                let authorId = recipe!.authorId!
                
                if authorId == Auth.auth().currentUser!.uid {
                    titleCell.followButton.isHidden = true
                } else {
                    titleCell.followButton.addTarget(self, action: #selector(self.followAuthor(_:)), for: .touchUpInside)
                }
                
                Firestore.firestore().collection("users").document(authorId).getDocument { (document, error) in
                    if let document = document {
                        if document.exists {
                            if let nickname = document.get("nickname") as? String {
                                titleCell.authorLabel.text = "Author: \(nickname)"
                            }
                        }
                    }
                }
                
                
                titleCell.titleLabel.text = recipe?.title
            }
            
            return titleCell
        }
        
        // Section Image
        if indexPath.section == SECTION_IMAGE {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "recipeImageCell", for: indexPath) as! RecipeImageCell
            
            // From Spoonacular
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
            
            // From Firebase
            else {
                if let imageURL = recipe?.imageURL {
                    let storageRef = Storage.storage().reference().child("images/" + imageURL)
                    storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                        if let err = error {
                            print(err)
                            return
                        }
                        
                        self.imageData = data
                        imageCell.recipeImageView.image = UIImage(data: data!)
                    }
                }
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == SECTION_INGREDIENTS else { return }
        
        let ingredient = recipe!.ingredients[indexPath.row]
        let searchText = ingredient.name
        
        let urlString = "https://www.woolworths.com.au/shop/search/products?searchTerm=" + searchText
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        UIApplication.shared.open(url)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Recipe Ingredients Retrieval From Spooncular
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
    
    // MARK: - Recipe Instructions Retrieval From Spoonacular
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
