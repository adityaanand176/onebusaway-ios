//
//  PersistenceTaskController.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import GRDB
import OBAKitCore

open class PersistenceTaskController<DataType>: UIViewController, AppContext {
    let application: Application
    var persistence: PersistenceService

    public var data: DataType? {
        try? result?.get().data
    }

    public var error: Error? {
        if case let .failure(error) = self.result {
            return error
        } else {
            return nil
        }
    }

    private var result: Result<FetchResult, Error>? {
        didSet {
            updateUI()
        }
    }
    private var task: Task<Void, Error>?

    public init(application: Application) {
        self.application = application
        self.persistence = PersistenceServiceRegion[application.currentRegion]
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func viewDidLoad() {
        super.viewDidLoad()

        task = Task {
            result = await Result {
                return try await fetch()
            }
        }
    }

    struct FetchResult {
        let isOffline: Bool
        let data: DataType?
    }

    func fetch() async throws -> FetchResult {
        let remoteFetchResult = await Result { try await fetchFromRemote() }
        let persistenceFetchResult: Result<DataType?, Error> = await Result { try await fetchFromPersistence() }

        let remoteFetchResultError: Error?
        if case let .failure(error) = remoteFetchResult {
            remoteFetchResultError = error
        } else {
            remoteFetchResultError = nil
        }

        switch persistenceFetchResult {
        case .success(let success):
            return FetchResult(isOffline: remoteFetchResultError != nil, data: success)
        case .failure(let failure):
            throw failure
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
    }

    open func fetchFromRemote() async throws {
        fatalError("\(#function) has not been implemented")
    }

    open func fetchFromPersistence() async throws -> DataType? {
        fatalError("\(#function) has not been implemented")
    }

    @MainActor
    open func updateUI() {

    }
}

extension Result where Failure == Error {
    init(catchingAsync: () async throws -> Success) async {
        do {
            self = .success(try await catchingAsync())
        } catch {
            self = .failure(error)
        }
    }
}
