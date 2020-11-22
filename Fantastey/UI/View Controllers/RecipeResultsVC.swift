//
//  RecipeResultsVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 3/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RecipeResultsVC: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    
    var searchText: String!
    var indicator = UIActivityIndicatorView()
    var recipes = [RecipeBasics]()
    
    //for sizing
    var cellSizes: [CGSize]!
    //var isLongText:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = collectionView.center
        view.addSubview(indicator)
        
        guard let searchText = searchText else { return }
        
        performSearch(searchText: searchText)
        
        //to beautify the background - zoe
        collectionView.backgroundColor = UIColor(patternImage:UIImage(named:"fantasteyBackground.png")!)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue" {
            let destinationVC = segue.destination as! RecipeDetailsVC
            destinationVC.recipeBasics = sender as? RecipeBasics
        }
    }
    
    private func performSearch(searchText: String) {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        // Set query URL for recipe search from spoonacular API
        var queryURL = "https://api.spoonacular.com/recipes/complexSearch?query="
        queryURL += searchText
        queryURL += "&number=100"
        queryURL += "&apiKey=" + Secret.SPOONACULAR_API_KEY
        
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
        cell.recipeTitle.text = recipe.title
        
//        if cell.recipeTitle.text!.count >= 36 {
//            isLongText = true
//        }
        
        
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
        
        //for changing the cell size base on the text length
        // Calculates the height
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
        //cellSizes[cell.size] = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        cell.recipeTitle.adjustsFontSizeToFitWidth = true
        cell.recipeTitle.minimumScaleFactor = 0.5
        
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension RecipeResultsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //for beautifying
            let cell = collectionView.cellForItem(at: indexPath)

            //Briefly fade the cell on selection
            UIView.animate(withDuration: 0.5,
                           animations: {
                            //Fade-out
                            cell?.alpha = 0.5
            }) { (completed) in
                UIView.animate(withDuration: 0.5,
                               animations: {
                                //Fade-out
                                cell?.alpha = 1
                })
                let recipeBasics = self.recipes[indexPath.row]
                self.performSegue(withIdentifier: "recipeDetailsSegue", sender: recipeBasics)
            }

        
       
    }
}

// MARK: - Collection View Flow Layout Functions
extension RecipeResultsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
//        if self.isLongText == true{
//            self.isLongText = false
//            return CGSize(width: widthPerItem, height: widthPerItem * 1.50)
//        }else{
        return CGSize(width: widthPerItem, height: widthPerItem * 1.25)
        //}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    //for changing the cell based on text lable
    // MARK: - UICollectionViewDelegateFlowLayout

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            NSLog("\(self), collectionView:layout:sizeForItemAtIndexPath")
            
//            cellSizes[indexPath.item] = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            return cellSizes[indexPath.item]
        }
}

