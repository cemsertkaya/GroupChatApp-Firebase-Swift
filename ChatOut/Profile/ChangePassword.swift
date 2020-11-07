//
//  ChangePassword.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 26.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class ChangePassword: UIViewController,UITextFieldDelegate
{
    @IBOutlet var currentPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var newPasswordAgain: UITextField!
    let firestoreDatabase = Firestore.firestore();let user = Auth.auth().currentUser
    var currentPasswordFirebase = String(); var currentEmailFirebase = String()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        newPasswordAgain.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
        getCurrentPassword()
        //Keybord Settings
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        currentPassword.delegate = self;newPassword.delegate = self;newPasswordAgain.delegate = self
    }
    
    func getCurrentPassword()
    {
        let docRef = Firestore.firestore().collection("users").document(user!.uid)
        // Get data
        docRef.getDocument { (document, error) in
            if let document = document, document.exists
            {
                let dataDescription = document.data()
                self.currentEmailFirebase = document.get("email") as! String
                
            }
        }
        let docRef2 = Firestore.firestore().collection("Passwords").document(user!.uid)
        // Get data
        docRef2.getDocument { (document, error) in
            if let document = document, document.exists
            {
                let dataDescription = document.data()
                self.currentPasswordFirebase = document.get("password") as! String

            }
        }
    }
    
    @IBAction func changePasswordButtonClicked(_ sender: Any)
    {
        if self.currentPassword.text != "" && self.newPassword.text != "" && self.newPasswordAgain.text != "" && self.newPassword.text!.count >= 6
        {
            if currentPassword.text == self.currentPasswordFirebase
            {
                if newPassword.text == newPasswordAgain.text
                {
                    var credential: AuthCredential = EmailAuthProvider.credential(withEmail: self.currentEmailFirebase, password: self.currentPasswordFirebase)
                       user?.reauthenticate(with: credential, completion: { (result, error) in
                         if let err = error
                         {
                         }
                         else
                         {
                            self.user?.updatePassword(to: self.newPassword.text!) { error in
                                   if let error = error {print(error)}
                                   else
                                   {
                                    self.firestoreDatabase.collection("Passwords").document(self.user!.uid).updateData(["password":self.newPassword.text])
                                        do
                                        {
                                           try Auth.auth().signOut()
                                           self.performSegue(withIdentifier: "toSignInFromChangePassword", sender: nil)
                                        }
                                        catch{print("error")}
                                   }
                               }
                         }
                      })
                }
                else{makeAlert(titleInput: "Oops", messageInput: "Hata")}
            }
            else{makeAlert(titleInput: "Oops", messageInput: "Mevcut şifrenizi hatalı girdiniz")}
        }
        else
        {
            makeAlert(titleInput: "Oops", messageInput: "Eksik bilgi girdiniz")
        }
        
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -200, up: true)}
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -200, up: false)}
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return true}
    
}
