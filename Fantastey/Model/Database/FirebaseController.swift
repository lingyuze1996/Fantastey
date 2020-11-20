//
//  FirestoreController.swift
//  Fantastey
//
//  Created by Yuze Ling on 18/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FirebaseController: NSObject {
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var currentUser: AppUser?
    
    var db: Firestore
    var storage: Storage
    var usersCollection: CollectionReference
    var recipesCollection: CollectionReference
    
    var myRecipes = [Recipe]()
    
    override init() {
        db = Firestore.firestore()
        storage = Storage.storage()
        usersCollection = db.collection("users")
        recipesCollection = db.collection("recipes")
        
        super.init()
    }
    
    private func getMyRecipesIndexByID(_ id: String) -> Int? {
        for i in 0 ..< myRecipes.count {
            if myRecipes[i].id == id {
                return i
            }
        }
        
        return nil
    }
    
    func registerUser(id: String, nickname: String, cookingLevel: String) {
        usersCollection.document(id).setData(["nickname": nickname, "level": cookingLevel, "followings": []])
    }
    
    func setUpMyRecipesListener(id: String) {
        recipesCollection.whereField("authorId", isEqualTo: id).addSnapshotListener({ (snapshot, error) in
            if let err = error {
                print(err)
                return
            }
            
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach { (change) in
                    let id = change.document.documentID
                    let title = change.document.get("title") as! String
                    let difficulty = change.document.get("difficulty") as! String
                    let imageURL = change.document.get("imageURL") as! String
                    let steps = change.document.get("steps") as! [String]
                    let ingredients = change.document.get("ingredients") as! [[String: Any]]
                    
                    let recipe = Recipe(id: id, title: title, imageURL: imageURL, difficulty: difficulty)
                    
                    for step in steps {
                        recipe.steps.append(step)
                    }
                    
                    for ingredient in ingredients {
                        let name = ingredient["name"] as! String
                        let value = ingredient["value"] as! Float
                        let unit = ingredient["unit"] as! String
                        
                        recipe.ingredients.append(Ingredient(name: name, value: value, unit: unit))
                    }
                    
                    if change.type == .added {
                        self.myRecipes.append(recipe)
                    } else if change.type == .modified {
                        let index = self.getMyRecipesIndexByID(id)!
                        self.myRecipes[index] = recipe
                    } else {
                        if let index = self.getMyRecipesIndexByID(id) {
                            self.myRecipes.remove(at: index)
                        }
                    }
                }
                
                self.listeners.invoke { (listener) in
                    if listener.listenerType == .myRecipes {
                        listener.onMyRecipesChange(recipes: self.myRecipes)
                    }
                }
                
            }
        })
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
    
    // Upload recipe details to Firestore
    func uploadRecipeDetails(recipe: Recipe) {
        let encoder = JSONEncoder()
        do {
            recipe.setAuthorId(id: currentUser!.id)
            let recipeJSON = try encoder.encode(recipe)
            let recipeDictionary = try JSONSerialization.jsonObject(with: recipeJSON, options: []) as! [String: Any]
            recipesCollection.document().setData(recipeDictionary) { (error) in
                if let err = error {
                    print(err)
                }
                
                print("success")
            }
        } catch let err {
            print(err)
        }
    }
    
    // Upload Recipe Image to Storage
    func uploadRecipeImage(imageURL: String, data: Data) {
        let storageRef = storage.reference().child("images/" + imageURL)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
                return
            }
            
            guard metadata != nil else {
                return
            }
            
            print("success upload")
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .myRecipes {
            listener.onMyRecipesChange(recipes: self.myRecipes)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
