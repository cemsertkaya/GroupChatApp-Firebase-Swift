//
//  ViewController.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 3.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate
{
    var keybordSize = Int()
    @IBOutlet var mailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    var firstResponder: UIView? /// To handle textField position when keyboard is visible.
    var isKeyboardVisible = false /// You can handle tap on view by checking if keyboard is visible.
    let firestoreDatabase = Firestore.firestore()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Password Security
        passwordField.isSecureTextEntry = true
        //Keyboard Settings
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
    
        mailField.delegate = self;passwordField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
    @objc func keyboardWillShow(notification: NSNotification)
    {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            let keyboardHeight : Int = Int(keyboardSize.height)
            self.keybordSize = keyboardHeight
        }

    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -110, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -110, up: false)
    }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func forgetPasswordButton(_ sender: Any) {alertWithTF()}
    func alertWithTF()
    {
        //Step : 1
        let alert = UIAlertController(title: "Hemen Şifrenizi Sıfırlayalım", message: "Lütfen şifresini sıfırlamak istediğiniz hesaba kayıtlı e-postayı giriniz", preferredStyle: UIAlertController.Style.alert )
        let attributedStringTitle = NSAttributedString(string: "Hemen Şifrenizi Sıfırlayalım", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.white])
        let attributedStringMessage = NSAttributedString(string: "Lütfen şifresini sıfırlamak istediğiniz hesaba kayıtlı e-postayı giriniz", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.white])
        alert.setValue(attributedStringTitle, forKey: "attributedTitle")
        alert.setValue(attributedStringMessage, forKey: "attributedMessage")
        // Accessing alert view backgroundColor :
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor  =  UIColor(rgb: 0xBF0505)
        // Accessing buttons tintcolor :
        alert.view.tintColor = UIColor.white
        //Step : 2
        let save = UIAlertAction(title: "Sıfırla", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                Auth.auth().sendPasswordReset(withEmail: textField.text!) { error in
                    DispatchQueue.main.async{
                        if error != nil {}
                        else {print("success")}
                    }
                }
            }
            else {print("TF 1 is Empty...")}
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Lütfen e-postanızı giriniz"
            textField.textColor = .black
        }
        alert.addAction(save)
        //Cancel action
        let cancel = UIAlertAction(title: "Geri Dön", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
    }
    
    @IBAction func loginButtonPress(_ sender: Any)
    {
        if mailField.text != "" && passwordField.text != "" //if email and password is not empty
            {
                Auth.auth().signIn(withEmail: mailField.text!, password: passwordField.text!)//Firebase signIn methods
                { (authData, error) in
                    if error != nil{self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")}
                    else
                    {
                        let user = Auth.auth().currentUser
                        if !Auth.auth().currentUser!.isEmailVerified
                        {
                            user!.sendEmailVerification { (error) in}
                            self.performSegue(withIdentifier: "toVerifFromSignIn", sender: nil)
                        }
                        else
                        {
                            self.firestoreDatabase.collection("Passwords").document(user!.uid).updateData(["password":self.passwordField.text])
                            self.performSegue(withIdentifier: "toMain1", sender: nil)
                        }
                    }
                }
            }
            else
            {
                makeAlert(titleInput: "Hata", messageInput: "Lütfen e-posta ve şifrenizini tam olarak giriniz")
            }
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    
    @objc func hideKeybord(){view.endEditing(true)}//Closing the keybord

}
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
