//
//  SettingsViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView1: UITableView!
    
    // 項目
    let items = ["アカウント", "ブロックしたユーザー", "利用規約"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView1.delegate = self
        tableView1.dataSource = self
    }
    
    // ビューが消える前
    override func viewWillDisappear(_ animated: Bool) {
        // MapViewのAnnotaionを更新する
        let navVC = self.navigationController!
        let parentVC = navVC.viewControllers.first as! MapViewController
        parentVC.refreshAnnotations()
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = items[indexPath.row]
        return cell!
    }
    
    // セルを選択した時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "toAccountView", sender: nil)
        case 1:
            performSegue(withIdentifier: "toBlockListView", sender: nil)
        case 2:
            performSegue(withIdentifier: "toTermsOfServiceWebView", sender: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
