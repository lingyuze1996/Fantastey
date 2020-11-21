//
//  HomeVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 19/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dbController: FirebaseController!
    
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController

        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbController.recipesCollection.whereField("authorId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (snapshot, error) in
            if let err = error {
                print(err)
                return
            }
            
            if let snapshot = snapshot {
            
                self.recipes.removeAll()
                
                for document in snapshot.documents {
                    let id = document.documentID
                    let title = document.get("title") as! String
                    let difficulty = document.get("difficulty") as! String
                    let imageURL = document.get("imageURL") as! String
                    let steps = document.get("steps") as! [String]
                    let ingredients = document.get("ingredients") as! [[String: Any]]
                    let author = document.get("authorId") as! String
                    
                    let recipe = Recipe(id: id, title: title, imageURL: imageURL, difficulty: difficulty)
                    recipe.authorId = author
                    
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
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myRecipeDetailsSegue" {
            let destinationVC = segue.destination as! RecipeDetailsVC
            destinationVC.recipe = sender as? Recipe
        }
    }
}

// MARK: - Table View Data Source & Delegate Functions
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
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
        performSegue(withIdentifier: "myRecipeDetailsSegue", sender: recipes[indexPath.row])
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
                
                self.dbController.recipesCollection.document(recipe.id!).delete() { error in
                    if let err = error {
                        print(err)
                        let alertFail = UIAlertController(title: "Error", message: "Fail to Delete Recipe!", preferredStyle: .alert)
                        alertFail.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertFail, animated: true, completion: nil)
                        return
                    }
                    
                    self.recipes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    let alertSuccess = UIAlertController(title: "Success", message: "Recipe Deleted Successfully!", preferredStyle: .alert)
                    alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertSuccess, animated: true, completion: nil)
                }
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
}
