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
    let userId: String!
    
    init(docID: String, coordinate: CLLocationCoordinate2D, userId: String) {
        self.docID = docID
        self.userId = userId
        // MKPointAnnotationが元から持っている変数はsuper.init()以下に
        super.init()
        self.coordinate = coordinate
    }
}
