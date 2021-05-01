//
//  DetailViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/16.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit
import CoreLocation

class DetailViewController: UIViewController {
    
    var docId: String!
    
    let db = Firestore.firestore()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latestUpdateLabel: UILabel!
    @IBOutlet weak var foundDateLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var stillThereButton: UIButton!
    @IBOutlet weak var notStillThereButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // docIdからピンの詳細を取得
        db.collection("pins").document(docId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                
                // Map
                let geopoint = data["coordinate"] as! GeoPoint
                self.setMapCenter(CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude)) // Mapの中心点を設定してピンを置く
                
                // 発見日時
                let createdAt = (data["createdAt"] as! Timestamp).dateValue()
                self.foundDateLabel.text = "発見日時: \(Ex.dateToString(createdAt))"
                
                // note
                let note = (data["note"] as? String)!
                if note.isEmpty {
                    self.noteTextView.text = "メモは書かれていません…"
                } else {
                    self.noteTextView.text = note
                }
            } else {
                print("Document does not exist")
            }
        }
        
        // logを取得
        db.collection("pins").document(docId).collection("logs").order(by: "timestamp").limit(to: 1).getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                let data = querySnapshot?.documents[0].data()
                let timestamp = Ex.dateToString((data!["timestamp"] as! Timestamp).dateValue())

                switch data!["type"] as! Int {
                case 0:
                    self.latestUpdateLabel.text = "最近の更新: 発見 \(timestamp)"
                case 1:
                    self.latestUpdateLabel.text = "最近の更新: まだあった！ \(timestamp)"
                case 2:
                    self.latestUpdateLabel.text = "最近の更新: なくなってた… \(timestamp)"
                default:
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toLogView":
            let logNavigationController = segue.destination as! UINavigationController
            let logViewController = logNavigationController.topViewController as! LogViewController
            logViewController.docId = docId
        default:
            break
        }
    }
    
    func setMapCenter(_ coordinate: CLLocationCoordinate2D) {
        // マップの中心点設定
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: coordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        
        // ピンを置く
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
}


// MARK: ログ投稿
extension DetailViewController {
    
    // ログ投稿
    func addLogToFireStore(_ type: Int) {
        db.collection("pins").document(docId).collection("logs").addDocument(data: [
                "type": type,
                "timestamp": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error Adding Document: \(err)")
            } else {
                // success
                self.thanksAlert()
                self.preventRepeat()
            }
        }
    }
    
    // 保存完了アラート
    func thanksAlert() {
        let alert = UIAlertController(title: "報告ありがとうございます！", message: "この自動販売機の情報をログへ保存しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 連打防止（ボタンをグレーアウト）
    func preventRepeat() {
        stillThereButton.isUserInteractionEnabled = false
        stillThereButton.isEnabled = false
        stillThereButton.backgroundColor = .lightGray
        notStillThereButton.isUserInteractionEnabled = false
        notStillThereButton.isEnabled = false
        notStillThereButton.backgroundColor = .lightGray
    }
    
    // まだあった
    @IBAction func stillThere() {
        self.addLogToFireStore(1)
    }
    
    // なくなってた
    @IBAction func notStillThere() {
        self.addLogToFireStore(2)
    }
}
