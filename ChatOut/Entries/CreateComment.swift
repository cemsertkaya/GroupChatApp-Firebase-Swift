//
//  CreateComment.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 29.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class CreateComment: UIViewController
{

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextView!
    var chosenEntryId = String()
    var username = String()
    let user = Auth.auth().currentUser
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getChatTitle()
        //Text View Options
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 2;textField.layer.cornerRadius = 20.0
        textField.layer.borderColor = UIColor(rgb: 0xBF0505).cgColor
        textField.font = UIFont.systemFont(ofSize: 15.0);
        textField.textColor = UIColor.black
        textField.textAlignment = NSTextAlignment.left;textField.dataDetectorTypes = UIDataDetectorTypes.all
        textField.layer.shadowOpacity = 0.5;textField.isEditable = true
    }
    @IBAction func sendCommentButton(_ sender: Any)
    {
        if textField.text != ""
        {
            let uuid  = UUID().uuidString
            let time = Date()
            Firestore.firestore().collection("entries").document(self.chosenEntryId).collection("comments").document(uuid).setData(
                ["sender" : self.user?.uid,
                 "time":time,
                 "senderUsername":self.username,
                 "commentMessage":textField.text!,
                 "dislikesArray":[String](),
                 "likesArray":[String]()])
            Firestore.firestore().collection("users").document(self.user!.uid).updateData(["commentedEntries" :FieldValue.arrayUnion([self.user!.uid])])
        }
        else{makeAlert(titleInput: "Oops!!", messageInput: "Yorum kısmı boş kalamaz")}
        
    }
    
    func getChatTitle()
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("entries").document(self.chosenEntryId).addSnapshotListener { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot
                        {
                            self.titleLabel.text = document.get("title") as! String
                        }
                        
            }}
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
         let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
         let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
         alert.addAction(okButton)
         self.present(alert, animated:true, completion: nil)
    }
    
}
