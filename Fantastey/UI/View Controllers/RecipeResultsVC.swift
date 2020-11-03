//
//  RecipeResultsVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 3/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeResultsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var searchText: String!
    var indicator = UIActivityIndicatorView()
    var recipes = [RecipeBasics]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = collectionView.center
        view.addSubview(indicator)
        
        guard let searchText = searchText else { return }
        
        performSearch(searchText: searchText)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    private func performSearch(searchText: String) {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        // Set query URL for recipe search from spoonacular API
        var queryURL = "https://api.spoonacular.com/recipes/complexSearch?query="
        queryURL += searchText
        queryURL += "&number=100"
        queryURL += "&apiKey=" + Secret.API_KEY
        
        let jsonURL = URL(string: queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            
            if let error = error {
                print(error)
                return
            }
            
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
            }
            
        }
        
        task.resume()
    }
}

// MARK: UICollectionViewDataSource
extension RecipeResultsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCell
        
        // Cell Configuration
        let recipe = recipes[indexPath.row]
        if let imageURL = recipe.imageURL {
            let jsonURL = URL(string: imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
                if let error = error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        cell.recipeImageView.image = UIImage(data: data!)
                    }
                }
            }
            
            task.resume()
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension RecipeResultsVC: UICollectionViewDelegate {
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}
