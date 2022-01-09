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
        GIDSignIn.sharedInstance()?.delegate = self
        
        changeAllSignInButtonStyle()
    }
    
    func performToMapView() {
        self.dismiss(animated: true, completion: nil)
        self.presentingViewController?.performSegue(withIdentifier: "toMapView", sender: nil)
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInAsAnonymous() {
        Auth.auth().signInAnonymously() {(authResult, err) in
            if let err = err {
                print("Error logging in as Anonymoous: \(err)")
            } else {
                // success
                self.performToMapView()
            }
        }
    }

}

// MARK: GIDSignIn
extension LoginViewController: GIDSignInDelegate {
    // ログインボタンタップ後起動したブラウザの応答を受け取る
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        guard let auth = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credential, completion: {(authResult, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                // ログイン成功
                self.performToMapView()
            }
        })
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
