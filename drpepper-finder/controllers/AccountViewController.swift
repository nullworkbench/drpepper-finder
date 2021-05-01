//
//  AccountViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AccountViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var SignInWithGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        userNameLabel.text = appDelegate.currentUser!.displayName
        
        // SignInボタンの見た目変更
        self.changeAllSignInButtonStyle()
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }

}

// MARK: SignInButton Style
extension AccountViewController {
    
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
