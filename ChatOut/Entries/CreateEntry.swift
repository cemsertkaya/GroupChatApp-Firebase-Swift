//
//  CreateEntry.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 19.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase

class CreateEntry: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var textView: UITextView!
    let user = Auth.auth().currentUser;var username = String();var chosenEntryId = String()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Text View Options
        textView.layer.masksToBounds = true;textView.layer.cornerRadius = 20.0
        textView.layer.borderWidth = 1;textView.layer.borderColor = UIColor(rgb: 0xBF0505).cgColor
        textView.font = UIFont.systemFont(ofSize: 16.0);textView.textColor = UIColor.black
        textView.textAlignment = NSTextAlignment.left;textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.layer.shadowOpacity = 0.5;textView.isEditable = true
        getData()
    }
    
    @IBAction func buttonPressed(_ sender: Any)
    {
        if titleField.text != ""
        {
            let time = Date()
            let firestoreDatabase = Firestore.firestore()
            var  firestoreReference : DocumentReference? = nil
            let uuid = UUID().uuidString
            firestoreDatabase.collection("entries").document(uuid).setData(["title":self.titleField.text!,"time":time,"creatorUid":self.user?.uid])
            if textView.text != ""
            {
                let commentTime = Date()
                let commentUid = UUID().uuidString
                let likesArray = [String]()
                let dislikesArray = [String]()
                firestoreDatabase.collection("entries").document(uuid).collection("comments").document(commentUid).setData([
                    "sender" : self.user?.uid,
                    "time":commentTime,
                    "senderUsername":self.username,
                    "commentMessage":self.textView.text!,
                    "likesArray":likesArray,
                    "dislikesArray":dislikesArray])
            }
            self.chosenEntryId = uuid
            self.performSegue(withIdentifier: "toEntry2", sender: nil)
        }
        else{makeAlert(titleInput: "Hoppa", messageInput: "Lütfen açacağın entry için bir başlık gir")}
    }
    
    func getData()
    {
        let fireStoreDatabase2 = Firestore.firestore()
               fireStoreDatabase2.collection("users").document(self.user!.uid).addSnapshotListener
                   { (documentSnapshot, error) in
                           if error != nil{print(error?.localizedDescription)}
                           else{if  let document = documentSnapshot{self.username = document.get("username") as! String}}
                   }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {if segue.identifier == "toEntry2"{let destinationVC = segue.destination as! Comments; destinationVC.chosenEntryId = self.chosenEntryId}}
    
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
         let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
         let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
         alert.addAction(okButton)
         self.present(alert, animated:true, completion: nil)
    }
}
