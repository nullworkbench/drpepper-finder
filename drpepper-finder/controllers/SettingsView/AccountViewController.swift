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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ログイン状況によってボタンの表示を切り替え
        if let currentUser = Auth.auth().currentUser{
            if !currentUser.isAnonymous {
                // ログイン済み
                loginButton.isHidden = true
            } else {
                // 匿名アカウントでログイン済み
                logoutButton.isHidden = true
            }
        } else {
            // 未ログイン
            logoutButton.isHidden = true
        }
        
        // ユーザーの情報を代入
        self.setUserData()
    }
    
    @IBAction func logout() {
        let alert = UIAlertController(title: "ログアウトしますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "ログアウト", style: .default) { (action) in
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
            // 使用しているアカウントサービスによって分岐
            if let providerID = user.providerData.first?.providerID {
                switch providerID {
                case "google.com":
                    userNameLabel.text = user.displayName ?? "Googleでログイン済み"
                    if user.photoURL != nil {
                        self.setUserImage(user.photoURL!)
                    }
                    return
                case "apple.com":
                    userNameLabel.text = user.displayName ?? "Appleでログイン済み"
                    if user.photoURL != nil {
                        self.setUserImage(user.photoURL!)
                    }
                    return
                default:
                    userNameLabel.text = "ログインしていません"
                    return
                }
            } else {
                userNameLabel.text = "ログインしていません"
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
