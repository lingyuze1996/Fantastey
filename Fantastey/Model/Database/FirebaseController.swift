//
//  FirestoreController.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Firebase

class FirebaseController: NSObject, Database {
    var db: Firestore
    var usersCollection: CollectionReference
    
    override init() {
        db = Firestore.firestore()
        usersCollection = db.collection("users")
    }
    
    func registerUser(id: String, nickname: String, cookingLevel: String) {
        usersCollection.document(id).setData(["nickname": nickname, "level": cookingLevel])
    }
}
