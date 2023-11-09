//
//  TripDetailsViewController.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import Combine
import OBAKitCore

protocol TripDetailsDelegate: AnyObject {
    func tripDetailsViewController(_ tripDetailsViewController: TripDetailsViewController, didSelectTrip tripID: TripIdentifier)
    func tripDetailsViewController(_ tripDetailsViewController: TripDetailsViewController, didSelectStop stopID: StopID)
}

final class TripDetailsViewController: UICollectionViewController {
    enum Section {
        case main
    }

    fileprivate struct Item: Hashable {
        let state: TripSegmentView.State
        let title: String
        let date: Date?
        let stopID: StopID?
        let emphasize: Bool

        init(state: TripSegmentView.State, stopID: StopID? = nil, title: String, date: Date?, emphasize: Bool = false) {
            self.state = state
            self.title = title
            self.stopID = stopID
            self.date = date
            self.emphasize = emphasize
        }
    }

    // MARK: - State
    @Published var currentStop: Stop.ID?
    @Published var tripDetailsViewModel: TripDetailsViewModel? = nil

    weak var delegate: TripDetailsDelegate?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Collection View
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cellRegistration: UICollectionView.CellRegistration<TripStopCell, Item>!

    init() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = false

        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        cellRegistration = UICollectionView.CellRegistration<TripStopCell, Item> { cell, indexPath, item in
            cell.tripSegmentView.state = item.state
            cell.titleLabel.text = item.title

            if item.emphasize {
                cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body).withTraits(traits: .traitBold)
                cell.timeLabel.font = UIFont.preferredFont(forTextStyle: .body).withTraits(traits: .traitBold)
            } else {
                cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
                cell.timeLabel.font = UIFont.preferredFont(forTextStyle: .body)
            }

            if let date = item.date {
                cell.timeLabel.text = date.formatted(date: .omitted, time:  .shortened)
                cell.setAlpha(date < .now ? 1/2 : 1)
            } else {
                cell.timeLabel.text = nil
                cell.setAlpha(1)
            }
        }

        diffableDataSource = .init(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
        })

        view.addSubview(collectionView)
        collectionView.pinToSuperview(.edges)
        setContentScrollView(collectionView)

        $tripDetailsViewModel
            .receive(on: DispatchQueue.main)
            .sink { _ /* TripsDetailsViewModel */ in
                self.applyData()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    @MainActor
    private func applyData() {
        var items: [Item] = []
        if let tripDetailsViewModel {
            let stopTimes = tripDetailsViewModel.tripDetails.schedule.stopTimes

            let isOmittingPreviousStops = currentStop != nil
            if let previousTrip = tripDetailsViewModel.previousTrip, !isOmittingPreviousStops {
                let title = String(
                    format: OBALoc(
                        "trip_details_controller.starts_as_fmt",
                        value: "Starts as %@",
                        comment: "Describes the previous trip of this vehicle. e.g. Starts as 10 - Downtown Seattle"
                    ),
                    previousTrip.routeHeadsign
                )

                items.append(Item(state: .previousTrip, title: title, date: nil))
            }

            if let currentStop, let firstIndex = stopTimes.firstIndex(where: { $0.stopID == currentStop }) {
                let stopsBefore = String(AttributedString(localized: "^[\(firstIndex) \("stop")](inflect: true) before").characters)
                items.append(Item(state: .ellipsis, title: stopsBefore, date: nil))
                items.append(contentsOf: listItems(tripDetailsViewModel, range: firstIndex...))
            } else {
                items.append(contentsOf: listItems(tripDetailsViewModel, range: 0...))
            }

            if let nextTrip = tripDetailsViewModel.nextTrip {
                let title = String(
                    format: OBALoc(
                        "trip_details_controller.continues_as_fmt",
                        value: "Continues as %@",
                        comment: "Describes the next trip of this vehicle. e.g. Continues as 10 - Downtown Seattle"
                    ),
                    nextTrip.routeHeadsign
                )

                items.append(Item(state: .nextTrip, title: title, date: nil))
            }
        }

        var section = NSDiffableDataSourceSectionSnapshot<Item>()
        section.append(items)
        self.diffableDataSource.apply(section, to: .main)
    }

    private func listItems(_ viewModel: TripDetailsViewModel, range: PartialRangeFrom<Int>) -> [Item] {
        var items: [Item] = []

        let stopTimes = viewModel.tripDetails.schedule.stopTimes

        for (index, stopTime) in stopTimes.enumerated() where index >= range.lowerBound {
            let state: TripSegmentView.State
            if index == stopTimes.startIndex {
                if viewModel.previousTrip != nil {
                    state = .stop
                } else {
                    state = .origin
                }
            } else if index == stopTimes.endIndex - 1 {
                if viewModel.nextTrip != nil {
                    state = .stop
                } else {
                    state = .terminal
                }
            } else {
                state = .stop
            }

            items.append(Item(
                state: state,
                stopID: stopTime.stopID,
                title: viewModel.stops[stopTime.stopID]?.name ?? stopTime.stopID,
                date: stopTime.departureDate(relativeTo: viewModel.tripDetails)
            ))
        }

        return items
    }

    #if DEBUG && targetEnvironment(simulator)
    /// For use with Xcode previews only.
    fileprivate func applyNonInteractivePreviewData(_ items: [Item]) {
        var section = NSDiffableDataSourceSectionSnapshot<Item>()
        section.append(items)
        self.diffableDataSource.apply(section, to: .main)
    }
    #endif

    // MARK: - UICollectionViewDelegate methods
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }

        switch item.state {
        case .ellipsis:
            self.currentStop = nil
            self.applyData()

        case .nextTrip:
            if let nextTrip = self.tripDetailsViewModel?.nextTrip {
                self.delegate?.tripDetailsViewController(self, didSelectTrip: nextTrip.id)
            }

        case .previousTrip:
            if let previousTrip = self.tripDetailsViewModel?.previousTrip {
                self.delegate?.tripDetailsViewController(self, didSelectTrip: previousTrip.id)
            }

        case .origin, .terminal, .stop: 
            if let stop = item.stopID {
                self.delegate?.tripDetailsViewController(self, didSelectStop: stop)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG && targetEnvironment(simulator)
@available(iOS 17, *)
#Preview {
    let view = TripDetailsViewController()
    view.loadViewIfNeeded()
    view.applyNonInteractivePreviewData([
        TripDetailsViewController.Item(state: .origin, title: "Origin stop", date: nil),
        TripDetailsViewController.Item(state: .nextTrip, title: "Continues as 550", date: nil),
        TripDetailsViewController.Item(state: .previousTrip, title: "Previous Trip", date: nil),
        TripDetailsViewController.Item(state: .stop, title: "Past Stop", date: .now - 180),
        TripDetailsViewController.Item(state: .stop, title: "Past Stop", date: .now - 120),
        TripDetailsViewController.Item(state: .stop, title: "Past Stop", date: .now - 60),
        TripDetailsViewController.Item(state: .stop, title: "Current Stop", date: .now + 120, emphasize: true),
        TripDetailsViewController.Item(state: .stop, title: "Future Stop", date: .now + 180),
        TripDetailsViewController.Item(state: .ellipsis, title: "ellipsis", date: nil),
        TripDetailsViewController.Item(state: .nextTrip, title: "Next trip", date: nil),
        TripDetailsViewController.Item(state: .previousTrip, title: "Prev Trip", date: nil),
        TripDetailsViewController.Item(state: .terminal, title: "Terminal stop", date: .now + 600)
    ])

    return view
}

#endif
