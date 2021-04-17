//
//  Extensions.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/16.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// グローバル関数
class Ex {
    // Firestoreにログを保存する。
    class func loggingToFirestore(_ docId: String, _ type: Int) {
        let db = Firestore.firestore()
        db.collection("pins").document(docId).collection("logs").addDocument(data: [
            "type": type,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }
    
    // Date型をString型に変換する
    class func dateToString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        
        return f.string(from: date)
    }
}
