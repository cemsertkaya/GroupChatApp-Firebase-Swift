//
//  EmailVerificationViewController.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 24.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase

class EmailVerificationViewController: UIViewController {
    var verificationTimer : Timer = Timer()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);
        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(EmailVerificationViewController.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
    }
    
    @objc func checkIfTheEmailIsVerified()
    {
        Auth.auth().currentUser?.reload(completion: { (err) in
            if err == nil{

                if Auth.auth().currentUser!.isEmailVerified{
                    self.performSegue(withIdentifier: "toMainfromVerify", sender: nil)
                    
                }
                else
                {
                    print("It aint verified yet")
                }
            } else {print(err?.localizedDescription)
            }
        })

    }
    
    func sendVerificationMail(){Auth.auth().currentUser?.sendEmailVerification { (error) in}}
    
    @IBAction func sendAgain(_ sender: Any){sendVerificationMail()}
    
    @IBAction func deleteUser(_ sender: Any)
    {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.verificationTimer.invalidate()
    }
    
    

}
