//
//  FirstViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/05/03.
//

import UIKit

class FirstViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 初回起動なら利用規約に同意してもらう
        if true {
            performSegue(withIdentifier: "toTermsOfServiceView", sender: nil)
        } else {
            // ログインしていない場合はLoginViewへ
            if appDelegate.currentUser != nil {
                print("Already logged in.")
                performSegue(withIdentifier: "toMapView", sender: nil)
            } else {
                print("not logged in")
                performSegue(withIdentifier: "toLoginView", sender: nil)
            }
        }
    }
    
    func isFirstLaunch() -> Bool {
        // isFirstLaunchが存在するか
        if UserDefaults.standard.object(forKey: "isFirstLaunch") != nil {
            // 存在する場合
            // 初回起動ではない
            return false
        } else {
            // 存在しない場合
            // 初回起動なので値をセット
            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
            return true
        }
    }
}
