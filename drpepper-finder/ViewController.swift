//
//  ViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    
    var authStateHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // FirebaseAuthの認証状態をリッスン
        authStateHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // FirebaseAuthの認証状態のリッスンを解除
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }


}

