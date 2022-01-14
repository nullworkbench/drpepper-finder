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
    
    // AppleSignIn用
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appleでログインボタンを設置
        addAppleSignInBtn()
        
        // Googleでログインボタンを設置
        addGoogleSignInBtn()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
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
    
    // 匿名アカウントでログイン
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
    // Googleでサインイン
    @objc func signInWithGoogleBtnTapped() {
        GIDSignIn.sharedInstance().signIn()
    }
    
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
        // リクエストする情報
        request.requestedScopes = [.fullName, .email]
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

    // Appleでログインボタンを追加
    func addAppleSignInBtn() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        // コードでAutoLayoutするためのお作法
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        // UIStackViewに追加
        self.signInBtnStackView.insertArrangedSubview(authorizationButton, at: 0)
        // サイズ比率のAutoLayoutを記述
        authorizationButton.widthAnchor.constraint(equalTo: authorizationButton.heightAnchor, multiplier: 11/2).isActive = true
    }
    
    // Googleでログインボタンを追加
    func addGoogleSignInBtn() {
        let button = GIDSignInButton()
        button.style = .wide
        button.addTarget(self, action: #selector(signInWithGoogleBtnTapped), for: .touchUpInside)
        self.signInBtnStackView.insertArrangedSubview(button, at: 0)
    }
}
