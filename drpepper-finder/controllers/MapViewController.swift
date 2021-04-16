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
import FirebaseFirestoreSwift

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerセットアップ
        locationManager.delegate = self
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue(label: "showAllCustomPins", qos: .default).async {
            self.showAllCustomPins()
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


// MARK: Custom Class
class CustomPin: MKPointAnnotation {
    var pinImage: UIImage?
}

// MARK: 位置情報関係
extension MapViewController {
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
    // 現在地にセット
    func setToCurrentLocation() {
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Mapを現在地にセット
            let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: mapSpan)
            mapView.setRegion(mapRegion, animated: true)
        }
    }
}

// MARK: MapKit関連
extension MapViewController {
    // MARK: ピン表示設定
    // addAnotationしたときに呼ばれる
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 現在地ピンは何も変更しない
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "pin"
        let anotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        // pinImageがあればピンに画像をつける
        if let pin = annotation as? CustomPin {
            if let pinImage = pin.pinImage {
                // pinImage設定
                anotationView.image = pinImage // リサイズより先に画像設定
                // pinImageをリサイズ
                let screenWidth = UIScreen.main.bounds.width * 0.1
                let pinImageSize = CGSize(width: screenWidth, height: screenWidth)
                anotationView.frame.size = pinImageSize
            }
        }
        
        return anotationView
    }
    
    // MARK: カスタムピンの取得＆表示
    // Firestoreに保存されているピンを表示
    func showAllCustomPins() {
        
        for pin in self.getAllPins() {
            pin.title = "test"
            pin.subtitle = "Jollibeeうまい"
            pin.pinImage = UIImage(named: "drpepper")
            self.mapView.addAnnotation(pin)
        }
    }
    
    // Firestoreに保存されているピンを取得
    func getAllPins() -> [CustomPin] {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var pins = [CustomPin]()
        print("query will start")
        db.collection("pins").limit(to: 50).getDocuments() { (querySnapshot, err) in
            print("firestore query started")
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let newCustomPin = CustomPin()
                    let geoPoint = document["coordinate"] as! GeoPoint
                    newCustomPin.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                    
                    pins.append(newCustomPin)
                }
                semaphore.signal()
            }
        }
        print("start waiting")
        semaphore.wait()
        print("pins downloaded")
        return pins
    }

}
