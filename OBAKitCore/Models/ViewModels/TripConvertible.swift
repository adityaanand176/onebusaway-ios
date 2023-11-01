//
//  TripConvertible.swift
//  OBAKitCore
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// A model that displays Trip information.
public class TripConvertible: NSObject {
    public var arrivalDeparture: ArrivalDeparture?
    public var vehicleStatus: VehicleStatus?

    public init(arrivalDeparture: ArrivalDeparture) {
        self.arrivalDeparture = arrivalDeparture
    }

    public init?(vehicleStatus: VehicleStatus) {
        guard vehicleStatus.tripID != nil else {
            return nil
        }
        self.vehicleStatus = vehicleStatus
    }

    public var vehicleID: String? {
        arrivalDeparture?.vehicleID ?? vehicleStatus?.vehicleID
    }

    public var tripStatus: TripStatus? {
        return arrivalDeparture?.tripStatus ?? vehicleStatus?.tripStatus
    }

    public var tripID: TripIdentifier {
        return arrivalDeparture?.tripID ?? vehicleStatus!.tripID!
    }

    public var serviceDate: Date {
        return arrivalDeparture?.serviceDate ?? vehicleStatus!.tripStatus.serviceDate
    }
}
