//
//  Monument.swift
//  pruebaMapas
//
//  Created by Eva Paracuellos on 26/2/24.
//

import Foundation
import MapKit

class Monument: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    
    init(
        title: String?,
        locationName: String?,
        discipline: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    var subtitle: String? {
        locationName
    }
}
