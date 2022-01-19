//
//  addNewPinViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/18.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import CoreLocation
import MapKit

class addNewPinViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet weak var noteTextViewPlaceholder: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate設定
        priceTextField.delegate = self
        noteTextView.delegate = self
        
        // Doneボタン追加
        self.addDoneButton()
        
        // キーボードを表示したときにViewもあげるように
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // キーボードを閉じたらViewを戻す
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // マップの位置決定
        self.setMapCenter(coordinate)
        
        // 住所ラベル設定
        self.setAddressLabel()
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
    
    
    @IBAction func postButton() {
        // 未入力項目を確認
        if priceTextField.text == "" {
            let alert = UIAlertController(title: "未入力項目があります", message: "価格を入力してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if Ex.checkRestrictionWord(noteTextView.text) {
            // 不適切な単語が含まれる場合
            let alert = UIAlertController(title: "不適切な表現が含まれています", message: "他のユーザーに不快感を与える表現、投稿に関係のない表現はご遠慮ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // FireStoreへ登録
            postNewPin(coordinate: coordinate, price: Int(priceTextField.text!)!, note: noteTextView.text ?? "")
        }
    }
    
    @IBAction func dismissButton() {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: 新規投稿
extension addNewPinViewController {
    func postNewPin(coordinate: CLLocationCoordinate2D, price: Int, note: String) {
        // ログイン確認
        guard let user = Auth.auth().currentUser else {
            // エラー
            let alert = UIAlertController(title: "ログインしていません", message: "投稿するには設定画面からログインしてください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Firestoreに追加
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("pins").addDocument(data: [
            "coordinate": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "price": price,
            "note": note,
            "createdAt": FieldValue.serverTimestamp(),
            "userId": user.uid
        ]) { error in
            if let err = error {
                // エラー
                print("Error adding document: \(err)")
                let alert = UIAlertController(title: "エラーが発生しました", message: "ネットワーク接続や、アプリの更新が来ていないかを確認してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // 投稿成功
                print("Document added with ID: \(ref!.documentID)")
                // ログを保存
                DB.loggingToFirestore(docId: ref!.documentID, type: 0)
                // 前の画面に戻る
                self.dismiss(animated: true, completion: nil)
                // Annotationを更新
                let navVC = self.presentingViewController as! UINavigationController
                let parentVC = navVC.viewControllers.first as! MapViewController
                parentVC.refreshAnnotations()
            }
        }
    }
}
// MARK: 住所を表示（非同期）
extension addNewPinViewController {
    // 住所を表示
    func setAddressLabel() {
        var address = ""
        
        let setAddressLabelQueue = DispatchQueue(
            label: "setAddressLabelQueue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem
            )
        
        setAddressLabelQueue.async {
            let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            
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
                    self.addressLabel.text = address
                } else {
                    self.addressLabel.text = "住所が見つかりませんでした…"
                }
            })
        }
    }
}

// MARK: textField関連
extension addNewPinViewController: UITextFieldDelegate {
    // 文字が入力されたとき
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // priceTextFieldで数字以外が入力された場合はリジェクトする
        if textField == priceTextField {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

// MARK: textView関連
extension addNewPinViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            // placeholder設置
            noteTextViewPlaceholder.isHidden = false
        } else {
            // placeholder削除
            noteTextViewPlaceholder.isHidden = true
        }
    }
}


// MARK: Keyboard Function
extension addNewPinViewController {
    
    // Doneボタンを追加
    private func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        toolBar.items = [spacer, doneButton]
        
        self.priceTextField.inputAccessoryView = toolBar
        self.noteTextView.inputAccessoryView = toolBar
    }
    @objc func doneButtonTapped() {
        self.view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    // キーボードが出たら、キーボード分Viewの位置をあげる
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 2
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height / 2
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    // キーボードが閉じたらViewを戻す
    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
