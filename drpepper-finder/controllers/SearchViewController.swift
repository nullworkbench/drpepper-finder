//
//  SearchViewController.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/05/29.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        return cell
    }
    
    
}
