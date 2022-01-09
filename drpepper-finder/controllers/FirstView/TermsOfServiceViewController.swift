//
//  TermsOfServiceViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/09.
//

import UIKit

class TermsOfServiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 同意しない
    @IBAction func disagreeBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: "サービスの利用には利用規約への同意が必要です。", message: "利用規約にご同意いただけない場合、サービスはご利用いただけません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // 同意する
    @IBAction func agreeBtnTapped(_ sender: Any) {
        // 次回以降は初回起動ではない値をセット
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}
