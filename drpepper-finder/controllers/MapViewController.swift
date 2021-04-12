//
//  MapViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseCore
import FirebaseFirestore

class MapViewController: UIViewController, CLLocationManagerDelegate {

    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerセットアップ
        locationManager.delegate = self
    }
    
    // 位置情報の権限が更新された時
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // 位置情報の取得開始
            locationManager.startUpdatingLocation()
            // 現在地セット
            self.setToCurrentLocation()
            break
        case .restricted, .denied:
            break
        default:
            break
        }
    }
    
    // 位置情報が更新された時
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    func setToCurrentLocation() {
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Mapを現在地にセット
            let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: mapSpan)
            mapView.region = mapRegion
        }
    }
    
    @IBAction func setToCurrentLocationButton() {
        self.setToCurrentLocation()
    }
    
    // 新規にピンを追加
    @IBAction func addNewPinButton() {
        // MapViewの中心座標
        let coordinate = mapView.centerCoordinate
        
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
    }

}
