//
//  BlockListViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/13.
//

import UIKit

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let blockList = DB.getBlockList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
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
        return blockList.count
    }
}
