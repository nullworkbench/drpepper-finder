//
//  LogViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/19.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var docId: String!
    
    var logs = [FBLog]()
    
    @IBOutlet var tableView1: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView1.dataSource = self
        tableView1.delegate = self
        
        logs = getAllLogs()
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if logs.count == 0 {
            return 1
        } else {
            return logs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellLabel = cell.contentView.viewWithTag(1) as! UILabel
        
        if logs.count != 0 {
            let timestamp = Ex.dateToString(logs[indexPath.row].timestamp!)
            
            switch logs[indexPath.row].type {
            case 0:
                cellLabel.text = "発見：\(timestamp)"
            case 1:
                cellLabel.text = "まだあった！：\(timestamp)"
            case 2:
                cellLabel.text = "なくなってた…：\(timestamp)"
            default:
                break
            }
        } else {
            cellLabel.text = "ログはありません"
        }

        return cell
    }
    
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension LogViewController {
    // FireStoreからログ一覧を取得
    class FBLog {
        var type: Int!
        var timestamp: Date!
        
        init(_ type: Int, _ timestamp: Date) {
            self.type = type
            self.timestamp = timestamp
        }
    }
    
    func getAllLogs() -> [FBLog] {
        
        let db = Firestore.firestore()
        db.collection("pins").document(docId!).collection("logs").order(by: "timestamp").limit(to: 50).getDocuments {(querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in querySnapshot!.documents {
                    let data = doc.data()
                    let log = FBLog.init(data["type"] as! Int, (data["timestamp"] as! Timestamp).dateValue())
                    self.logs.append(log)
                }
                self.tableView1.reloadData() // FireStore情報取得が遅いためリロード
            }
        }
        
        return logs
    }
}
