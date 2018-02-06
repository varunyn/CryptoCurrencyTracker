//
//  SettingsViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/8/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var LogoutButton: UIButton!
    
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
            UIApplication.topViewController()?.present(newViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
    
}
