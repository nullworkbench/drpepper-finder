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
        // MapKitセットアップ
        mapView.delegate = self
        
        // カスタムピン取得＆表示
        DispatchQueue(label: "showAllCustomPins", qos: .default).async {
            self.showAllCustomPins()
        }
    }
    
    // 画面遷移準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        // 新規追加画面
        case "toAddNewPinView":
            let addNewPinViewController = segue.destination as! addNewPinViewController
            addNewPinViewController.coordinate = sender as? CLLocationCoordinate2D
        // ピンタップ後の詳細画面
        case "toDetailView":
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.docId = sender as? String
        default:
            break
        }
    }
    
    
    @IBAction func setToCurrentLocationButton() {
        self.setToCurrentLocation()
    }
    
    // 新規登録
    @IBAction func addNewPinButton() {
        // MapViewの中心座標
        let coordinate = mapView.centerCoordinate
        performSegue(withIdentifier: "toAddNewPinView", sender: coordinate)
    }

}


// MARK: Custom Class
class CustomPin: MKPointAnnotation {
    var docId: String?
    var pinImage: UIImage?
}

// MARK: 位置情報関係
extension MapViewController {
    // 位置情報の権限が更新された時
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        // 位置情報の利用を未選択
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        // 使用中は許可
        case .authorizedWhenInUse:
            // 位置情報の取得開始
            locationManager.startUpdatingLocation()
            // 現在地セット
            self.setToCurrentLocation()
            break
        // 拒否
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
        // 位置情報への権限を確認
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .notDetermined {
            let alert = UIAlertController(title: "位置情報サービスが必要です", message: "アプリのご利用には位置情報利用の許可が必要です。設定アプリから許可してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "設定へ移動", style: .default, handler: {action in
                // 設定画面を開く
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        // Mapを現在地にセット
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: locationManager.location!.coordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
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
                    // id設定
                    newCustomPin.docId = document.documentID
                    // 座標設定
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
    
    
    // MARK: ピンをタップしたときの設定
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        } else {
            print("pin tapped")
            // docIdをsenderへ渡す
            let docId = (view.annotation as! CustomPin).docId
            
            // 画面遷移
            performSegue(withIdentifier: "toDetailView", sender: docId)
            
            // 選択解除
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }

}
