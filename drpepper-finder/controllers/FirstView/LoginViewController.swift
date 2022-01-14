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
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInBtnStackView: UIStackView!
    @IBOutlet weak var SignInWithGoogleButton: UIButton!
    
    // AppleSignIn用
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appleでログインボタンを設置
        addAppleSignInBtn()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        changeAllSignInButtonStyle()
    }
    
    // MapViewへ遷移
    func performToMapView() {
        self.dismiss(animated: true, completion: nil)
        self.presentingViewController?.performSegue(withIdentifier: "toMapView", sender: nil)
    }
    
    // ログインエラーアラート
    func loginErrorAlert() {
        let alert = UIAlertController(title: "ログインエラー", message: "ログイン時にエラーが発生しました。ネットワーク接続などを確かめてから再度お試しください。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInAsAnonymous() {
        Auth.auth().signInAnonymously() {(authResult, err) in
            if let err = err {
                self.loginErrorAlert()
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

// MARK: AppleIDSignIn
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // お作法
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Appleでログインボタンをタップしたとき
    @objc func handleAuthorizationAppleIDButtonPress() {
        // Nonceの生成
        let nonce = AppleIDSignIn.randomNonceString()
        currentNonce = nonce
        
        // Apple SignInを準備
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        // delegateなどの設定
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        // SignInをリクエスト
        authorizationController.performRequests()
    }
    
    
    // 認証が完了したとき
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // FireBaseでの認証を開始
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Nonceの確認
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            // 認証で取得したトークンの確認
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            // トークンを文字列に変換
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Firebaseの認証情報を定義
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // Firebaseにサインイン
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let err = error {
                    // エラーアラートを表示
                    self.loginErrorAlert()
                    print(err.localizedDescription)
                    return
                }
                // Firebaseへのサインイン完了
                self.performToMapView()
            }
        }
    }
    
    // 認証時にエラーが発生したとき
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // エラーアラートを表示
        loginErrorAlert()
    }
    
    
}



// MARK: SignInButton Style
extension LoginViewController {
    
    func changeAllSignInButtonStyle() {
        self.applySignInButtonStyle(SignInWithGoogleButton)
    }
    
    // Appleでログインボタンを追加
    func addAppleSignInBtn() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.signInBtnStackView.addArrangedSubview(authorizationButton)
    }
    
    func applySignInButtonStyle(_ target: UIButton!) {
        target.layer.cornerRadius = 5
        target.layer.shadowColor = UIColor.gray.cgColor
        target.layer.shadowRadius = 1
        target.layer.shadowOffset = CGSize(width: 0, height: 1)
        target.layer.shadowOpacity = 0.5
    }
}
