//
//  LoginVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 20/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var loginWithGoogleButton: GIDSignInButton!
    var dbController: FirebaseController!
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBAction func unwind(_ sender: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        pwTextField.delegate = self
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        loginWithGoogleButton.colorScheme = .dark
        loginWithGoogleButton.style = .wide
        
        //change navigation bar color - zoe
//        guard navigationController != nil else{return}
//        navigationController!.navigationBar.barTintColor = UIColor.yellow
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = pwTextField.text else {return}
        
        // Sign In with Email
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                let alert = UIAlertController(title: "Login Failed", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.dbController.retrieveCurrentUser(id: result!.user.uid)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.dbController.retrieveCurrentUser(id: user!.uid)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
