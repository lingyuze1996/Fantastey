//
//  RecipeDiscoverVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeDiscoverVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.delegate = self
        
        searchController.searchBar.placeholder = "What are you looking for?"
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
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

// MARK: - UISearchBar Delegate
extension RecipeDiscoverVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else { return }
        //performSegue(withIdentifier: "recipeSearchSegue", sender: searchText)
    }
    
    
}
