//
//  LoginVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwind(_ sender: UIStoryboardSegue) {}
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = pwTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                let alert = UIAlertController(title: "Login Error", message: "The account or the password might be wrong, please check them again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
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
