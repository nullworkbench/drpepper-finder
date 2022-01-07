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
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var latestUpdateLabel: UILabel!
    @IBOutlet weak var foundDateLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var stillThereButton: UIButton!
    @IBOutlet weak var notStillThereButton: UIButton!
    
    // 住所保存用
    var addressString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // docIdからピンの詳細を取得
        db.collection("pins").document(docId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                
                // Map
                let geopoint = data["coordinate"] as! GeoPoint
                let coordinate = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude)
                self.setMapCenter(coordinate) // Mapの中心点を設定してピンを置く
                self.setAddressLabel(coordinate) // 住所を設定
                
                // 価格
                let price = data["price"] as! Int
                self.priceLabel.text = "価格：¥\(price)"
                
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
        
        // 最新のlogを取得
        db.collection("pins").document(docId).collection("logs").order(by: "timestamp", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
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
    
    // モーダルを閉じるボタン
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}


// MARK: 住所
extension DetailViewController {
    // 住所を表示（非同期）
    func setAddressLabel(_ coordinate: CLLocationCoordinate2D) {
        var address = ""
        
        let setAddressLabelQueue = DispatchQueue(
            label: "setAddressLabelQueue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem
            )
        
        setAddressLabelQueue.async {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let semaphore = DispatchSemaphore(value: 0)
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else { return }
                
                // 都道府県
                if let administractiveArea = placemark.administrativeArea {
                    address += "\(administractiveArea) "
                }
                // 市町村
                if let locality = placemark.locality {
                    address += "\(locality) "
                }
                // 丁目
                if let thoroughfare = placemark.thoroughfare {
                    address += "\(thoroughfare) "
                }
                // 番地
                if let subThoroughfare = placemark.subThoroughfare {
                    address += subThoroughfare
                }
                
                semaphore.signal()
            }
            
            semaphore.wait()
            DispatchQueue.main.async(execute: {
                if address != "" {
                    self.addressLabel.text = "住所：\(address)"
                    // 住所コピー用に保存
                    self.addressString = address
                } else {
                    self.addressLabel.text = "住所：見つかりませんでした…"
                }
            })
        }
    }
    
    // 住所をマップアプリで開く
    @IBAction func openInMap() {
        // actionSheet定義
        let actionSheet = UIAlertController(title: "どのアプリで開きますか？", message: addressString, preferredStyle: .actionSheet)
        
        // Google Mapで開く
        actionSheet.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { action in
            let urlString = "comgooglemaps://?q=\(self.addressString)"
            let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            UIApplication.shared.open(url!)
        }))
        
        // 純正のマップアプリで開く
        actionSheet.addAction(UIAlertAction(title: "マップ", style: .default, handler: { action in
            let urlString = "http://maps.apple.com/?q=\(self.addressString)"
            let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            UIApplication.shared.open(url!)
        }))
        
        // 住所をコピー
        actionSheet.addAction(UIAlertAction(title: "住所をコピー", style: .default, handler: { action in
            // クリップボードにコピー
            UIPasteboard.general.string = self.addressString
        }))
        
        // キャンセルボタン
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        // actionSheet発火
        present(actionSheet, animated: true, completion: nil)
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
