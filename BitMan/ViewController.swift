//
//  ViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/5/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase


class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var GoogleLogin: GIDSignInButton!
    
    @IBOutlet weak var UserTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var SignUpButton: UIButton!
    
    @IBOutlet weak var haveAccount: UILabel!
    var signUpMode = false
    
    @IBOutlet weak var UserNameField: UITextField!
    
    @IBAction func GoogleLoginTapped(_ sender: Any) {
    }
    
    
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        if UserTextField.text == "" || PasswordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both a email and password")
        } else {
            if let email = UserTextField.text{
                if let password = PasswordTextField.text{
                    
                    if signUpMode {
                        // SIGN UP
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            let ref = Database.database().reference().root
                            
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                ref.child("users").child((user?.uid)!).setValue(email)
                                
                                guard let userkey = Auth.auth().currentUser?.uid else {return}
                                
                                Database.database().reference().child("users")
                                    .child(userkey)
                                    .child("user")
                                    .childByAutoId()
                                    .setValue(self.UserNameField.text)
                                
                                print("Sign up success")
                                self.performSegue(withIdentifier: "segue1", sender: nil)
                            }
                        })
                    } else{
                        
                        
                        //LOGIN
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print("Login success")
                                self.performSegue(withIdentifier: "segue1", sender: nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func SignUpButtonTapped(_ sender: Any) {
        if signUpMode {
            LoginButton.setTitle("Log In", for: .normal)
            SignUpButton.setTitle("Sign Up", for: .normal)
            signUpMode  = false
            UserNameField.isHidden = true
        }
        else {
            UserNameField.isHidden = false
            LoginButton.setTitle("Sign Up", for: .normal)
            SignUpButton.setTitle("Log In", for: .normal)
            signUpMode  = true
            haveAccount.text = "If you already have an account"
        }
    }
    
    
    @IBAction func GoogleSigninButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let authentication = user.authentication {
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential, completion: { (user, error) -> Void in
                if error != nil {
                    print("Problem at signing in with google with error : \(String(describing: error))")
                } else if error == nil {
                    print("user successfully signed in through GOOGLE! uid:\(Auth.auth().currentUser!.uid)")
                    print("signed in")
                    self.performSegue(withIdentifier: "segue1", sender: nil)
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func showLoginScreen() {
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "AllPageController") as? UITabBarController
        DispatchQueue.main.async {
            self.present(mapViewControllerObj!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if Auth.auth().currentUser != nil {
            showLoginScreen()
        }
        
        self.hideKeyboardWhenTappedAround()
        LoginButton.layer.cornerRadius = 15
        
        SignUpButton.layer.cornerRadius = 15
        LoginButton.layer.borderWidth = 1.5
        LoginButton.layer.borderColor = UIColor.orange.cgColor
        
        GoogleLogin.layer.cornerRadius = 15
        GoogleLogin.layer.borderWidth = 1.5
        GoogleLogin.layer.borderColor = UIColor.red.cgColor
        
        UserNameField.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


