//
//  ModelExtensions.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import MapKit
import OBAKitCore

// MARK: - Region/MKAnnotation

extension Region: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        centerCoordinate
    }

    public var title: String? {
        name
    }
}
