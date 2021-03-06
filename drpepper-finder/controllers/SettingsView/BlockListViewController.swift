//
//  BlockListViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/13.
//

import UIKit

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var blockList = DB.getBlockList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // 編集ボタンの設置
        navigationItem.rightBarButtonItem = editButtonItem
    }

}


// MARK: tableView
extension BlockListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: セルのスタイル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = blockList[indexPath.row]
        return cell
    }
    // MARK: セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blockList.count == 0 {
            let alert = UIAlertController(title: "ブロック中のユーザーはいません。", message: "ブロックしたユーザーはここに表示されます。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
        
        return blockList.count
    }
    
    // MARK: セルを選択したとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: tableView全体の更新
    func refreshTableView() {
        blockList = DB.getBlockList()
        // アニメーション付きでtableViewを更新
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    // MARK: スワイプアクション
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // MARK: 解除ボタン
        let unblockAction = UIContextualAction(style: .destructive, title: "ブロック解除", handler: {(action, view, completionHandler) in
            // 削除処理
            DB.unblockuser(userId: self.blockList[indexPath.row])
            // tableViewを更新
            self.refreshTableView()
            // お作法
            completionHandler(true)
        })
        
        // スワイプアクションたちをreturn
        return UISwipeActionsConfiguration(actions: [unblockAction])
    }
    
    // MARK: 編集モード
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
}
