//
//  FirestoreController.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Firebase

class FirebaseController: NSObject {
    var currentUser: AppUser?
    
    var db: Firestore
    var usersCollection: CollectionReference
    var recipesCollection: CollectionReference
    
    override init() {
        db = Firestore.firestore()
        usersCollection = db.collection("users")
        recipesCollection = db.collection("recipes")
    }
    
    func registerUser(id: String, nickname: String, cookingLevel: String) {
        usersCollection.document(id).setData(["nickname": nickname, "level": cookingLevel, "followings": []])
    }
    
    func retrieveCurrentUser(id: String) {
        usersCollection.document(id).getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    let nickname = document.get("nickname") as? String
                    let level = document.get("level") as? String
                    let followings = document.get("followings") as? [String]
                    
                    self.currentUser = AppUser(id: id, nickname: nickname!, cookingLevel: level!, followings: followings!)
                }
                
                else {
                    self.usersCollection.document(id).setData(["nickname": "Not Set", "level": "Not Set", "followings": []])
                }
            }
        }
    }
}