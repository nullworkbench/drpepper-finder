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
    let db = Firestore.firestore()
    
    // docIDから単一のピンを取得する
    class func getPinFromID(docID: String) -> Pin? {
        // 非同期処理用
        let semaphore = DispatchSemaphore(value: 0)
        // pinの値保持用
        var pin: Pin?
        // Firestoreから値の取得
        let docRef = db.collection("pins").document(docID)
        docRef.getDocument {(doc, err) in
            if let doc = doc, doc.exists {
                let data = doc.data()!
                
                // 座標
                let geopoint = data["coordinate"] as! GeoPoint
                // 価格
                let price = data["price"] as! Int
                // 発見日時
                let createdAt = (data["createdAt"] as! Timestamp).dateValue()
                // note
                let note = (data["note"] as? String) ?? "メモは書かれていません…"
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
}
