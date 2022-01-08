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
                // Pinオブジェクトの作成
                let obj = Pin(docID: doc.documentID, geoPoint: geopoint, price: price, createdAt: createdAt, note: note)
                
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
    
}
