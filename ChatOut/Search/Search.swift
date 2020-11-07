//
//  Search.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 5.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class Search: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate
{
    let user = Auth.auth().currentUser
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var blockedArray = [String](); var blockedByArray = [String]()
    var chatArray = [Chat]();var searchChatArray = [Chat]();var userArray = [User]();var searchUserArray = [User]()
    var searchActive = false;var lastSearchUserArray = [User]();var lastSearchIdArray = [String]()
    var chosenId = String();var activeChat = String();var isPremium = Bool();var username = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getData();getChats();getUsers()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xBF0505)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: UIControl.State.selected)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self;tableView.dataSource = self;searchBar.delegate = self
        let nib = UINib(nibName: "SearchChat", bundle: nil);tableView.register(nib, forCellReuseIdentifier: "searchChat")
        let nib2 = UINib(nibName: "SearchUser", bundle: nil);tableView.register(nib2, forCellReuseIdentifier: "searchUser" )
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                segmentedControl.selectedSegmentIndex = 1
                getChats()
            case UISwipeGestureRecognizer.Direction.left:
                segmentedControl.selectedSegmentIndex = 0
                getData();getUsers()
                default:
                    break
            }
        }
    }
    

    func getData()//snapshot ile data kontrolü
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(self.user!.uid).addSnapshotListener { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        self.lastSearchIdArray.removeAll(keepingCapacity: false)
                        self.lastSearchUserArray.removeAll(keepingCapacity: false)
                        if  let document = documentSnapshot
                        {
                            self.activeChat = document.get("activeChat") as! String
                            self.isPremium = document.get("isPremium") as! Bool
                            self.username = document.get("username") as! String
                            self.blockedArray = document.get("blockedArray") as! [String]
                            self.blockedByArray = document.get("blockedByArray") as! [String]
                            self.lastSearchIdArray = document.get("lastSearchs") as! [String]
                            for userIds in self.lastSearchIdArray
                            {
                                if !self.blockedByArray.contains(userIds) && !self.blockedArray.contains(userIds)
                                {
                                    let docRef = Firestore.firestore().collection("users").document(userIds)
                                    docRef.getDocument { (document, error) in
                                    if let document = document, document.exists
                                    {
                                        let username = document.get("username") as! String
                                        let photoUri = document.get("photoUri") as! String
                                        let userId = document.get("userId") as! String
                                        let user = User(username: username, userPhoto: photoUri, userId: userId)
                                        self.lastSearchUserArray.append(user)
                                        self.tableView.reloadData()
                                        }}
                                }
                            }
                        }
            }
        }
    }
    
    @IBAction func indexChanged(_ sender: Any)
    {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:getChats()
        case 1:getData();getUsers()
        default:
            break
        }
    }
    
    
    
    func getChats()//getting data from firestore
    {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("chats").addSnapshotListener
        {
                (snapshot, error) in
                if error != nil{print(error?.localizedDescription)}
                else
                {
                    if snapshot?.isEmpty != true && snapshot != nil
                    {
                        self.chatArray.removeAll(keepingCapacity: false)
                        for document in snapshot!.documents
                        {
                            let creatorUid = document.get("creatorUid") as! String
                            if !self.blockedByArray.contains(creatorUid) && !self.blockedArray.contains(creatorUid)
                            {
                                let documentId = document.documentID
                                let time = document.get("finishTime") as! Timestamp
                                let numberOfPerson = document.get("numberOfPerson") as! Int
                                let peopleInChatCount = Int((document.get("peopleInChat") as! [String]).count)
                                let title = document.get("title") as! String
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm"
                                let chat = Chat(id: documentId, time: dateFormatter.string(from: (time.dateValue())), numberOfPerson: String(numberOfPerson), currentNumberOfPerson: peopleInChatCount, title:title)
                                self.chatArray.append(chat)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    func getUsers()//En son profiline girilen 10 kişinin gösterilmesi gerek arama yapılmadıkça
    {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("users").addSnapshotListener { (snapshot, error) in
               if error != nil
               {
                   print(error?.localizedDescription)
               }
               else
               {
                   
                    if snapshot?.isEmpty != true && snapshot != nil
                    {
                      self.userArray.removeAll(keepingCapacity: false)
                      for document in snapshot!.documents
                       {
                          let userId = document.documentID
                          if(self.user?.uid != document.documentID) && !self.blockedByArray.contains(userId) && !self.blockedArray.contains(userId)
                          {
                                  let username =  document.get("username") as! String
                                  let photoUri = document.get("photoUri") as! String
                                  let user = User(username: username, userPhoto: photoUri, userId: userId)
                                  self.userArray.append(user)
                          }
                      }
                      self.tableView.reloadData()
                  }
              }}
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
           switch segmentedControl.selectedSegmentIndex
           {
              case 0:
                  if searchActive{return searchChatArray.count}
                  else {return chatArray.count}
              case 1:
                  if searchActive{return searchUserArray.count}
                  else {return lastSearchUserArray.count}
              default:
                  return 0
                  break;
           }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        switch segmentedControl.selectedSegmentIndex
        {
           case 0:
               let chatCell = tableView.dequeueReusableCell(withIdentifier: "searchChat", for: indexPath) as! SearchChat
               if searchActive
               {
                    chatCell.title.text = searchChatArray[indexPath.row].getTitle()
                    chatCell.time.text = searchChatArray[indexPath.row].getTime()
                    chatCell.numberOfPerson.text = String(searchChatArray[indexPath.row].getCurrentNumberOfPerson()) + "/" + searchChatArray[indexPath.row].getNumberOfPerson()
               }
               else
               {
                    chatCell.title.text = self.chatArray[indexPath.row].getTitle()
                    chatCell.time.text = self.chatArray[indexPath.row].getTime()
                    chatCell.numberOfPerson.text = String(self.chatArray[indexPath.row].getCurrentNumberOfPerson()) + "/" + chatArray[indexPath.row].getNumberOfPerson()
               }
               return chatCell
            
           case 1:
               let userCell = tableView.dequeueReusableCell(withIdentifier: "searchUser", for: indexPath) as! SearchUser
               if searchActive
               {
                    let url = URL(string:self.searchUserArray[indexPath.row].getUserPhoto() as! String)
                    let data = try? Data(contentsOf:url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    userCell.imageCell.image = UIImage(data: data!)
                    userCell.usernameCell.text = searchUserArray[indexPath.row].getUsername()
               }
               else
               {
                    let url = URL(string:self.lastSearchUserArray[indexPath.row].getUserPhoto() as! String)
                    let data = NSData(contentsOf: url!)
                    userCell.imageCell.image = UIImage(data: data as! Data)
                    userCell.usernameCell.text = self.lastSearchUserArray[indexPath.row].getUsername()
               }
               return userCell
           default:
                return cell
               break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 55}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch segmentedControl.selectedSegmentIndex
        {
           case 0:
            if self.searchActive{self.chosenId = self.searchChatArray[indexPath.row].getId()}
            else{self.chosenId = self.chatArray[indexPath.row].getId()}
            performSegue(withIdentifier: "toChat2", sender: self)
            Firestore.firestore().collection("users").document(user!.uid).updateData(["activeChat":self.chosenId])
           case 1:
                if searchActive{self.chosenId = self.searchUserArray[indexPath.row].getUserId()}
                else{self.chosenId = self.lastSearchUserArray[indexPath.row].getUserId()}
                if lastSearchIdArray.count < 10 //Son arananlar array inde 10 kişiden az kişi varsa
                {
                    if !self.lastSearchIdArray.contains(self.chosenId) // Aranan kişi zaten bu arrayde DEĞİLSE
                    {Firestore.firestore().collection("users").document(self.user!.uid).updateData(["lastSearchs":FieldValue.arrayUnion([self.chosenId])])}
                }
                else {print("Array in ilk elemanına son arananı koy")}
                performSegue(withIdentifier: "toOtherUserProfile", sender: nil)
           default:
               break;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toChat2"{let destinationVC = segue.destination as! Chatroom; destinationVC.chosenChatId = self.chosenId}
        else if segue.identifier == "toOtherUserProfile"{let destinationVC = segue.destination as! OtherProfile; destinationVC.chosenUserId = self.chosenId}
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty{searchActive = false;self.tableView.reloadData();return}
        else
        {
            searchActive = true
            switch segmentedControl.selectedSegmentIndex
            {
                case 0:searchChatArray = chatArray.filter{ chats in return  chats.getTitle().lowercased().contains(searchText.lowercased())}
                case 1:searchUserArray = userArray.filter{ users in return  users.getUsername().lowercased().contains(searchText.lowercased())}
                default:
                   break
            }
            self.tableView.reloadData()
        }
        
    }
}
