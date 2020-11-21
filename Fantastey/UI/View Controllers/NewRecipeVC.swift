//
//  NewRecipeVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class NewRecipeVC: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var difficultySC: UISegmentedControl!
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    private final var SECTION_INGREDIENTS = 0
    private final var SECTION_INSTRUCTIONS = 1
    
    var dbController: FirebaseController!
    
    var steps = [String]()
    var ingredients = [Ingredient]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: nil, message: "Select Option: ", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func saveRecipe(_ sender: Any) {
        guard validateRecipe() else { return }
        
        let title = titleTextField.text
        let difficulty = difficultySC.titleForSegment(at: difficultySC.selectedSegmentIndex)!
        
        let date = UInt(Date().timeIntervalSince1970)
        let imageURL = "\(date)\(dbController.currentUser!.id).jpg"
        
        let recipe = Recipe(id: nil, title: title!, imageURL: imageURL)
        recipe.setDifficulty(difficulty: difficulty)
        recipe.setIngredients(ingredients: ingredients)
        recipe.setSteps(steps: steps)
        
        dbController.uploadRecipeDetails(recipe: recipe)
        dbController.uploadRecipeImage(imageURL: recipe.imageURL!, data: recipeImage.image!.jpegData(compressionQuality: 0.6)!)
        
        let alert = UIAlertController(title: "Success", message: "Create recipe successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController!.popViewController(animated: true)
        })
        
        navigationController!.present(alert, animated: true)
    }
    
    func validateRecipe() -> Bool {
        return true
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
// MARK: - Image Picker Controller Delegate Function
extension NewRecipeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            recipeImage.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Table View DataSource and Delegate Functions
extension NewRecipeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_INGREDIENTS {
            return ingredients.count
        }
        
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Section Ingredients
        if indexPath.section == SECTION_INGREDIENTS {
            let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "recipeIngredientCell", for: indexPath)
            let ingredient = ingredients[indexPath.row]
            ingredientCell.textLabel?.text = ingredient.name
            ingredientCell.detailTextLabel?.text = "\(ingredient.value) " + ingredient.unit
            
            return ingredientCell
        }
        
        // Section Instructions
        let instructionCell = tableView.dequeueReusableCell(withIdentifier: "recipeInstructionCell", for: indexPath)
        let step = steps[indexPath.row]
        instructionCell.textLabel?.numberOfLines = 0
        instructionCell.textLabel?.lineBreakMode = .byWordWrapping
        instructionCell.textLabel?.text = "Step " + "\(indexPath.row + 1):\n" + step
        
        return instructionCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_INGREDIENTS {
            return "Ingredients"
        }
        
        return "Instructions"
    }
}
