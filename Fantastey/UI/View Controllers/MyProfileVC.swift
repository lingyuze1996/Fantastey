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
    @IBOutlet weak var prefferedNameLabel: UILabel!
    @IBOutlet weak var followingAuthorsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAccountLabel.text = Auth.auth().currentUser?.email
        //prefferedNameLabel.text = Auth.auth().currentUser?.displayName
        
        followingAuthorsTable.delegate = self
        followingAuthorsTable.dataSource = self
        followingAuthorsTable.reloadData()
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
    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = followingAuthorsTable.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = "Author"
        cell.detailTextLabel?.text = "Notification: on"
        return cell
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutSegue" {
            _ = segue.destination as! AboutVC
            
        }
    }
    

}
