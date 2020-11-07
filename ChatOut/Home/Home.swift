//
//  Home.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 5.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class Home: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    let user = Auth.auth().currentUser
    @IBOutlet var addButton: UIBarButtonItem!
    var activeChat = String();var chatArray = [Chat]();var blockedArray = [String](); var blockedByArray = [String]();var followings = [String]()
    var isPremium = false;var chosenId = "";var username = "";var chatFollowingsArray =  [Chat]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedView: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xBF0505)]
        segmentedView.setTitleTextAttributes(titleTextAttributes, for: UIControl.State.selected)
        let nib = UINib(nibName: "SearchChat", bundle: nil);tableView.register(nib, forCellReuseIdentifier: "searchChat")
        tableView.delegate = self;tableView.dataSource = self
        getData();getChats();getFollowingsChats()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                segmentedView.selectedSegmentIndex = 1
                getChats()
            case UISwipeGestureRecognizer.Direction.left:
                segmentedView.selectedSegmentIndex = 0
                getFollowingsChats()
                default:
                    break
            }
        }
    }
    @IBAction func segmentClicked(_ sender: Any)
    {
        switch segmentedView.selectedSegmentIndex
        {
        case 0:getChats()
        case 1:getFollowingsChats()
        default:
            break
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any)
    {
        if activeChat == ""
        {
            performSegue(withIdentifier: "toAdd", sender: nil)
        }
        
        
        
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
                self.isPremium = document.get("isPremium") as! Bool
                self.username = document.get("username") as! String
                self.activeChat = document.get("activeChat") as! String
                self.blockedByArray = document.get("blockedByArray") as! [String]
                self.blockedArray = document.get("blockedArray") as! [String]
                self.followings = document.get("followings") as! [String]
            }
        }
        
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
    
    func getFollowingsChats()//getting data from firestore
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
                         self.chatFollowingsArray.removeAll(keepingCapacity: false)
                         for document in snapshot!.documents
                         {
                            
                            let creatorUid = document.get("creatorUid") as! String
                            if self.followings.contains(creatorUid)
                                 {
                                     let documentId = document.documentID
                                     let time = document.get("finishTime") as! Timestamp
                                     let numberOfPerson = document.get("numberOfPerson") as! Int
                                     let peopleInChatCount = Int((document.get("peopleInChat") as! [String]).count)
                                     let title = document.get("title") as! String
                                     let dateFormatter = DateFormatter()
                                     dateFormatter.dateFormat = "HH:mm"
                                     let chat = Chat(id: documentId, time: dateFormatter.string(from: (time.dateValue())), numberOfPerson: String(numberOfPerson), currentNumberOfPerson: peopleInChatCount, title:title)
                                     self.chatFollowingsArray.append(chat)
                                 }
                                 
                         }
                         self.tableView.reloadData()
                     }
                 }
        }
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)//YENİ BİR CHAT'E KATILMAK
    {
        
        let firestoreDatabase = Firestore.firestore()
        if segmentedView.selectedSegmentIndex == 0
        {
           self.chosenId = self.chatArray[indexPath.row].getId()
        }
        else if segmentedView.selectedSegmentIndex == 1
        {
           self.chosenId = self.chatFollowingsArray[indexPath.row].getId()
        }
        if activeChat == ""
        {
            if self.chatArray[indexPath.row].getCurrentNumberOfPerson() == Int(self.chatArray[indexPath.row].getNumberOfPerson())
            {
                makeAlert(titleInput: "Oops", messageInput: "Maalesef bu sohbette hiç yer yok bekleyebilir ya da başka bir sohbete katılabilirsiniz...")
            }
            else
            {
                firestoreDatabase.collection("users").document(self.user!.uid).updateData(["activeChat":self.chosenId])
                firestoreDatabase.collection("chats").document(self.chosenId).updateData(["peopleInChat" :FieldValue.arrayUnion([self.user!.uid])])
                performSegue(withIdentifier: "toChat", sender: self)
            }
        }
        else if activeChat == self.chosenId
        {
            performSegue(withIdentifier: "toChat", sender: self)
        }
        else
        {
            if self.chatArray[indexPath.row].getCurrentNumberOfPerson() == Int(self.chatArray[indexPath.row].getNumberOfPerson())
            {
                makeAlert(titleInput: "Oops", messageInput: "Maalesef bu sohbette hiç yer yok bekleyebilir ya da başka bir sohbete katılabilirsiniz...")
            }
            else
            {
                let alert = UIAlertController(title: "Oops", message: "Aktif olduğunuz chat'den ayrılıp yeni bir chat'e geçmek isteğinize emin misiniz ?", preferredStyle: UIAlertController.Style.alert )
                let attributedStringTitle = NSAttributedString(string: "Oops", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.white])
                let attributedStringMessage = NSAttributedString(string: "Aktif olduğunuz chat'den ayrılıp yeni bir chat'e geçmek isteğinize emin misiniz ?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.white])
                alert.setValue(attributedStringTitle, forKey: "attributedTitle")
                alert.setValue(attributedStringMessage, forKey: "attributedMessage")
                // Accessing alert view backgroundColor :
                alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor  =  UIColor(rgb: 0xBF0505)
                // Accessing buttons tintcolor :
                alert.view.tintColor = UIColor.white
                //Cancel action
                let cancel = UIAlertAction(title: "Vazgeç", style: .default) { (alertAction) in }
                alert.addAction(cancel)
                //Step : 2
                let out = UIAlertAction(title: "Sohbetten Çık", style: .default) { (alertAction) in
                    let firestoreDatabase = Firestore.firestore()
                    firestoreDatabase.collection("chats").document(self.activeChat).updateData(["peopleInChat" :FieldValue.arrayRemove([self.user!.uid])])
                    firestoreDatabase.collection("chats").document(self.chosenId).updateData(["peopleInChat" :FieldValue.arrayUnion([self.user!.uid])])
                    firestoreDatabase.collection("users").document(self.user!.uid).updateData(["activeChat":self.chosenId])
                    self.performSegue(withIdentifier: "toChat", sender: nil)
                    
                }
                alert.addAction(out)
                self.present(alert, animated:true, completion: nil)
            }
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toChat"
        {
            let destinationVC = segue.destination as! Chatroom
            destinationVC.chosenChatId = self.chosenId
            destinationVC.username = self.username
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch segmentedView.selectedSegmentIndex
        {
        case 0:return chatArray.count
        case 1:return chatFollowingsArray.count
        default:
            return 0
            break
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
          let cell = tableView.dequeueReusableCell(withIdentifier: "searchChat", for: indexPath) as! SearchChat
          if segmentedView.selectedSegmentIndex == 0
          {
            cell.title.text = chatArray[indexPath.row].getTitle()
            cell.time.text = chatArray[indexPath.row].getTime()
            cell.numberOfPerson.text = String(chatArray[indexPath.row].getCurrentNumberOfPerson()) + "/" + chatArray[indexPath.row].getNumberOfPerson()
          }
          else if segmentedView.selectedSegmentIndex == 1
          {
            cell.title.text = chatFollowingsArray[indexPath.row].getTitle()
            cell.time.text = chatFollowingsArray[indexPath.row].getTime()
            cell.numberOfPerson.text = String(chatFollowingsArray[indexPath.row].getCurrentNumberOfPerson()) + "/" + chatFollowingsArray[indexPath.row].getNumberOfPerson()
            
          }
          return cell
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 55}
}
