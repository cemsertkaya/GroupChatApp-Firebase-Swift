//
//  Profile.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 4.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit; import Firebase
class Profile: UIViewController
{
   
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var aboutMeLabel: UITextView!
    @IBOutlet var followedLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var sozlukButton: UIButton!
    
    

    var activeChatId = String()
    let user = Auth.auth().currentUser
    var buttonType = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        sozlukButton.layer.borderWidth = 2
        sozlukButton.layer.borderColor = UIColor(rgb: 0xBF0505).cgColor
        self.photo.isHidden = true
        getData()
    }
    
    func getData()//snapshot ile data kontrolü
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(self.user!.uid).addSnapshotListener
            { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot
                        {
                            let url = URL(string: document.get("photoUri")as! String)
                            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                            self.imageView.image = UIImage(data: data!)
                            self.activeChatId = document.get("activeChat") as! String
                            self.username.text! = document.get("username") as! String
                            self.aboutMeLabel.text! = document.get("aboutMe") as! String
                            if self.aboutMeLabel.text == ""
                            {
                                self.aboutMeLabel.isHidden = true
                                self.photo.isHidden = false
                            }
                            else
                            {
                                self.photo.isHidden = true
                            }
                            self.followersLabel.text! = String((document.get("followers") as! [String]).count)
                            self.followedLabel.text! = String((document.get("followings") as! [String]).count)
                        }
                    }
                        
                    }
          }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {if segue.identifier == "toFollowers"{let destinationVC = segue.destination as! Followers_Following;destinationVC.chosenType = self.buttonType}}
    
    @IBAction func followersButtonClicked(_ sender: Any)
    {
        self.buttonType = "Takipçiler";performSegue(withIdentifier: "toFollowers", sender: nil)
    }
    @IBAction func followingsButtonClicked(_ sender: Any)
    {
        self.buttonType = "Takip Edilenler";performSegue(withIdentifier: "toFollowers", sender: nil)
    }
    
}
