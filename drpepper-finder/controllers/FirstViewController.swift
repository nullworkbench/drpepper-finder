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
