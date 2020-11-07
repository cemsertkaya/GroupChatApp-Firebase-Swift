//
//  OtherProfile.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 12.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase;import QuartzCore

class OtherProfile: UIViewController
{
    let user = Auth.auth().currentUser
    @IBOutlet var sozlukButton: UIButton!
    @IBOutlet var followButton: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var aboutMeLabel: UITextView!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var followedLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var titleField: UILabel!
    @IBOutlet var numberOfPersonField: UILabel!
    @IBOutlet var numberOfPersonLabel: UILabel!
    @IBOutlet var timeField: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var blockButton: UIBarButtonItem!
    @IBOutlet var photo: UIImageView!
    
    var activeChat = String();var followingsArray = [String]();var followersArray = [String]()
    var otherUserFollowingsArray = [String]();var otherUserFollowersArray = [String]();var userLastSearchs = [String]();var otherUserLastSearchs = [String]()
    var chosenUserId = "";var isPremium = Bool();var isFollowing = Bool();var followButtonType = String();var buttonType = String()
    @IBOutlet var goChatButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        sozlukButton.layer.borderWidth = 2
        sozlukButton.layer.borderColor = UIColor(rgb: 0xBF0505).cgColor
        self.photo.isHidden = true
        getOtherUserData();getCurrentUserData()
    }
    
    func getCurrentUserData()//snapshot ile data kontrolü
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(user!.uid).addSnapshotListener { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot
                        {
                            self.isPremium = document.get("isPremium") as! Bool
                            self.followingsArray = document.get("followings") as! [String]
                            self.followersArray = document.get("followers") as! [String]
                            self.userLastSearchs = document.get("lastSearchs") as! [String]
                            if self.followingsArray.contains(self.chosenUserId){self.followButton.title = "Unfollow"}
                            else{self.followButton.title = "Follow"}
                        }}}
        
    }
    
    func getOtherUserData()
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(self.chosenUserId).addSnapshotListener { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot
                        {
                            let url = URL(string: document.get("photoUri")as! String)
                            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                            self.imageView.image = UIImage(data: data!)
                            self.usernameLabel.text! = document.get("username") as! String
                            self.aboutMeLabel.text! = document.get("aboutMe") as! String
                            self.otherUserFollowersArray = document.get("followers") as! [String]
                            self.otherUserFollowingsArray = document.get("followings") as! [String]
                            self.otherUserLastSearchs = document.get("lastSearchs") as! [String]
                            self.followersLabel.text! = String(self.otherUserFollowersArray.count)
                            self.followedLabel.text! = String(self.otherUserFollowingsArray.count)
                            self.activeChat = document.get("activeChat") as! String
                            if self.aboutMeLabel.text == ""
                            {
                                self.aboutMeLabel.isHidden = true
                                self.photo.isHidden = false
                            }
                            else
                            {
                                self.photo.isHidden = true
                            }
                            if self.activeChat != ""
                            {
                                let docRef = Firestore.firestore().collection("chats").document(self.activeChat)
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists
                                    {
                                            let dataDescription = document.data()
                                            let peopleInChat  = dataDescription?["peopleInChat"] as! [String]
                                            let numberOfPerson = dataDescription?["numberOfPerson"] as! Int
                                            self.numberOfPersonField.text =  String(peopleInChat.count) + "/" + String(numberOfPerson)
                                            self.titleField.text = dataDescription?["title"] as! String
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "HH:mm"
                                            let timestamp = dataDescription?["finishTime"] as! Timestamp
                                            self.timeField.text = dateFormatter.string(from: (timestamp.dateValue()))
                                            if peopleInChat.count == numberOfPerson
                                            {
                                                self.goChatButton.isEnabled = false
                                            }
                                    }
                                }
                            }
                            else
                            {
                                self.goChatButton.isHidden = true
                                self.timeField.isHidden = true
                                self.titleField.isHidden = true
                                self.numberOfPersonField.isHidden = true
                                self.numberOfPersonLabel.isHidden = true
                                self.timeLabel.isHidden = true
                                
                            }
                        }
                }
        }
    }
    @IBAction func goChatButtonClicked(_ sender: Any)
    {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("users").document(self.user!.uid).updateData(["activeChat":self.activeChat])
        firestoreDatabase.collection("chats").document(self.activeChat).updateData(["peopleInChat" :FieldValue.arrayUnion([self.user!.uid])])
        performSegue(withIdentifier: "toChatFromOtherProfile", sender: self)
    }
    
    @IBAction func followButtonClicked(_ sender: Any)
    {
        let fireStoreDatabase = Firestore.firestore()
        if followButton.title == "Follow"
        {
            fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["followings":FieldValue.arrayUnion([self.chosenUserId])])//chatArray e yeni chat i ekledim
            fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["followers":FieldValue.arrayUnion([self.user!.uid])])//chatArray e yeni chat i ekledim
        }
        else
        {
            fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["followings":FieldValue.arrayRemove([self.chosenUserId])])//chatArray e yeni chat i ekledim
            fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["followers":FieldValue.arrayRemove([self.user!.uid])])//chatArray e yeni chat i ekledim
        }
    }
    
    @IBAction func blockButtonClicked(_ sender: Any)
    {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["blockedArray":FieldValue.arrayUnion([self.chosenUserId])])//kullanıcının blockedArray ine ekledik
        fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["blockedByArray":FieldValue.arrayUnion([self.user!.uid])])//diğer kullanıcın blockledBy ine ekledik
        if otherUserFollowingsArray.contains(self.user!.uid)
        {
            fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["followings":FieldValue.arrayRemove([self.user!.uid])])
        }
        if otherUserFollowersArray.contains(self.user!.uid)
        {
            fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["followers":FieldValue.arrayRemove([self.user!.uid])])
        }
        if otherUserLastSearchs.contains(self.user!.uid)
        {
            fireStoreDatabase.collection("users").document(self.chosenUserId).updateData(["lastSearchs":FieldValue.arrayRemove([self.user!.uid])])
        }
        if followingsArray.contains(self.chosenUserId)
        {
            fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["followings":FieldValue.arrayRemove([self.chosenUserId])])
        }
        if followersArray.contains(self.chosenUserId)
        {
            fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["followers":FieldValue.arrayRemove([self.chosenUserId])])
        }
        if userLastSearchs.contains(self.chosenUserId)
        {
            fireStoreDatabase.collection("users").document(self.user!.uid).updateData(["lastSearchs":FieldValue.arrayRemove([self.chosenUserId])])
        }
       
    }
    
    @IBAction func followersButtonClicked(_ sender: Any){self.buttonType = "Takipçiler";performSegue(withIdentifier: "toFollowers", sender: nil)}
    @IBAction func followedButtonClicked(_ sender: Any){self.buttonType = "Takip Edilenler";performSegue(withIdentifier: "toFollowers", sender: nil)}
    
    @IBAction func goEntry(_ sender: Any){performSegue(withIdentifier: "toProfileEntry", sender: nil)}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toFollowers"
        {
            let destinationVC = segue.destination as! Followers_Following
            destinationVC.chosenType = self.buttonType
            
        }
        else if segue.identifier == "toChatFromOtherProfile"
        {
            let destinationVC = segue.destination as! Chatroom
            destinationVC.chosenChatId = self.activeChat
        }
        else if segue.identifier == "toProfileEntry"
        {
            let destinationVC = segue.destination as! ProfileEntries
            destinationVC.chosenUserId = self.chosenUserId
        }
    }
    
    }

