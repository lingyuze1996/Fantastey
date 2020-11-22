//
//  RecipeSearchVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Firebase

class RecipeSearchVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeSearchSegue" {
            let destinationVC = segue.destination as! RecipeResultsVC
            destinationVC.searchText = sender as? String
        }
    }
    
}

// MARK: - UISearchBar Delegate Function
extension RecipeSearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else { return }
        performSegue(withIdentifier: "recipeSearchSegue", sender: searchText)
    }
    
    
}
