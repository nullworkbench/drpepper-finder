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
            
    //        CLGeocoder().geocodeAddressString(address) { placemarks, error in
    //            let lat = placemarks?.first?.location?.coordinate.latitude
    //            let lng = placemarks?.first?.location?.coordinate.longitude
    //        }
            
        } else {
            // 検索窓が空なら終了
            return
        }
        
        
    }
}

// TableView
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = searchResult[indexPath.row].name
        return cell
    }
    
    
}
