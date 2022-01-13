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
    @IBOutlet weak var userIdButton: UIButton!
    
    @IBOutlet weak var stillThereButton: UIButton!
    @IBOutlet weak var notStillThereButton: UIButton!
    
    // 住所保存用
    var addressString = ""
    // ユーザーID保存
    var userId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .default).async {
            // docIdからピンの詳細を取得
            if let pin = DB.getPinFromID(docID: self.docId) {
                DispatchQueue.main.async {
                    // Mapの中心点を設定してピンを置く
                    self.setMapCenter(pin.coordinate)
                    // 住所を設定
                    self.setAddressLabel(pin.coordinate)
                    // 価格
                    self.priceLabel.text = "価格：¥\(String(pin.price))"
                    // 発見日時
                    self.foundDateLabel.text = "発見日時: \(Ex.dateToString(pin.createdAt))"
                    // note
                    self.noteTextView.text = pin.note
                    // usreId（先頭の８文字を切り出して表示）
                    self.userIdButton.setTitle("\(pin.userId.prefix(8))", for: .normal)
                    self.userId = pin.userId
                    // Log
                    self.getRecentLog()
                }
            } else {
                // ピンの取得に失敗
                let alert = UIAlertController(title: "情報の取得に失敗", message: "情報の取得に失敗してしまいました…また後ほどお試しください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // 最新のlogを取得
    func getRecentLog() {
        db.collection("pins").document(docId).collection("logs").order(by: "timestamp", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                if let doc = querySnapshot?.documents[0] {
                    let data = doc.data()
                    let timestamp = Ex.dateToString((data["timestamp"] as! Timestamp).dateValue())
                    
                    switch data["type"] as! Int {
                    case 0:
                        self.latestUpdateLabel.text = "最近の更新: 発見 \(timestamp)"
                    case 1:
                        self.latestUpdateLabel.text = "最近の更新: まだあった！ \(timestamp)"
                    case 2:
                        self.latestUpdateLabel.text = "最近の更新: なくなってた… \(timestamp)"
                    default:
                        break
                    }
                } else {
                    print("Log does not exists.")
                }
            }
        }
    }
    
    // MARK: 画面遷移準備
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
    
    @IBAction func reportBtnTapped(_ sender: Any) {
        reportPin()
    }
    @IBAction func editBtnTapped(_ sender: Any) {
        editPin()
    }
    @IBAction func deleteBtnTapped(_ sender: Any) {
        deletePin()
    }
    @IBAction func userIdBtnTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "ユーザー: \(userIdButton.currentTitle ?? "")", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "ブロック", style: .destructive, handler: {_ in
            // ブロック確認アラート
            let alert = UIAlertController(title: "このユーザーをブロックしますか？", message: "ブロックするとこのユーザーの投稿は表示されなくなります。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ブロック", style: .destructive, handler: {_ in
                // ブロック処理
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
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

// MARK: 編集・削除
extension DetailViewController {
    // 編集メソッド
    func editPin() {
        let alert = UIAlertController(title: "まだ開発中です、！", message: "投稿の編集機能は開発中です。今しばらくお待ちくださいませ！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // 通報メソッド
    func reportPin() {
        let alert = UIAlertController(title: "投稿を通報しますか？", message: "不適切な内容、間違った情報などが含まれる場合は投稿を通報し、削除要請をすることができます。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "通報", style: .destructive, handler: {_ in
            // 削除フォームを送信
            DB.requestPinDelation(docID: self.docId)
            // 感謝アラート
            let thxAlert = UIAlertController(title: "通報ありがとうございました！", message: "通報を受け付けました。", preferredStyle: .alert)
            thxAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                // 詳細モーダルを閉じる
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(thxAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        // alert発火
        present(alert, animated: true, completion: nil)
    }
    // 削除メソッド
    func deletePin() {
        // alertを定義
        let alert = UIAlertController(title: "投稿の削除を要請しますか？", message: "間違えて投稿した場合、不適切な内容が含まれる場合などは投稿の削除を要請することができます。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除を要請", style: .destructive, handler: {_ in
            // 削除フォームを送信
            DB.requestPinDelation(docID: self.docId)
            // 感謝アラート
            let thxAlert = UIAlertController(title: "申請ありがとうございました！", message: "削除申請を受け付けました。", preferredStyle: .alert)
            thxAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                // 詳細モーダルを閉じる
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(thxAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        // alert発火
        present(alert, animated: true, completion: nil)
    }
}
