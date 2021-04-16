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

class Ex {
    class func loggingToFirestore(_ docId: String, _ type: Int) {
        let db = Firestore.firestore()
        db.collection("pins").document(docId).collection("logs").addDocument(data: [
            "type": type,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }
}
