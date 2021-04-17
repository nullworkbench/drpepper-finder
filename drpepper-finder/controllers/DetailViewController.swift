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
    @IBOutlet weak var latestUpdateLabel: UILabel!
    @IBOutlet weak var foundDateLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // docIdからピンの詳細を取得
        db.collection("pins").document(docId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let geopoint = data["coordinate"] as! GeoPoint
                self.setMapCenter(CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude)) // Mapの中心点を設定
                let note = (data["note"] as? String)
                if note == "" { self.noteTextView.text = "noteはありません。" } else { self.noteTextView.text = note }
            } else {
                print("Document does not exist")
            }
        }
        
        // logを取得
//        db.collection("pins").document(docId).collection("logs").order(by: "timestamp").limit(to: 1).getDocuments { (querySnapshot, error) in
//            if let err = error {
//                print("Error getting documents: \(err)")
//            } else {
//                let data = querySnapshot?.documents[0].data()
//                let timestamp = (data!["timestamp"] as! Timestamp).dateValue()
//
//                switch data!["type"] as! Int {
//                case 0:
//                    self.latestUpdateLabel.text = "発見 \(timestamp)"
//                default:
//                    break
//                }
//            }
//        }
    }
    
    func setMapCenter(_ coordinate: CLLocationCoordinate2D) {
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: coordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
    }

}
