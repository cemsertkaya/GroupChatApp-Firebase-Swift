//
//  BlockingController.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 28.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class BlockingController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var tableView: UITableView!
    let user = Auth.auth().currentUser
    var userArray = [UserBlock]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getData()//snapshot ile data kontrolü
    {

        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(user!.uid).addSnapshotListener { (documentSnapshot, error) in
        if error != nil{print(error?.localizedDescription)}
        else
        {
           
            if  let document = documentSnapshot
            {
                 self.userArray.removeAll(keepingCapacity: false)
                let blockedArray = document.get("blockedArray") as! [String]
                for user in blockedArray
                {
                    let docRef = Firestore.firestore().collection("users").document(user)
                    // Get data
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists
                        {
                            let dataDescription = document.data()
                            let username = document.get("username") as! String
                            let userId = document.get("userId") as! String
                            let userBlock = UserBlock(username: username, userId: userId)
                            self.userArray.append(userBlock)
                            self.tableView.reloadData()
                        }}
                }
            }
        }}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toBlockedUsers", for: indexPath) as! BlockingCell
        cell.username.text  = userArray[indexPath.row].getUsername()
        cell.chosenUserId = userArray[indexPath.row].getUserId()
        return cell
    }
    
    
    
    
}
    
import UIKit
import Firebase
class BlockingCell: UITableViewCell
{
    
   
    @IBOutlet var username: UILabel!
    let user = Auth.auth().currentUser
    let firestoreDatabase = Firestore.firestore()
    var chosenUserId = String()
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
    @IBAction func unblockClick(_ sender: Any)
    {
        if chosenUserId != ""
        {
            firestoreDatabase.collection("users").document(self.user!.uid).updateData(["blockedArray":FieldValue.arrayRemove([self.chosenUserId])])//kullanıcının blockedArray
        }
    }
    
    
    
}
 
import Foundation
class UserBlock
{
    private var username  : String
    private var userId : String

    init(username : String, userId : String)
    {
        self.username = username
        self.userId = userId
    }
    
    func getUsername() -> String {return self.username}
    func getUserId() -> String {return self.userId}
}
