//
//  CreateChatViewController.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 6.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase
class CreateChatViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate
{
    let user = Auth.auth().currentUser
    @IBOutlet var chatTitle: UITextField!
    @IBOutlet var numberOfPerson: UITextField!
    var chatTime = String()
    @IBOutlet var twelveHour: UIButton!
    @IBOutlet var twentyFourHour: UIButton!
    let numberOfPersonOptions = [5,10,15,20,25,30,35,40,45,50]
    var isPremium = false;let numberPicker = UIPickerView();var chosenId = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        twelveHour.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        twelveHour.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        twelveHour.layer.shadowOpacity = 2.0
        twelveHour.layer.shadowRadius = 0.4
        twentyFourHour.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        twentyFourHour.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        twentyFourHour.layer.shadowOpacity = 2.0
        twentyFourHour.layer.shadowRadius = 0.4
        //Keybord
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        numberPicker.delegate = self;numberPicker.dataSource = self;numberOfPerson.inputView  = numberPicker;numberOfPerson.delegate = self//NumberOfPersonPicker
        chatTitle.delegate = self
        getUserData()
                
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    //Keybord
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
    func textFieldDidBeginEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -150, up: true)}
    func textFieldDidEndEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -150, up: false)}
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return true}
    
    
    func getUserData()
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(self.user!.uid).addSnapshotListener
            { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot
                        {
                            self.isPremium = document.get("isPremium") as! Bool
                        }
                    }
            }
    }
    
    @IBAction func startChatButtonClicked(_ sender: Any)
    {
        if chatTitle.text != "" && numberOfPerson.text != "" && chatTime != ""
        {
                let finishTime = Calendar.current.date( byAdding: .hour, value:Int(chatTime)!, to: Date())
                let firestoreDatabase = Firestore.firestore()
                var  firestoreReference : DocumentReference? = nil
                let uuid = UUID().uuidString
                self.chosenId = uuid
                firestoreDatabase.collection("chats").document(uuid).setData([
                        "title":self.chatTitle.text!,
                        "numberOfPerson":Int(self.numberOfPerson.text!),
                        "peopleInChat":[String](),
                        "finishTime":finishTime,
                        "creatorUid":self.user?.uid
                    ])
                firestoreDatabase.collection("users").document(user!.uid).updateData(["activeChat":uuid])
                firestoreDatabase.collection("chats").document(uuid).updateData(["peopleInChat" :FieldValue.arrayUnion([self.user!.uid])])
                self.performSegue(withIdentifier: "toChatFromCreate", sender: self)
                self.dismiss(animated: true, completion: nil)
        }
        else{makeAlert(titleInput: "Ouops!!", messageInput: "Lütfen Tüm Boşlukları Doldur...")}
    }
    
    @IBAction func twelveHourClick(_ sender: Any)
    {
        self.chatTime = "12"
        self.twelveHour.backgroundColor = UIColor.black
        self.twentyFourHour.backgroundColor = UIColor(rgb: 0xBF0505)
    }
    
    @IBAction func twentyfourHourClick(_ sender: Any)
    {
        self.chatTime = "24"
        self.twelveHour.backgroundColor = UIColor(rgb: 0xBF0505)
        self.twentyFourHour.backgroundColor = UIColor.black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toChatFromCreate"
        {
            let destinationVC = segue.destination as! Chatroom
            destinationVC.chosenChatId = self.chosenId
            destinationVC.isFromCreate = true
        }
    }
    
    //Methods for numberofperson picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if numberOfPerson.isFirstResponder{return numberOfPersonOptions.count}
        else {return 0}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if numberOfPerson.isFirstResponder{return String(numberOfPersonOptions[row])}
        else {return nil}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if numberOfPerson.isFirstResponder
        {
            var selectedNumber = numberOfPersonOptions[row]
            numberOfPerson.text = String(selectedNumber)
            view.endEditing(true)
        }
    }
    
    //max-length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

      if(textField == chatTitle){
         let currentText = textField.text! + string
         return currentText.count <= 45
      }
      return true;
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
         let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
         let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
         alert.addAction(okButton)
         self.present(alert, animated:true, completion: nil)
    }
    
    
}
