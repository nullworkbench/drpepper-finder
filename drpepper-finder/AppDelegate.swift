//
//  AppDelegate.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FirebaseFirestoreSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    
    // FirebaseAuthの認証状態を保持する変数
    var authStateHandle: AuthStateDidChangeListenerHandle?
    // FirebaseAuthの認証済みユーザー
    var currentUser: User? = nil


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase Config
        FirebaseApp.configure()
        
        // FirebaseAuth Config
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // 認証状態のリッスンを開始するため
        self.applicationWillEnterForeground(application)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let err = error {
                // 失敗
                print(err)
            } else {
                // 成功
                print(authResult?.additionalUserInfo?.profile!)
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // FirebaseAuthの認証状態をリッスン
        authStateHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            
            if let authedUser = user {
                print("Logged in as \(authedUser.displayName!)")
                
                self.currentUser = authedUser
            } else {
                print("Logged out.")
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // FirebaseAuthの認証状態のリッスンを解除
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }


}

