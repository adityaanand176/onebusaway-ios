//
//  FullSituation.swift
//  OBAKitCore
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import GRDB

public struct DetailedSituation {
    public let situation: Situation

    public let activeWindows: [DateInterval]
    public let publicationWindows: [DateInterval]

    public let affectedAgencies: Set<Agency>
    public let affectedRoutes: Set<Route>
    public let affectedStops: Set<Stop>
    public let affectedTrips: Set<Trip>
}

extension Situation {
    public static func fetchDetailedSituation(_ db: Database, id: Situation.ID) throws -> DetailedSituation? {
        guard let situation = try Situation.fetchOne(db, id: id) else {
            return nil
        }

        let activeWindows = try situation.activeWindows.fetchAll(db)
            .map { TimeWindow(from: $0.from, to: $0.to).interval }
        let publicationWindows = try situation.publicationWindows.fetchAll(db)
            .map { TimeWindow(from: $0.from, to: $0.to).interval }

        let affectedEntities = try situation.affectedEntities.fetchAll(db)

        let agencies = try affectedEntities
            .compactMap { try $0.agency.fetchOne(db) }
        let routes = try affectedEntities
            .compactMap { try $0.route.fetchOne(db) }
        let stops = try affectedEntities
            .compactMap { try $0.stop.fetchOne(db) }
        let trips = try affectedEntities
            .compactMap { try $0.trip.fetchOne(db) }

        return DetailedSituation(
            situation: situation,
            activeWindows: activeWindows,
            publicationWindows: publicationWindows,
            affectedAgencies: Set(agencies),
            affectedRoutes: Set(routes),
            affectedStops: Set(stops),
            affectedTrips: Set(trips)
        )
    }
}
