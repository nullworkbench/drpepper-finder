//
//  Pin.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/07.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class Pin {
    // document ID
    let docID: String!
    // 座標
    let coordinate: CLLocationCoordinate2D!
    // 価格
    let price: Int!
    // 発見日時
    let createdAt: Date!
    // メモ
    let note: String!
    // uid
    let userId: String!
    
    // initialization
    init(docID: String, geoPoint: GeoPoint, price: Int, createdAt: Date, note: String, userId: String) {
        self.docID = docID
        self.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        self.price = price
        self.createdAt = createdAt
        self.note = note.isEmpty ? "メモは書かれていません…" : note
        self.userId = userId
    }
    
}
