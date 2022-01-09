//
//  TermsOfServiceWebViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/09.
//

import UIKit
import WebKit

class TermsOfServiceWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ページの読み込み
        guard let url = URL(string: "https://nullworkbench.com/termsOfService") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    

    
    // webViewを閉じる
    @IBAction func closeWebView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
