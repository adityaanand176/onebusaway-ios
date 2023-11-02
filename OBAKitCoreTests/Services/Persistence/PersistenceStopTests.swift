//
//  PersistenceStopTests.swift
//  OBAKitCoreTests
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import OBAKitCore

final class PersistenceStopTests: OBAKitCorePersistenceTestCase {
    override func setUp() async throws {
        try await super.setUp()

        self.dataLoader.mock(
            URLString: "https://www.example.com/api/where/stop/1_621.json",
            with: try Fixtures.loadData(file: "stop_1_621.json")
        )

        self.dataLoader.mock(
            URLString: "https://www.example.com/api/where/stop/1_623.json",
            with: try Fixtures.loadData(file: "stop_1_623.json")
        )
    }

    func testParentStop() async throws {
        // 1_621 and 1_623 are expected to have a parent stop of 1_C09.
        let cidNorthResponse = try await restAPIService.getStop(id: "1_621")
        try await persistence.processAPIResponse(cidNorthResponse)
        XCTAssertEqual(cidNorthResponse.entry.parentStopID, "1_C09")

        let cidSouthResponse = try await restAPIService.getStop(id: "1_623")
        try await persistence.processAPIResponse(cidSouthResponse)
        XCTAssertEqual(cidSouthResponse.entry.parentStopID, "1_C09")

        let cidNorthParent = try await persistence.database.read { db in
            let cidNorth = try Stop.fetchOne(db, id: "1_621")
            return try cidNorth?.parentStop.fetchOne(db)
        }

        let cidSouthParent = try await persistence.database.read { db in
            let cidSouth = try Stop.fetchOne(db, id: "1_623")
            return try cidSouth?.parentStop.fetchOne(db)
        }

        XCTAssertEqual(cidNorthParent?.id, "1_C09")
        XCTAssertEqual(cidNorthParent, cidSouthParent)
    }
}
