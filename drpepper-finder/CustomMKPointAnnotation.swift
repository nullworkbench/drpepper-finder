//
//  CustomMKPointAnnotation.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2022/01/09.
//

import MapKit

class CustomAnnotation: MKPointAnnotation {
    let docID: String!
    let pinImage = UIImage(named: "drpepper")
    
    init(docID: String) {
        self.docID = docID
    }
}
