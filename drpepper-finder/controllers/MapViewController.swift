//
//  MapViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/12.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerセットアップ
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //位置情報を使用可能か
        if CLLocationManager.locationServicesEnabled() {
            //位置情報の取得開始
            locationManager.startUpdatingLocation()
            
            self.setToCurrentLocation()
        }
    }
    
    // 位置情報が更新された時
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    func setToCurrentLocation() {
        // Mapを現在地にセット
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: mapSpan)
        mapView.region = mapRegion
    }
    
    @IBAction func setToCurrentLocationButton() {
        self.setToCurrentLocation()
    }

}
