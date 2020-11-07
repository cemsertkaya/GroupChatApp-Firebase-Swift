//
//  SignUp.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 4.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase
import CropViewController


class SignUp: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate,CropViewControllerDelegate
{

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordAgainField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    private var croppingStyle = CropViewCroppingStyle.circular
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    
    
    override func viewDidLoad()
    {
       super.viewDidLoad()
       //Image Select recognizer
       imageView.isUserInteractionEnabled = true
       let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
       imageView.addGestureRecognizer(imageTapRecognizer)
       //Keybord Settings
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
       view.addGestureRecognizer(tapGesture)
       usernameField.delegate = self;emailField.delegate = self;passwordField.delegate = self;passwordAgainField.delegate = self
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    {
        self.imageView.image = image
    }
    
    func presentCropViewController()
    {
          let image: UIImage = imageView.image! //Load an image
          let cropViewController = CropViewController(image: image)
          cropViewController.delegate = self
          present(cropViewController, animated: true, completion: nil)
    }

    //Methods for picking photo
    @objc func selectImage()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        if croppingStyle == .circular
        {
            if picker.sourceType == .camera
            {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
        }
        else{picker.pushViewController(cropController, animated: true)}
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
            })
        }
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController)
    {
        imageView.image = image
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        if cropViewController.croppingStyle != .circular
        {
            imageView.isHidden = true
        }
        else
        {
            self.imageView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

    
   @IBAction func signUpButtonClicked(_ sender: Any)
   {
    if emailField.text != "" && passwordField.text != "" && passwordAgainField.text != ""  && usernameField.text! != ""
       {
           if passwordField.text == passwordAgainField.text
           {
               Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!)//Authantication
               { (authData, error) in
                 if error != nil
                 {
                     self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")//for alertMessages of Firebase
                 }
                 else
                 {
                   let user = Auth.auth().currentUser
                   let storage = Storage.storage()
                     let storageReference = storage.reference()
                     let mediaFolder = storageReference.child("users")
                     if let data = self.imageView.image?.jpegData(compressionQuality: 0.5)
                       {
                           let uuid = UUID().uuidString
                           let imageReference = mediaFolder.child("\(uuid).jpg")
                           imageReference.putData(data, metadata: nil) { (metadata, error) in
                               if error != nil{self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")}
                               else
                               {
                                   imageReference.downloadURL { (url, error) in
                                       if error == nil
                                       {
                                           let imageUrl = url?.absoluteString
                                           //DATABASE
                                           let firestoreDatabase = Firestore.firestore()
                                           var  firestoreReference : DocumentReference? = nil
                                           firestoreDatabase.collection("users").document(user!.uid).setData([
                                                    "userId":user!.uid,
                                                    "email":self.emailField.text!,
                                                    "username":self.usernameField.text!,
                                                    "photoUri":imageUrl!,
                                                    "isPremium":false,//PREMİUM KONTROLÜ
                                                    "aboutMe":"",//HAKKIMDA ALANI
                                                    "activeChat":"",//KULLANICININ AKTİF OLDUĞU SOHBET
                                                    "lastSearchs":[String](),//EN SON ARANAN 10 KİŞİ
                                                    "followers":[String](),//TAKİPÇİ
                                                    "followings":[String](),//TAKİP EDİLENLER
                                                    "blockedArray":[String](),//KULLANICIN ENGELLEDİKLERİ
                                                    "blockedByArray":[String](),//KULLANICIYI ENGELLEYENLER
                                                    "commentedEntries":[String](),
                                                    "createdEntries":[String]()
                                                ])
                                           firestoreDatabase.collection("Passwords").document(user!.uid).setData(["password":self.passwordField.text])
                                           user!.sendEmailVerification { (error) in}
                                           self.performSegue(withIdentifier: "toVerif", sender: self)
                                       }
                                   }
                               }
                           }
                       }
                 }
               }
           }
               
           else
           {
               makeAlert(titleInput: "Aooo!!", messageInput: "Şifre ve şifre doğrulayıcın aynı olmalı...")
           }
   }
   else{makeAlert(titleInput: "Aooo!!", messageInput: "Lütfen tüm boşlukları doldur...")}
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
       func textFieldDidBeginEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -80, up: true)}
       // Finish Editing The Text Field
       func textFieldDidEndEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -80, up: false)}
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

