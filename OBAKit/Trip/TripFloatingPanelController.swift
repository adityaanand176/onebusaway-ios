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

    lazy var tripDetailsViewController = TripDetailsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tripDetailsViewController.collectionView.backgroundColor = nil

        tripDetailsViewController.willMove(toParent: self)
        addChild(tripDetailsViewController)
        visualEffectView.contentView.addSubview(tripDetailsViewController.view)
        tripDetailsViewController.view.pinToSuperview(.edges)
        tripDetailsViewController.didMove(toParent: self)

        setContentScrollView(tripDetailsViewController.contentScrollView(for: .bottom), for: .bottom)
    }
}
