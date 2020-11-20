//
//  HomeVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 19/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, DatabaseListener {
    
    
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
        dbController.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dbController.removeListener(listener: self)
    }
    
    // MARK: - Database Listener Protocol
    var listenerType: ListenerType = .myRecipes
    
    func onMyRecipesChange(recipes: [Recipe]) {
        self.recipes = recipes
        tableView.reloadData()
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RecipeDetailsVC
        
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
    
}
