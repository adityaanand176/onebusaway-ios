//
//  PersistenceServiceRegion.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import OBAKitCore

struct PersistenceServiceRegion {
    private static var serviceForRegion: [RegionIdentifier: PersistenceService] = [:]

    static subscript(region: RegionIdentifier) -> PersistenceService {
        if let service = serviceForRegion[region] {
            return service
        }

        let _service = try! PersistenceService(PersistenceService.Configuration(regionIdentifier: region, databaseLocation: .memory))
        serviceForRegion[region] = _service
        return _service
    }

    static subscript(region: Region?) -> PersistenceService {
        guard let identifier = region?.regionIdentifier else {
            fatalError("No region")
        }

        return self[identifier]
    }
}
