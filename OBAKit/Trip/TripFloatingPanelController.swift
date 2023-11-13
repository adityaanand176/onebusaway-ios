//
//  TripFloatingPanelController.swift
//  OBAKit
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import GRDB
import OBAKitCore

final class TripFloatingPanelController: VisualEffectViewController {

    let application: Application

    init(application: Application) {
        self.application = application
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tripDetailsViewController = TripDetailsViewController()
    lazy var stopArrivalView = StopArrivalView.autolayoutNew()
    lazy var stopArrivalSeparator = UIView.autolayoutNew()

    override func viewDidLoad() {
        super.viewDidLoad()

        stopArrivalView.formatters = application.formatters

        visualEffectView.contentView.addSubview(stopArrivalView)
        NSLayoutConstraint.activate([
            stopArrivalView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stopArrivalView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stopArrivalView.topAnchor.constraint(equalTo: view.topAnchor, constant: ThemeMetrics.padding)
        ])

        visualEffectView.contentView.addSubview(stopArrivalSeparator)
        stopArrivalSeparator.backgroundColor = UIColor.separator
        NSLayoutConstraint.activate([
            stopArrivalSeparator.topAnchor.constraint(equalTo: stopArrivalView.bottomAnchor, constant: ThemeMetrics.compactPadding),
            stopArrivalSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stopArrivalSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stopArrivalSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])

        tripDetailsViewController.collectionView.backgroundColor = nil
        tripDetailsViewController.collectionView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tripDetailsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        tripDetailsViewController.willMove(toParent: self)
        addChild(tripDetailsViewController)
        visualEffectView.contentView.addSubview(tripDetailsViewController.view)

        NSLayoutConstraint.activate([
            tripDetailsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tripDetailsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tripDetailsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tripDetailsViewController.view.topAnchor.constraint(equalTo: stopArrivalSeparator.bottomAnchor)
        ])

        tripDetailsViewController.didMove(toParent: self)
        setContentScrollView(tripDetailsViewController.contentScrollView(for: .bottom), for: .bottom)
    }
}
