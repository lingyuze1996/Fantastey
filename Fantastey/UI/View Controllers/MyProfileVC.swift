//
//  MyProfileVC.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var emailAccountLabel: UILabel!
    @IBOutlet weak var preferredNameLabel: UILabel!
    @IBOutlet weak var cookingLevelLabel: UILabel!
    @IBOutlet weak var followingAuthorsTable: UITableView!
    @IBOutlet weak var aboutUsButton: RoundButton!
    
    var indicator = UIActivityIndicatorView()
    
    var followings = [String]()
    
    var dbController: FirebaseController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = followingAuthorsTable.center
        view.addSubview(indicator)
        
        aboutUsButton.backgroundColor = UIColor.systemTeal
        
        dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
        
        followingAuthorsTable.delegate = self
        followingAuthorsTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        emailAccountLabel.text = Auth.auth().currentUser?.email
        
        
        dbController.usersCollection.document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    let nickname = document.get("nickname") as? String
                    let level = document.get("level") as? String
                    let followings = document.get("followings") as! [String]
                    
                    self.preferredNameLabel.text = nickname
                    self.cookingLevelLabel.text = level
                    self.followings = followings
                    self.followingAuthorsTable.reloadData()
                }
                
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
        }
        
       
            
        
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
        
        let authorId = followings[indexPath.row]
        
        dbController.usersCollection.document(authorId).getDocument { (document, error) in
            if let document = document, document.exists {
                let nickname = document.get("nickname") as? String
                cell.textLabel?.text = nickname
                
                let level = document.get("level") as! String
                cell.detailTextLabel?.text = "Level: \(level)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Following Authors"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let authorId = followings[indexPath.row]
        
        performSegue(withIdentifier: "visitAuthorSegue", sender: authorId)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Confirmation", message: "Stop to follow this author?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // Delete the row from the data source
                
                self.dbController.usersCollection.document(Auth.auth().currentUser!.uid).updateData(["followings": FieldValue.arrayRemove([self.followings[indexPath.row]])])
                
                self.followings.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                let alertSuccess = UIAlertController(title: "Success", message: "Author following cancelled!", preferredStyle: .alert)
                alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertSuccess, animated: true, completion: nil)
            }
            ))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "visitAuthorSegue" {
            let destinationVC = segue.destination as! HomeVC
            destinationVC.authorId = sender as? String
        }
    }

}
