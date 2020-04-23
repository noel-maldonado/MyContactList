//
//  MapPoint.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/22/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation{
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

