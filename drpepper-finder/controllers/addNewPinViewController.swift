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
import MapKit

class addNewPinViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D!
    
    let db = Firestore.firestore()
    
    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setMapCenter(coordinate)
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
    
    
    
    @IBAction func postButton() {
        self.postToFireStore()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButton() {
        self.dismiss(animated: true, completion: nil)
    }

}
