//
//  Database.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/07.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class DB {
    enum keys: String {
        case blockList = "blockListArray"
    }
    
    // MARK: 指定された数を上限として全てのピンのAnnotationを取得
    class func getAllAnnotations(limit: Int) -> [CustomAnnotation] {
        let db = Firestore.firestore()
        // 非同期処理のSemaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        // 取得したピンを保存する配列
        var pins: [CustomAnnotation] = []
        
        // print("query will start")
        db.collection("pins").limit(to: limit).getDocuments() { (querySnapshot, err) in
            // print("firestore query started")
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in querySnapshot!.documents {
                    // 座標
                    let geoPoint = doc["coordinate"] as! GeoPoint
                    let coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                    // ユーザーID
                    let userId = doc["userId"] as! String
                    // CustomAnnotation定義
                    let annotation = CustomAnnotation(docID: doc.documentID, coordinate: coordinate, userId: userId)
                    
                    pins.append(annotation)
                }
                semaphore.signal()
            }
        }
        // print("start waiting")
        semaphore.wait()
        // print("pins downloaded")
        return pins
    }
    
    // MARK: docIDから単一のピンを取得する
    class func getPinFromID(docID: String) -> Pin? {
        let db = Firestore.firestore()
        // 非同期処理用
        let semaphore = DispatchSemaphore(value: 0)
        // pinの値保持用
        var pin: Pin?
        // Firestoreから値の取得
        let docRef = db.collection("pins").document(docID)
        docRef.getDocument {(doc, err) in
            if (err != nil) {
                semaphore.signal()
                return
            }
            if let doc = doc, doc.exists {
                let data = doc.data()!
                
                // 座標
                let geopoint = data["coordinate"] as! GeoPoint
                // 価格
                let price = data["price"] as! Int
                // 発見日時
                let createdAt = (data["createdAt"] as! Timestamp).dateValue()
                // note
                let note = (data["note"] as? String) ?? ""
                // uid
                let userId = data["userId"] as! String
                // Pinオブジェクトの作成
                let obj = Pin(docID: doc.documentID, geoPoint: geopoint, price: price, createdAt: createdAt, note: note, userId: userId)
                
                pin = obj
                semaphore.signal()
                return
            } else {
                semaphore.signal()
                return
            }
        }
        // getDocumentが終わるのを待機
        semaphore.wait()
        return pin
    }
    
    
    // MARK: Firestoreからピンの削除を要求する
    class func requestPinDelation(docID: String) {
        // GoogleFormへ投稿
        func postToGoogleForm() {
            let formURL = URL(string: "https://docs.google.com/forms/u/0/d/e/1FAIpQLSex-lV1JXvBdgeck34e3TqJLAbMoDjKeI9F8qitSSID67i2TQ/formResponse")!
            var request = URLRequest(url: formURL)
            let params = "entry.489974167=\(docID)"
            
            request.httpBody = params.data(using: .utf8)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //print((response as! HTTPURLResponse).statusCode)
            }
            task.resume()
        }
        postToGoogleForm()
    }
    
    
    // MARK: Firestoreにログを保存する。
    class func loggingToFirestore(docId: String, type: Int) {
        let db = Firestore.firestore()
        db.collection("pins").document(docId).collection("logs").addDocument(data: [
            "type": type,
            "timestamp": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error logging to Firestore: \(err)")
            } else {
                // success
            }
        }
    }
    
    // MARK: ブロックリストを取得
    class func getBlockList() -> [String] {
        let key = keys.blockList.rawValue
        // ブロックリストの存在確認
        if UserDefaults.standard.object(forKey: key) != nil {
            // 存在している場合
            return UserDefaults.standard.array(forKey: key) as! [String]
        } else {
            // 存在していない場合
            // ブロックリストを作成
            let blockList: [String] = []
            UserDefaults.standard.set(blockList, forKey: key)
            return []
        }
    }
    // MARK: ユーザーをブロック
    class func blockUser(userId: String) {
        let key = keys.blockList.rawValue
        // 現在のブロックリストを取得
        var blockList = self.getBlockList()
        // すでに追加済みでなければユーザーを追加
        if !blockList.contains(userId) {
            blockList.append(userId)
        }
        // ブロックリストを更新
        UserDefaults.standard.set(blockList, forKey: key)
    }
    // MARK: ブロック解除
    class func unblockuser(userId: String) {
        let key = keys.blockList.rawValue
        // 現在のブロックリストを取得
        let blockList = self.getBlockList()
        // 指定したユーザーを配列から除外
        let newBlockList = blockList.filter { $0 != userId }
        // 配列を上書き保存
        UserDefaults.standard.set(newBlockList, forKey: key)
    }
    
}
