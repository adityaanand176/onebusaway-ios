//
//  StopAnnotation.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import MapKit
import OBAKitCore
import GRDB

class StopAnnotation: NSObject, MKAnnotation {
    let stop: Stop
    let routes: [Route]
    var isBookmarked: Bool

    convenience init(stop: Stop, isBookmarked: Bool = false, database: DatabaseReader) throws {
        let routes = try database.read { db in
            return try stop.routes.fetchAll(db)
        }

        self.init(stop: stop, routes: routes, isBookmarked: isBookmarked)
    }

    init(stop: Stop, routes: [Route] = [], isBookmarked: Bool = false) {
        self.stop = stop
        self.routes = routes
        self.isBookmarked = isBookmarked
    }

    var coordinate: CLLocationCoordinate2D {
        stop.location.coordinate
    }

    var title: String? {
        Formatters.formattedTitle(stop: stop)
    }

    /// The subtitle for a `Stop` as an `MKAnnotation` is a formatted list of `Route`s served by this `Stop`,
    /// plus the value of `Stop.code`, which is the transit rider-visible stop ID number.
    public var subtitle: String? {
        ["#\(stop.code)", Formatters.formattedRoutes(routes) ]
            .compactMap{ $0 }
            .joined(separator: "\n")
    }

    public var mapTitle: String? {
        return Formatters.formattedRoutes(routes, limit: 3)
    }
}
