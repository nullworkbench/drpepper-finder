//
//  LoginViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/05/02.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var SignInWithGoogleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        changeAllSignInButtonStyle()
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInAsAnonymous() {
        
    }

}

// MARK: SignInButton Style
extension LoginViewController {
    
    func changeAllSignInButtonStyle() {
        self.applySignInButtonStyle(SignInWithGoogleButton)
    }
    
    func applySignInButtonStyle(_ target: UIButton!) {
        target.layer.cornerRadius = 5
        target.layer.shadowColor = UIColor.gray.cgColor
        target.layer.shadowRadius = 1
        target.layer.shadowOffset = CGSize(width: 0, height: 1)
        target.layer.shadowOpacity = 0.5
    }
}
