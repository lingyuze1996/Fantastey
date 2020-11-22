//
//  NewRecipeVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class NewRecipeVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var difficultySC: UISegmentedControl!
    
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    private final var SECTION_INGREDIENTS = 0
    private final var SECTION_INSTRUCTIONS = 1
    
    var dbController: FirebaseController!
    
    weak var recipe: Recipe?
    
    var imageAltered = false
    
    var steps = [String]()
    var ingredients = [Ingredient]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = view.center
        view.addSubview(indicator)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // For dismiss keyboard - zoe
        titleTextField.delegate = self
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        //to beautify the background - zoe
        view.backgroundColor = UIColor(patternImage:UIImage(named:"fantasteyBackground.png")!)
        
        // Editing
        if let recipe = recipe {
            navigationItem.title = "Edit Recipe"
            
            titleTextField.text = recipe.title
            difficultySC.selectedSegmentIndex = 1
            
            if recipe.difficulty == "Easy" {
                difficultySC.selectedSegmentIndex = 0
            } else if recipe.difficulty == "Hard" {
                difficultySC.selectedSegmentIndex = 2
            }
            
            steps = recipe.steps
            ingredients = recipe.ingredients
            tableView.reloadData()
            
            if let imageURL = recipe.imageURL {
                let storageRef = dbController.storage.reference().child("images/" + imageURL)
                storageRef.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
                    if let err = error {
                        print(err)
                        return
                    }
                    
                    self.recipeImage.image = UIImage(data: data!)
                }
            }
        }
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
        
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func recipeAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "Select Option: ", preferredStyle: .actionSheet)
        let addIngredientAction = UIAlertAction(title: "Add Ingredient", style: .default) { action in
            let alert = UIAlertController(title: "New Ingredient", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
            
            let nameTextField = alert.textFields![0]
            let amountTextField = alert.textFields![1]
            let unitTextField = alert.textFields![2]
            
            nameTextField.placeholder = "Please Enter Ingredient Name"
            amountTextField.placeholder = "Please Enter Ingredient Amount"
            unitTextField.placeholder = "Please Enter Ingredient Unit"
            
            alert.addAction(UIAlertAction(title: "Save Ingredient", style: .destructive, handler: { (action) in
                
                var valid = true
                var msg = ""
                
                if alert.textFields![0].text!.count == 0 {
                    msg += "- Name is empty!\n"
                    valid = false
                }
                
                if alert.textFields![1].text!.count == 0 {
                    msg += "- Amount is empty!\n"
                    valid = false
                }
                
                if alert.textFields![2].text!.count == 0 {
                    msg += "- Unit is empty!\n"
                    valid = false
                }
                
                
                let amount = (alert.textFields![1].text! as NSString).floatValue
                if amount == 0 {
                    msg += "- Amount is not valid!"
                    valid = false
                }
                
                guard valid else {
                    let alertError = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertError, animated: true, completion: nil)
                    return
                }
                    
                let unit = alert.textFields![2].text!
                let name = alert.textFields![0].text!
                let ingredient = Ingredient(name: name, value: amount , unit: unit)
                self.ingredients.append(ingredient)
                self.tableView.reloadSections([self.SECTION_INGREDIENTS], with: .automatic)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let addInstructionAction = UIAlertAction(title: "Add Instruction", style: .default) { action in
            let alert = UIAlertController(title: "New Instruction", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let textField = alert.textFields![0]
            textField.placeholder = "Please Enter Instruction"
            alert.addAction(UIAlertAction(title: "Save Instruction", style: .destructive, handler: { (action) in
                if let step = alert.textFields![0].text, step.count != 0 {
                    self.steps.append(step)
                    self.tableView.reloadSections([self.SECTION_INSTRUCTIONS], with: .automatic)
                } else {
                    let alertError = UIAlertController(title: "Error", message: "Instruction is empty!", preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertError, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let saveAction = UIAlertAction(title: "Save Recipe", style: .destructive) { (action) in
            guard self.validateRecipe() else { return }
            
            self.indicator.startAnimating()
            self.indicator.backgroundColor = UIColor.clear
            
            let title = self.titleTextField.text
            let difficulty = self.difficultySC.titleForSegment(at: self.difficultySC.selectedSegmentIndex)!
            
            // For New Recipe
            if self.navigationItem.title != "Edit Recipe" {
                let date = UInt(Date().timeIntervalSince1970)
                let imageURL = "\(date)\(Auth.auth().currentUser!.uid).jpg"
                let newRecipe = Recipe(id: nil, title: title!, imageURL: imageURL)
                newRecipe.setDifficulty(difficulty: difficulty)
                newRecipe.setIngredients(ingredients: self.ingredients)
                newRecipe.setSteps(steps: self.steps)
                self.dbController.uploadRecipeDetails(recipe: newRecipe)
                self.uploadRecipeImage(imageURL: newRecipe.imageURL!, data: self.recipeImage.image!.jpegData(compressionQuality: 0.6)!)
            }
            
            // For Recipe Editing
            else {
                self.recipe?.setTitle(title: title!)
                self.recipe?.setDifficulty(difficulty: difficulty)
                self.recipe?.setSteps(steps: self.steps)
                self.recipe?.setIngredients(ingredients: self.ingredients)
                
                // Image Not Changed
                if !self.imageAltered {
                    let encoder = JSONEncoder()
                    do {
                        let recipeJSON = try encoder.encode(self.recipe)
                        let recipeDictionary = try JSONSerialization.jsonObject(with: recipeJSON, options: []) as! [String: Any]
                        self.dbController.recipesCollection.document(self.recipe!.id!).setData(recipeDictionary) { (error) in
                            if let err = error {
                                print(err)
                            }
                            
                            let alert = UIAlertController(title: "Success", message: "Upload recipe successfully!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                                self.navigationController!.popViewController(animated: true)
                            })
                            
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            self.navigationController!.present(alert, animated: true)
                        }
                    } catch let err {
                        print(err)
                    }
                }
                
                // Image Changed
                else {
                    self.uploadRecipeImage(imageURL: self.recipe!.imageURL!, data: self.recipeImage.image!.jpegData(compressionQuality: 0.6)!)
                    let encoder = JSONEncoder()
                    do {
                        let recipeJSON = try encoder.encode(self.recipe)
                        let recipeDictionary = try JSONSerialization.jsonObject(with: recipeJSON, options: []) as! [String: Any]
                        self.dbController.recipesCollection.document(self.recipe!.id!).setData(recipeDictionary) { (error) in
                            if let err = error {
                                print(err)
                            }
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(addIngredientAction)
        actionSheet.addAction(addInstructionAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
        
        
    }
    
    func validateRecipe() -> Bool {
        var msg = ""
        
        if titleTextField.text?.count == 0 {
            msg += "- Recipe Title is Empty!\n"
        }
        
        if difficultySC.selectedSegmentIndex == -1 {
            msg += "- Recipe Difficulty is Empty!\n"
        }
        
        if recipeImage.image == nil {
            msg += "- Recipe Image is Empty!\n"
        }
        
        if ingredients.count == 0 {
            msg += "- Recipe Ingredients are Empty!\n"
        }
        
        if steps.count == 0 {
            msg += "- Recipe Instructions are Empty!"
        }
        
        if msg != "" {
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    private func uploadRecipeImage(imageURL: String, data: Data) {
        guard imageAltered else {return}
        let storageRef = Storage.storage().reference().child("images/" + imageURL)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
                return
            }
            
            guard metadata != nil else {
                return
            }
            
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            
            let alert = UIAlertController(title: "Success", message: "Upload recipe successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController!.popViewController(animated: true)
            })
            
            self.navigationController!.present(alert, animated: true)
        }
    }
    
}
// MARK: - Image Picker Controller Delegate Function
extension NewRecipeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            recipeImage.image = pickedImage
            imageAltered = true
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Section Instructions
            if indexPath.section == SECTION_INSTRUCTIONS {
                let alert = UIAlertController(title: "Confirmation", message: "Sure to delete this step?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    // Delete the row from the data source
                    
                    self.steps.remove(at: indexPath.row)
                    tableView.reloadSections([indexPath.section], with: .automatic)
                    
                    let alertSuccess = UIAlertController(title: "Success", message: "Step Deleted Successfully!", preferredStyle: .alert)
                    alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertSuccess, animated: true, completion: nil)
                }
                ))
                
                present(alert, animated: true, completion: nil)
                
                return
            }
            
            // Section Ingredients
            let alert = UIAlertController(title: "Confirmation", message: "Sure to delete this ingredient?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Delete the row from the data source
                
                self.ingredients.remove(at: indexPath.row)
                tableView.reloadSections([indexPath.section], with: .automatic)
                
                let alertSuccess = UIAlertController(title: "Success", message: "Ingredient Deleted Successfully!", preferredStyle: .alert)
                alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertSuccess, animated: true, completion: nil)
            }
            ))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_INGREDIENTS {
            return "Ingredients"
        }
        
        return "Instructions"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SECTION_INGREDIENTS {
            return "Total Ingredients: \(ingredients.count)"
        }
        
        return "Total Instructions: \(steps.count)"
    }
    
    //for dismiss keyboard. reference:tutorial
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
