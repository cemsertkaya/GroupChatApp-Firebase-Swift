//
//  Followers&Following.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 11.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class Followers_Following: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate
{
    let user = Auth.auth().currentUser
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var idArray = [String]()
    var userArray  = [User]()
    var searchUserArray = [User]()
    var searchActive = false
    var chosenType = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Delegates and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //Cell Register
        let nib2 = UINib(nibName: "SearchUser", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "searchUser" )
        
        if chosenType == "Takipçiler"  {getFollowers()}
        else if chosenType == "Takip Edilenler" {getFollowings()}
        else {print("Error!!")}
    }
    
    
    
    func getFollowers()
    {
       let docRef = Firestore.firestore().collection("users").document(user!.uid)
       // Get data
       docRef.getDocument { (document, error) in
           if let document = document, document.exists {
               let dataDescription = document.data()
               self.idArray = dataDescription?["followers"] as! [String]
               for userIds in self.idArray
               {
                   let docRef = Firestore.firestore().collection("users").document(userIds)
                   docRef.getDocument { (document, error) in
                   if let document = document, document.exists {
                       let username = document.get("username") as! String
                       let photoUri = document.get("photoUri") as! String
                       let userId = document.get("userId") as! String
                       let user = User(username: username, userPhoto: photoUri, userId: userId)
                       self.userArray.append(user)
                       self.tableView.reloadData()
                   }}
               }
               
           }}
    }
    
    func getFollowings()
    {
          let docRef = Firestore.firestore().collection("users").document(user!.uid)
          // Get data
          docRef.getDocument { (document, error) in
              if let document = document, document.exists {
                  let dataDescription = document.data()
                  self.idArray = dataDescription?["followings"] as! [String]
                  for userIds in self.idArray
                  {
                      let docRef = Firestore.firestore().collection("users").document(userIds)
                      docRef.getDocument { (document, error) in
                      if let document = document, document.exists {
                          let username = document.get("username") as! String
                          let photoUri = document.get("photoUri") as! String
                          let userId = document.get("userId") as! String
                          let user = User(username: username, userPhoto: photoUri, userId: userId)
                          self.userArray.append(user)
                          self.tableView.reloadData()
                      }}
                  }
                  
              }}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchActive {return self.searchUserArray.count}
        else {return self.userArray.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if searchActive
        {
            let userCell = tableView.dequeueReusableCell(withIdentifier: "searchUser", for: indexPath) as! SearchUser
            let url = URL(string:self.searchUserArray[indexPath.row].getUserPhoto() as! String)
            let data = try? Data(contentsOf:url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            userCell.imageCell.image = UIImage(data: data!)
            userCell.usernameCell.text = self.searchUserArray[indexPath.row].getUsername()
            return userCell
        }
        else
        {
            let userCell = tableView.dequeueReusableCell(withIdentifier: "searchUser", for: indexPath) as! SearchUser
            let url = URL(string:self.userArray[indexPath.row].getUserPhoto() as! String)
            let data = try? Data(contentsOf:url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            userCell.imageCell.image = UIImage(data: data!)
            userCell.usernameCell.text = self.userArray[indexPath.row].getUsername()
            return userCell
        }
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty{searchActive = false;self.tableView.reloadData();return}
        else
        {
            searchActive = true
            searchUserArray = userArray.filter{ users in return users.getUsername().lowercased().contains(searchText.lowercased())}
                
        }
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 55}
    


}
