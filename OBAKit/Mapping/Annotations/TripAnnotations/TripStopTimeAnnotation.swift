//
//  TripStopTimeAnnotation.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import MapKit
import OBAKitCore

class TripStopTimeAnnotation: NSObject, MKAnnotation {
    let tripStopTime: TripStopTime
    let stop: Stop

    init(tripStopTime: TripStopTime, stop: Stop) {
        self.tripStopTime = tripStopTime
        self.stop = stop
    }

    var coordinate: CLLocationCoordinate2D {
        stop.location.coordinate
    }

    var title: String? {
        Formatters.formattedTitle(stop: stop)
    }

    var subtitle: String? {
        nil
    }
}
