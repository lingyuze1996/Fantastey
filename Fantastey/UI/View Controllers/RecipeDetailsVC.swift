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
    private final var SECTION_COMMENTS = 4
    
    @IBOutlet weak var videoButton: UIButton!
    weak var recipeBasics: RecipeBasics?
    var recipe: Recipe?
    var imageData: Data?
    
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        // From Spoonacular API
        if let basics = recipeBasics {
            let recipeId = basics.id
            
            recipe = Recipe(id: String(basics.id), title: basics.title, imageURL: basics.imageURL)
            
            retrieveIngredients(id: recipeId)
            retrieveInstructions(id: recipeId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // From Firebase
        if recipeBasics == nil {
            guard self.recipe != nil else { return }
            videoButton.isHidden = true
            tableView.reloadData()
        }
    }
    @IBAction func watchVideo(_ sender: Any) {
        // Set query URL for recipe video search from spoonacular API
        guard let title = recipeBasics?.title else { return }
        
        var queryURL = "https://api.spoonacular.com/food/videos/search?query="
        queryURL += "\(title)"
        queryURL += "&number=1&apiKey="
        queryURL += Secret.SPOONACULAR_API_KEY
        
        let jsonURL = URL(string: queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            
            do {
                let jsonRoot = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                if let videos = jsonRoot["videos"] as? [Any], videos.count != 0 {
                    if let video = videos[0] as? [String: Any] {
                        if let youtubeId = video["youTubeId"] as? String {
                            let urlString = "https://www.youtube.com/watch?v=\(youtubeId)"
                            
                            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
                            DispatchQueue.main.async {
                                // Open Video URL
                                UIApplication.shared.open(url)
                            }
                            return
                        }
                    }
                }
                
            } catch let err {
                print(err)
            }
            
            DispatchQueue.main.async {
                // Video Not Found
                let alert = UIAlertController(title: "Error", message: "Recipe Video doesn't Exist!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        task.resume()
    }
    
    @IBAction func actionList(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "Select Option: ", preferredStyle: .actionSheet)
        
        let addCommentAction = UIAlertAction(title: "Add a Comment", style: .default) { action in
            let alert = UIAlertController(title: "New Comment", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            
            let commentTextField = alert.textFields![0]
            
            commentTextField.placeholder = "Please Enter a Comment"
            
            alert.addAction(UIAlertAction(title: "Save Comment", style: .destructive, handler: { (action) in
                
                var valid = true
                var msg = ""
                
                if alert.textFields![0].text!.count == 0  {
                    msg += "- Comment is empty!\n"
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
                    
                let comment = "\(alert.textFields![0].text!)&By \(self.dbController.currentUser!.nickname)"
                self.recipe?.comments?.append(comment)
                self.tableView.reloadSections([self.SECTION_COMMENTS], with: .automatic)
                
                self.dbController.recipesCollection.document(self.recipe!.id!).updateData(["comments": FieldValue.arrayUnion([comment])])
                
                let alertSuccess = UIAlertController(title: "Success", message: "Comment Added!", preferredStyle: .alert)
                alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertSuccess, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let addToFavouritesAction = UIAlertAction(title: "Add to Favourites", style: .default) { action in
            let alert = UIAlertController(title: "Confirmation", message: "Add this recipe to Favourites?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                self.dbController.usersCollection.document(Auth.auth().currentUser!.uid).updateData(["favourites": FieldValue.arrayUnion([self.recipe!.id!])]) { error in
                    if let err = error {
                        print(err)
                        return
                    }
                    
                    let alertSuccess = UIAlertController(title: "Success", message: "Recipe Added to Favourites!", preferredStyle: .alert)
                    alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertSuccess, animated: true, completion: nil)
                }
                
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
        
        let mapAction = UIAlertAction(title: "View Map for Ingredients", style: .default) { (action) in
            self.performSegue(withIdentifier: "mapSegue", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(addCommentAction)
        actionSheet.addAction(addToFavouritesAction)
        actionSheet.addAction(twitterShareAction)
        actionSheet.addAction(mapAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func followAuthor(_ sender: Any) {
        dbController.usersCollection.document(Auth.auth().currentUser!.uid).updateData(["followings": FieldValue.arrayUnion([recipe!.authorId!])])
        
        let alert = UIAlertController(title: "Success", message: "Add to Following Authors Successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        if let button = sender as? UIButton {
            button.isEnabled = false
            button.backgroundColor = UIColor.systemGray5
        }
    }
    
    func shareToTwitter() {
        let swifter = Swifter(consumerKey: Secret.TWITTER_CONSUMER_KEY, consumerSecret: Secret.TWITTER_CONSUMER_SECRET)
        
        let url = URL(string: "Fantastey://")!
        swifter.authorize(withCallback: url, presentingFrom: self, success: { (token, response) in
            // Post tweet with recipe title and image
            swifter.postTweet(status: "\(self.recipe!.title) from Fantastey! Come and have a look!", media: self.imageData!)
            
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_INGREDIENTS {
            return recipe?.ingredients.count ?? 0
        }
        
        if section == SECTION_INSTRUCTIONS {
            return recipe?.steps.count ?? 0
        }
        
        if section == SECTION_COMMENTS {
            return recipe?.comments?.count ?? 0
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
                    dbController.retrieveCurrentUser(id: Auth.auth().currentUser!.uid)
                    
                    if !dbController.currentUser!.followings.contains(authorId) {
                        titleCell.followButton.addTarget(self, action: #selector(self.followAuthor(_:)), for: .touchUpInside)
                    } else {
                        titleCell.followButton.isEnabled = false
                        titleCell.followButton.backgroundColor = UIColor.systemGray5
                    }
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
                    storageRef.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
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
        
        // Section Comments
        if indexPath.section == SECTION_COMMENTS {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "recipeCommentCell", for: indexPath)
            if let comments = recipe?.comments {
                let comment = comments[indexPath.row]
                commentCell.textLabel?.numberOfLines = 0
                commentCell.textLabel?.lineBreakMode = .byWordWrapping
                
                let contents = comment.split(separator: "&")
                
                commentCell.textLabel?.text = String(contents[0])
                commentCell.detailTextLabel?.text = String(contents[1])
            }
            return commentCell
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
        
        if section == SECTION_COMMENTS && recipeBasics == nil {
            return "Comments"
        }
        
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SECTION_COMMENTS && recipeBasics == nil {
            return "Total Comments: \(recipe!.comments!.count)"
        }
        
        return nil
    }
    
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
