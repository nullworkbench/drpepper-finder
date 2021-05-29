//
//  SearchViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/05/29.
//

import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var table: UITableView!
    
    var searchResult = [CLPlacemark]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // searchBar
        searchBar.delegate = self

        // searchBar
        table.dataSource = self
        table.delegate = self
    }
    
}


// SearchBar, 住所検索
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.searchAddress()
        } else {
            // 入力がなければ検索結果を削除
            searchResult = [CLPlacemark]()
            table.reloadData()
        }
    }
    
    func searchAddress() {
        // 検索窓に入力された住所
        if let address = searchBar.searchTextField.text {
            
            // 検索クエリ
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = address
            
            // 検索
            let localSearch = MKLocalSearch(request: searchRequest)
            
            // 検索開始
            self.searchResult = [CLPlacemark]() // 検索結果クリア
            localSearch.start(completionHandler: {(result, error) in
                if let err = error {
                    print("Error getting search result: \(err)")
                } else {
                    // 検索結果追加
                    for item in (result?.mapItems)! {
                        self.searchResult.append(item.placemark)
                    }
                    // tableView再読み込み
                    self.table.reloadData()
                }
            })
        } else {
            // 検索窓が空なら終了
            return
        }
    }
    
    
    func placemarkToAddressString(_ placemark: CLPlacemark) -> String {
        var address = ""
        
        // 都道府県
        if let administractiveArea = placemark.administrativeArea {
            address += administractiveArea
        } else { return address }
        // 市町村
        if let locality = placemark.locality {
            address += locality
        } else { return address }
        // 丁目
        if let thoroughfare = placemark.thoroughfare {
            address += thoroughfare
        } else { return address }
        // 番地
        if let subThoroughfare = placemark.subThoroughfare {
            address += subThoroughfare
        } else { return address }
        
        return address
    }
}

// TableView
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    // cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count;
    }
    
    // cellの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        // タイトル
        (cell.viewWithTag(1) as! UILabel).text = searchResult[indexPath.row].name
        // 住所
        (cell.viewWithTag(2) as! UILabel).text = self.placemarkToAddressString(searchResult[indexPath.row])
        return cell
    }
    
    // cellがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 前の画面
        let navigationController = self.navigationController!
        let mapViewcontroller = navigationController.viewControllers[navigationController.viewControllers.count - 2] as! MapViewController
        
        // 前の画面のmapView
        let mapView = mapViewcontroller.mapView!
        
        // 検索結果のcoordinate
        let coordinate = (searchResult[indexPath.row].location?.coordinate)!
        
        // mapViewの中心を変更
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: coordinate, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        
        // mapViewControllerへ戻る
        self.navigationController?.popViewController(animated: true)
    }
}
