//
//  ProfileEdit.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 5.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//


import UIKit; import Firebase;import CropViewController
class ProfileEdit: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate
{
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var aboutMeLabel: UITextView!
    let user =  Auth.auth().currentUser
    private var nextViewNumber = Int()
    private var croppingStyle = CropViewCroppingStyle.circular
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getData()
        //Closing the keybord recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func getData()
    {
           let docRef = Firestore.firestore().collection("users").document(user!.uid)
           // Get data
           docRef.getDocument
            {
               (document, error) in
               if let document = document, document.exists
               {
                   let dataDescription = document.data()
                   let url = URL(string: dataDescription?["photoUri"] as! String)
                   let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                   self.usernameLabel.text! = dataDescription?["username"] as! String
                   self.aboutMeLabel.text! = dataDescription?["aboutMe"] as! String
                   self.imageView.image = UIImage(data: data!)
               }
            }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "backToProfile" {
        let nextView = segue.destination as! CustomTabBar
            nextView.selectedIndex = 2
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        
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
                        firestoreDatabase.collection("users").document(self.user!.uid).updateData(["photoUri":imageUrl!,"aboutMe":self.aboutMeLabel.text!])
                        self.nextViewNumber = 1
                        self.performSegue(withIdentifier: "backToProfile", sender: self)
                    }}
            }
            }
        }
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

    @IBAction func imageChangeButton(_ sender: Any) {selectImage()}
    @objc func hideKeybord(){view.endEditing(true)}//Closing the keybord
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
         let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
         let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
         alert.addAction(okButton)
         self.present(alert, animated:true, completion: nil)
    }
     
    
}
class CustomTabBar: UITabBarController{override func viewDidLoad() {super.viewDidLoad()}}
