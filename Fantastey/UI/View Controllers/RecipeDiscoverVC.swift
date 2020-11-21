//
//  RecipeDiscoverVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class RecipeDiscoverVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var auto = true
    
    var recipes = [Recipe]()
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        recommendRecipes()

        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.delegate = self
        
        searchController.searchBar.placeholder = "What are you looking for?"
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func recommendRecipes() {
        let id = dbController.currentUser!.id
        let level = dbController.currentUser!.cookingLevel
        
        dbController.recipesCollection.whereField("level", isEqualTo: level).getDocuments() { (snapshot, error) in
            if let err = error {
                print(err)
                return
            }
            
            if let snapshot = snapshot {
            
                self.recipes.removeAll()
                
                for document in snapshot.documents {
                    let author = document.get("authorId") as! String
                    if author == id { continue }
                    
                    let id = document.documentID
                    let title = document.get("title") as! String
                    let difficulty = document.get("difficulty") as! String
                    let imageURL = document.get("imageURL") as! String
                    let steps = document.get("steps") as! [String]
                    let comments = document.get("comments") as! [String]
                    let ingredients = document.get("ingredients") as! [[String: Any]]
                    
                    let recipe = Recipe(id: id, title: title, imageURL: imageURL, difficulty: difficulty)
                    recipe.authorId = author
                    
                    for step in steps {
                        recipe.steps.append(step)
                    }
                    
                    for comment in comments {
                        recipe.comments?.append(comment)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: - Table View Delegate & Data Source Functions
extension RecipeDiscoverVC: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if auto {
            return "Auto Recommended Recipes"
        }
        
        return "Recipes Found"
    }
}


// MARK: - UISearchBar Delegate
extension RecipeDiscoverVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else { return }
        //performSegue(withIdentifier: "recipeSearchSegue", sender: searchText)
    }
    
    
}