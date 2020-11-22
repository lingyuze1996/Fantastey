//
//  EditProfileVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 22/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var saveButton: RoundButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelSC: UISegmentedControl!
    @IBOutlet weak var emailLabel: UILabel!
    
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        saveButton.backgroundColor = UIColor.systemTeal
        
        emailLabel.text = Auth.auth().currentUser!.email
        
        nameTextField.text = dbController.currentUser?.nickname
        levelSC.selectedSegmentTintColor = UIColor.systemGreen
        levelSC.selectedSegmentIndex = 1
        
        if dbController.currentUser?.cookingLevel == "Advanced" {
            levelSC.selectedSegmentIndex = 2
        } else if dbController.currentUser?.cookingLevel == "Beginner" {
            levelSC.selectedSegmentIndex = 0
        }
        
        //to beautify the background - zoe
        view.backgroundColor = UIColor(patternImage:UIImage(named:"fantasteyBackground.png")!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        
        alert.textFields![0].textContentType = .newPassword
        alert.textFields![1].textContentType = .newPassword
        alert.textFields![0].isSecureTextEntry = true
        alert.textFields![1].isSecureTextEntry = true
        alert.textFields![0].placeholder = "Please Enter New Password"
        alert.textFields![1].placeholder = "Please Enter New Password Again"
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            // Validation For Password
            
            guard let pw1 = alert.textFields![0].text, let pw2 = alert.textFields![1].text, pw1.count >= 6, pw2.count >= 6 else {
                let alertError = UIAlertController(title: "Error", message: "Password Length must be at least 6!", preferredStyle: .alert)
                alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertError, animated: true, completion: nil)
                return
            }
            
            guard pw1 == pw2 else {
                let alertError = UIAlertController(title: "Error", message: "Password Not Match!", preferredStyle: .alert)
                alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertError, animated: true, completion: nil)
                return
            }
            
            // Update Password
            Auth.auth().currentUser!.updatePassword(to: pw1) { (error) in
                if let err = error {
                    let alertError = UIAlertController(title: "Error", message: "\(err.localizedDescription)", preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertError, animated: true, completion: nil)
                    return
                }
                
                let alertSuccess = UIAlertController(title: "Success", message: "Password Updated!", preferredStyle: .alert)
                alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertSuccess, animated: true, completion: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Save Information
    @IBAction func save(_ sender: Any) {
        guard validateEntries() else {
            return
        }
        
        let nickname = nameTextField.text!
        let level = levelSC.titleForSegment(at: levelSC.selectedSegmentIndex)!
        let uid = Auth.auth().currentUser!.uid
        
        dbController.usersCollection.document(uid).updateData(["level" : level, "nickname": nickname])
        
        let alert = UIAlertController(title: "Success", message: "Information Saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // Validation for user inputs
    private func validateEntries() -> Bool {
        var msg = ""
        
        if nameTextField.text!.count == 0 {
            msg += "- Preferred Name is Empty!\n"
        }
        
        if levelSC.selectedSegmentIndex == -1 {
            msg += "Cooking Level Not Selected!"
        }
        
        if msg.count == 0 {
            return true
        }
        
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        return false
    }

}
