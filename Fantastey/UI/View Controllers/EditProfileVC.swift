//
//  EditProfileVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 22/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
    @IBOutlet weak var saveButton: RoundButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelSC: UISegmentedControl!
    
    var newPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.backgroundColor = UIColor.systemTeal
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
        }))
        
        present(alert, animated: true, completion: nil)
    }
    @IBAction func save(_ sender: Any) {
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
