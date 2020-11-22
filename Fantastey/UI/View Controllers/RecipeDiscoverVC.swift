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

        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.delegate = self
        
        searchController.searchBar.placeholder = "What are you looking for?"
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        //to beautify the background - zoe
        view.backgroundColor = UIColor(patternImage:UIImage(named:"fantasteyBackground.png")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recommendRecipes()
    }
    
    private func recommendRecipes() {
        auto = true
        
        let id = dbController.currentUser!.id
        let level = dbController.currentUser!.cookingLevel
        
        var recommendedDifficulty = "Easy"
        
        if level == "Advanced" {
            recommendedDifficulty = "Hard"
        } else if level == "Intermediate" {
            recommendedDifficulty = "Middle"
        }
        
        dbController.recipesCollection.whereField("difficulty", isEqualTo: recommendedDifficulty).getDocuments() { (snapshot, error) in
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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RecipeDetailsVC
        destinationVC.recipe = sender as? Recipe
    }
    

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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Total Recipes: \(recipes.count)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "discoverDetailsSegue", sender: recipes[indexPath.row])
    }
}


// MARK: - UISearchBar Delegate
extension RecipeDiscoverVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else { return }
        searchRecipes(searchText)
    }
    
    func searchRecipes(_ text: String) {
        auto = false
        let id = dbController.currentUser!.id
        
        dbController.recipesCollection.getDocuments() { (snapshot, error) in
            if let err = error {
                print(err)
                return
            }
            
            if let snapshot = snapshot {
            
                self.recipes.removeAll()
                
                for document in snapshot.documents {
                    let author = document.get("authorId") as! String
                    if author == id { continue }
                    
                    let title = document.get("title") as! String
                    if !title.lowercased().contains(text.lowercased()) { continue }
                    
                    let id = document.documentID
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
    
    
}
