//
//  MyProfileVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var emailAccountLabel: UILabel!
    @IBOutlet weak var preferredNameLabel: UILabel!
    @IBOutlet weak var cookingLevelLabel: UILabel!
    @IBOutlet weak var followingAuthorsTable: UITableView!
    @IBOutlet weak var aboutUsButton: RoundButton!
    
    var followings = [String]()
    
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutUsButton.backgroundColor = UIColor.systemTeal
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        emailAccountLabel.text = Auth.auth().currentUser?.email
        preferredNameLabel.text = dbController.currentUser?.nickname ?? "Not Set"
        cookingLevelLabel.text = dbController.currentUser?.cookingLevel ?? "Not Set"
        
        if let followings = dbController.currentUser?.followings, followings.count != 0 {
            self.followings = followings
            followingAuthorsTable.reloadData()
        }
        
        followingAuthorsTable.delegate = self
        followingAuthorsTable.dataSource = self
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
        
        let alert = UIAlertController(title: "Success", message: "You have logged out successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootNC.topViewController?.present(alert, animated: true, completion: nil)
    }
    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = followingAuthorsTable.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = "Author"
        cell.detailTextLabel?.text = followings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Following Authors"
    }    

}
