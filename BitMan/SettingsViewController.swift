//
//  SettingsViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/8/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var LogoutButton: UIButton!
    
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        
        self.dismiss(animated: true) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginPage")
            self.present(vc!, animated: true, completion: nil)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
