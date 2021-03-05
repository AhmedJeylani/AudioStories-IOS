//
//  LoginVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: CustomDefaultUITextField!
    @IBOutlet weak var passwordField: CustomDefaultUITextField!
    @IBOutlet weak var loginBtn: CustomDefaultUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.setNavigationBar(sender: self)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        let email = emailField.text
        let password = passwordField.text

        if(emailField.text!.isEmpty || passwordField.text!.isEmpty) {
            Utilities.createAlert(title: "Error", message: "You have an empty field", sender: self)
        } else {
            loginBtn.disable(title: "LOGGING IN...")
            Auth.auth().signIn(withEmail: email!, password: password!) { (AuthResult, Error) in
                if let authResult = AuthResult {
                    
                    if(authResult.user.isEmailVerified == true) {
                        Utilities.getUserDetails(user: authResult.user, navigationController: self.navigationController)
                    } else if (authResult.user.isEmailVerified == false) {
                        Utilities.signOut(auth:  Auth.auth())
                        Utilities.createAlert(title: "Error", message: "Your email isn't verified", sender: self)
                        self.loginBtn.enable(title: "LOGIN")
                    }
                } else if let error = Error {
                    ErrorAlert.noUserAvailable(error: error, displayMessage: "Please register and try login", sender: self)
                    self.loginBtn.enable(title: "LOGIN")
                }
            }
        }
    }
    
    @IBAction func forgottenPasswordPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toForgottenPasswordSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForgottenPasswordSegue" {
            if let forgottenPasswordVC = segue.destination as? ForgottenPasswordVC {
                if let email = emailField.text {
                    forgottenPasswordVC.email = email
                }
            }
        }
    }
    
    //This sets the status color white
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
}
