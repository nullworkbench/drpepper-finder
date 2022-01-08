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
    
    init(docID: String, coordinate: CLLocationCoordinate2D) {
        self.docID = docID
        // MKPointAnnotationが元から持っている変数はsuper.init()以下に
        super.init()
        self.coordinate = coordinate
    }
}
