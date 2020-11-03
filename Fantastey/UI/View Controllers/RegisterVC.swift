//
//  RegisterVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 22/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField1: UITextField!
    @IBOutlet weak var pwTextField2: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cookingLevelSC: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func Register(_ sender: Any) {
        
        // Validate user inputs
        guard validateEntries() else { return }
        
        // Sign up
        Auth.auth().createUser(withEmail: emailTextField.text!, password: pwTextField1.text!) { (result, error) in
            
            // Sign Up Error
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Sign up Success
            let alert = UIAlertController(title: "Success", message: "Congratulations!\nYour new account is ready.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    private func validateEntries() -> Bool {
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
