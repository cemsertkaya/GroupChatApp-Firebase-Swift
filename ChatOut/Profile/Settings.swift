//
//  Settings.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 5.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase

class Settings: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any)
    {
        do
        {
           try Auth.auth().signOut()
           self.performSegue(withIdentifier: "toLogout", sender: nil)
        }
        catch
        {
            print("error")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
