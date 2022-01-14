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
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var SignInWithGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // ユーザーの情報を代入
        self.setUserData()
        
        // SignInボタンの見た目変更
        self.changeAllSignInButtonStyle()
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func signOut() {
        let alert = UIAlertController(title: "サインアウトしますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "サインアウト", style: .default) { (action) in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true, completion: nil)
                    self.self.dismiss(animated: true, completion: nil)
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
        })
        
        present(alert, animated: true)
        
    }

}

// MARK: Set User Data
extension AccountViewController {
    func setUserData() {
        // ログインしているかによって分岐
        if let user = appDelegate.currentUser {
            // 匿名アカウントか
            if !user.isAnonymous {
                // 名前の表示（AppleIDは名前を提供しない場合がある）
                userNameLabel.text = user.displayName ?? "Apple IDでログイン済み"
                // ユーザー画像の表示（AppleIDは画像を提供しないので分岐）
                if user.photoURL != nil {
                    self.setUserImage(user.photoURL!)
                }
            }
        } else {
            userNameLabel.text = "ログインしていません"
        }
    }
    // ユーザー画像の設定
    func setUserImage(_ url: URL) {
        let imageData = try! Data(contentsOf: url)
        userImageView.image = UIImage(data: imageData)
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
