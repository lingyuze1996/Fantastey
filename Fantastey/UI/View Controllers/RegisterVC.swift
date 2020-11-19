//
//  RegisterVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 22/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController,UITextFieldDelegate  {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField1: UITextField!
    @IBOutlet weak var pwTextField2: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cookingLevelSC: UISegmentedControl!
    
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        pwTextField1.delegate = self
        pwTextField2.delegate = self
        nameTextField.delegate = self
        
        //因为我点不动两个password textfield（写着strong password
//        报错：[Assert] View <(null):0x0> does not conform to UITextInput protocol），所以我先disable了这个auto-filling function
        self.hideKeyboardWhenTappedAround()
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    }
    

    @IBAction func Register(_ sender: Any) {
        
        // Validate user inputs
        guard validateEntries() else { return }
        
        // Sign up
        Auth.auth().createUser(withEmail: emailTextField.text!, password: pwTextField1.text!) { (result, error) in
            
            // Sign Up Error
            if let error = error {
//                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                self.popAlertWindow("Error", error.localizedDescription, false)
                return
            }
            
            // Sign up Success
//            let alert = UIAlertController(title: "Success", message: "Congratulations!\nYour new account is ready.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
//                self.navigationController?.popToRootViewController(animated: true)
//            })
//            self.present(alert, animated: true, completion: nil)
            self.popAlertWindow("Success", "Congratulations!\nYour new account is ready.",true)
            
            // Upload cooking level to Firestore
            let id = result!.user.uid
            let nickname = self.nameTextField.text
            let level = self.cookingLevelSC.titleForSegment(at: self.cookingLevelSC.selectedSegmentIndex)!
            self.dbController.registerUser(id: id, nickname: nickname!, cookingLevel: level)
        }
        
        
        
    }
    
    private func validateEntries() -> Bool {
        if emailTextField.text == ""{
            self.popAlertWindow("Error",  "The email account has not provided.", false)
            return false
        }
        if pwTextField1.text != pwTextField2.text {
            self.popAlertWindow("Error",  "Two password inputs do not match, please check again", false)
            return false
        }
        if nameTextField.text == ""{
            self.popAlertWindow("Error",  "Please provide a preffered name.", false)
            return false
        }
        let preferredNameLength = nameTextField.text!.count
        
        if (preferredNameLength > 20)
        {
            self.popAlertWindow("Error",  "The preferred name is now" + String(preferredNameLength) + " characters,which is too long.", false)
            return false
        }
        if cookingLevelSC.selectedSegmentIndex == -1 {
            self.popAlertWindow("Error",  "Please select a Cooking Level.", false)
            return false
        }
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { textField.resignFirstResponder()
        return true
    }
    
    //pop up the alert window
    private func popAlertWindow(_ title:String, _ message:String, _ returnToRootVC:Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if returnToRootVC == true{
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        })}else{
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))}
        self.present(alert, animated: true, completion: nil)
    }
}

//https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
