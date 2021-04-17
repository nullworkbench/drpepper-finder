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
import CoreLocation

class addNewPinViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func postToFireStore() {
        // Firestoreに登録
        var ref: DocumentReference?
        ref = db.collection("pins").addDocument(data: [
            "coordinate": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "createdAt": FieldValue.serverTimestamp(),
            "note": ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // ログを保存
        Ex.loggingToFirestore(ref!.documentID, 0)
    }

}
