//
//  TripDetailsViewModel.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import GRDB
import OBAKitCore

struct TripDetailsViewModel: Hashable {
    var tripDetails: TripDetails
    
    var trip: Trip
    var previousTrip: Trip? = nil
    var nextTrip: Trip? = nil

    var stops: [Stop.ID: Stop]
    var situations: [Situation.ID: Situation]

    static func fetch(_ database: DatabaseReader, tripDetails: TripDetails) throws -> TripDetailsViewModel? {
        return try database.read { db -> TripDetailsViewModel? in
            guard let trip = try tripDetails.trip.fetchOne(db) else {
                return nil
            }

            var viewModel = TripDetailsViewModel(tripDetails: tripDetails, trip: trip, stops: [:], situations: [:])

            if let previousTrip = tripDetails.schedule.previousTripID {
                viewModel.previousTrip = try Trip.fetchOne(db, id: previousTrip)
            }

            if let nextTrip = tripDetails.schedule.nextTripID {
                viewModel.nextTrip = try Trip.fetchOne(db, id: nextTrip)
            }

            let stopsIDs = tripDetails.schedule.stopTimes.map(\.stopID)
            let stops = try Stop.fetchAll(db, ids: stopsIDs)
            for stop in stops {
                viewModel.stops[stop.id] = stop
            }

            let situations = try Situation.fetchAll(db, ids: tripDetails.situationIDs)
            for situation in situations {
                viewModel.situations[situation.id] = situation
            }

            return viewModel
        }
    }
}
