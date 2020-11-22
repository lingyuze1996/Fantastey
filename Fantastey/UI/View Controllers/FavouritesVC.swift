//
//  FavouritesVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 22/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class FavouritesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dbController: FirebaseController!
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //to beautify the background - zoe
        view.backgroundColor = UIColor(patternImage:UIImage(named:"fantasteyBackground.png")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let id = Auth.auth().currentUser!.uid
        
        dbController.usersCollection.document(id).getDocument { (snapshot, error) in
            if let snapshot = snapshot {
                if snapshot.exists {
                    let favourites = snapshot.get("favourites") as! [String]
                    self.recipes.removeAll()
                    
                    for recipeId in favourites {
                        self.dbController.recipesCollection.document(recipeId).getDocument { (document, error) in
                            if let document = document {
                                if document.exists {
                                    let id = document.documentID
                                    let title = document.get("title") as! String
                                    let difficulty = document.get("difficulty") as! String
                                    let imageURL = document.get("imageURL") as! String
                                    let steps = document.get("steps") as! [String]
                                    let ingredients = document.get("ingredients") as! [[String: Any]]
                                    let author = document.get("authorId") as! String
                                    let comments = document.get("comments") as! [String]
                                    
                                    let recipe = Recipe(id: id, title: title, imageURL: imageURL, difficulty: difficulty)
                                    recipe.authorId = author
                                    
                                    for comment in comments {
                                        recipe.comments?.append(comment)
                                    }
                                    
                                    for step in steps {
                                        recipe.steps.append(step)
                                    }
                                    
                                    for ingredient in ingredients {
                                        let name = ingredient["name"] as! String
                                        let value = ingredient["value"] as! Float
                                        let unit = ingredient["unit"] as! String
                                        
                                        recipe.ingredients.append(Ingredient(name: name, value: value, unit: unit))
                                    }
                                    
                                    self.recipes.append(recipe)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favouriteRecipeDetailsSegue" {
            let destinationVC = segue.destination as! RecipeDetailsVC
            destinationVC.recipe = sender as? Recipe
        }
    }
    

}

extension FavouritesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeTableCell", for: indexPath) as! RecipeTableCell
        let recipe = recipes[indexPath.row]
        cell.recipeTitle.text = recipe.title
        cell.recipeDifficulty.text = recipe.difficulty
        
        if let imageURL = recipe.imageURL {
            let storageRef = dbController.storage.reference().child("images/" + imageURL)
            storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                if let err = error {
                    print(err)
                    return
                }
                
                cell.recipeImageView.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "favouriteRecipeDetailsSegue", sender: recipes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Confirmation", message: "Sure to delete this recipe?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Delete the row from the data source
                let recipe = self.recipes[indexPath.row]
                
                self.dbController.usersCollection.document(Auth.auth().currentUser!.uid).updateData(["favourites" : FieldValue.arrayRemove([recipe.id!])]) { error in
                    if let err = error {
                        print(err)
                        let alertFail = UIAlertController(title: "Error", message: "Fail to Delete Recipe!", preferredStyle: .alert)
                        alertFail.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertFail, animated: true, completion: nil)
                        return
                    }
                    
                    self.recipes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    let alertSuccess = UIAlertController(title: "Success", message: "Recipe Deleted From Favourites!", preferredStyle: .alert)
                    alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertSuccess, animated: true, completion: nil)
                }
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
}
