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
import NotificationBannerSwift


class ViewController: UIViewController, GIDSignInUIDelegate {
    
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
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        if UserNameField.text != nil {
            let email = UserTextField.text
            Auth.auth().sendPasswordReset(withEmail: email!) { error in
                if error != nil {
                    self.displayAlert(title: "Error", message: "\(error.debugDescription)")
                } else {
                    self.displayAlert(title: "Email sent", message: "Please check your email")
                }
            }
        }
    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        if UserTextField.text == "" || PasswordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both a email and password")
        } else {
            if let email = UserTextField.text{
                if let password = PasswordTextField.text{
        // SIGN UP
                    if signUpMode {
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
                                    .setValue(self.UserNameField.text)
                                
                                Database.database().reference().child("users")
                                    .child(userkey)
                                    .child("email")
                                    .setValue(self.UserTextField.text)
                                
                                Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                                print("Sign up success")
                                self.displayAlert(title: "Please Verify Email.", message: "We have sent you mail please verify it.")
//                                self.performSegue(withIdentifier: "segue1", sender: nil)
                                self.LoginButton.setTitle("Log In", for: .normal)
                                self.SignUpButton.setTitle("Sign Up", for: .normal)
                                self.signUpMode  = false
                                self.UserNameField.isHidden = true
                            }
                        })
                    } else{
                        
        //LOGIN
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if let user = Auth.auth().currentUser {
                                if !user.isEmailVerified{
                                    let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email?", preferredStyle: .alert)
                                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                                        (_) in
                                        user.sendEmailVerification(completion: nil)
                                    }
                                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                    alertVC.addAction(alertActionOkay)
                                    alertVC.addAction(alertActionCancel)
                                    self.displayAlert(title: "Please Verify Email.", message: "Your Email Id has not been verified.")
                                } else if error != nil {
                                    self.displayAlert(title: "Error", message: error!.localizedDescription)
                                } else {
                                    self.performSegue(withIdentifier: "segue1", sender: nil)
                                }
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

    func showLoginScreen() {
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "AllPageController") as? UITabBarController
        DispatchQueue.main.async {
            self.present(mapViewControllerObj!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signInSilently()
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance().delegate = self
        
//        if Auth.auth().currentUser != nil {
//            print(Auth.auth().currentUser as Any)
//            showLoginScreen()
//        }
        
        Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            if user != nil {
                self?.showLoginScreen()
                print(user)
            }
        }
        
//        if let alreadySignedIn = Auth.auth().currentUser {
//            print(alreadySignedIn)
//             showLoginScreen()
//        }
//
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


