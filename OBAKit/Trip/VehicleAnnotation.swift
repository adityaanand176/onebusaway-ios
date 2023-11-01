//
//  VehicleAnnotation.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 10/4/20.
//

import Foundation
import OBAKitCore
import MapKit

class VehicleAnnotation: MKPointAnnotation {

    init(tripStatus: TripStatusAnnotation) {
        self.tripStatus = tripStatus
        super.init()
        updateAnnotation()
    }

    private func updateAnnotation() {
        self.title = tripStatus?.title ?? ""
        self.coordinate = tripStatus?.tripStatus.lastKnownLocation?.location.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    var tripStatus: TripStatusAnnotation? {
        didSet {
            updateAnnotation()
        }
    }
}
