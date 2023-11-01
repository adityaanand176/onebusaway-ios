//
//  AgenciesViewController.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import SafariServices
import OBAKitCore
import GRDB

/// Loads and displays a list of agencies in the current region.
class AgenciesViewController: PersistenceTaskController<[Agency]>, OBAListViewDataSource {
    let listView = OBAListView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeColors.shared.systemBackground

        listView.obaDataSource = self
        view.addSubview(listView)
        listView.pinToSuperview(.edges)

        title = OBALoc("agencies_controller.title", value: "Agencies", comment: "Title of the Agencies controller")
    }

    override func fetchFromPersistence() async throws -> [Agency]? {
        return try await persistence.database.read { db in
            try Agency.fetchAll(db)
        }
    }

    override func fetchFromRemote() async throws {
        guard let apiService = application.apiService else {
            throw UnstructuredError("No API Service")
        }

        let response = try await apiService.getAgenciesWithCoverage()

        // Agencies are stored in the getAgenciesWithCoverage's references.
        try await persistence.processAPIResponse(response)
    }

    @MainActor
    override func updateUI() {
        listView.applyData()
    }

    // MARK: - OBAListKit
    func items(for listView: OBAListView) -> [OBAListViewSection] {
        guard let agencies = data else { return [] }

        let rows = agencies
            .sorted(by: \.name)
            .map { agency -> OBAListRowView.DefaultViewModel in
                OBAListRowView.DefaultViewModel(
                    title: agency.name,
                    accessoryType: .disclosureIndicator,
                    onSelectAction: { _ in
                        self.onSelectAgency(agency)
                    })
            }

        return [OBAListViewSection(id: "agencies", title: nil, contents: rows)]
    }

    func onSelectAgency(_ agency: Agency) {
        let safari = SFSafariViewController(url: agency.agencyURL)
        self.application.viewRouter.present(safari, from: self)
    }
}
