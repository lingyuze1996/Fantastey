//
//  MyProfileVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        // Log out
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out Error: \(error.localizedDescription)")
            return
        }
        
        // Return back to Login Screen
        let rootNC = view.window?.rootViewController as! UINavigationController
        rootNC.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
