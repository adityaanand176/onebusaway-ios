//
//  TripStatusAnnotation.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import MapKit
import OBAKitCore

class TripStatusAnnotation: NSObject, MKAnnotation {
    let tripStatus: TripStatus

    init(tripStatus: TripStatus) {
        self.tripStatus = tripStatus
    }

    var coordinate: CLLocationCoordinate2D {
        tripStatus.lastKnownLocation?.location.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    var title: String? {
        guard let vehicleID = tripStatus.vehicleID else {
            return OBALoc("trip_status_annotation.vehicle_id_unavailable", value: "Vehicle ID Unavailable", comment: "Shown on the map when the user taps on a vehicle to indicate we don't know the vehicle's ID.")
        }

        let fmt = OBALoc("trip_status_annotation.title_fmt", value: "Vehicle ID: %@", comment: "A formatted string for displaying a vehicle's ID on the trip status map. e.g. 'Vehicle ID: 12345'")
        return String(format: fmt, vehicleID)
    }
}
