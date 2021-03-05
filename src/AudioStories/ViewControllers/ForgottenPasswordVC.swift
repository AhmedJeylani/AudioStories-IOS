//
//  ForgottenPasswordVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 05/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class ForgottenPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTextField: CustomDefaultUITextField!
    
    var email:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text =  email
    }
    
    @IBAction func sendResetPasswordBtnPressed(_ sender: Any) {
        if let email = emailTextField.text {
            if email.isEmpty {
                Utilities.createAlert(title: "Error", message: "Please fill in the email field", sender: self)
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { (errorResponse) in
                if let error = errorResponse {
                    ErrorAlert.noUserAvailable(error: error, displayMessage: "", sender: self)
                    return
                }
                //TODO: make the following in a method
                let alert = UIAlertController(title: "Info",message: "Password reset email has been sent, please check your junk mail if you cannot find it.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
