//
//  TripStopListItem.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import OBAKitCore

fileprivate let tripStopCellMinimumHeight: CGFloat = 48.0

// MARK: - Cell

/// ## Standard Cell Appearance
/// ```
/// [ |                            ]
/// [ O  15th & Galer     7:25PM   ] <- Title and Time labels appears side-by-side
/// [ |                            ]
/// [ |                            ]
/// ```
///
/// ## Accessibility Cell Appearance
/// ```
/// [ |                            ]
/// [ |  15th                      ]
/// [ O  & Galer                   ] <- Title and Time labels appears on top of each other
/// [ |  7:25PM                    ]
/// [ |                            ]
/// ```
final class TripStopCell: OBAListViewCell {
    static let tripSegmentImageWidth: CGFloat = 20.0

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        timeLabel.text = nil
        tripSegmentView.state = .stop
    }

    let titleLabel: UILabel = {
        let label = UILabel.obaLabel(textColor: ThemeColors.shared.label)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel.obaLabel(
            font: .preferredFont(forTextStyle: .callout),
            textColor: ThemeColors.shared.secondaryLabel,
            numberOfLines: 1
        )
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let textLabelSpacerView = UIView.autolayoutNew()
    lazy var textLabelsStack: UIStackView = UIStackView(arrangedSubviews: [titleLabel, textLabelSpacerView, timeLabel])

    let tripSegmentView = TripSegmentView.autolayoutNew()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(tripSegmentView)
        NSLayoutConstraint.activate([
            tripSegmentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeMetrics.compactPadding),
            tripSegmentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tripSegmentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tripSegmentView.widthAnchor.constraint(equalToConstant: TripStopCell.tripSegmentImageWidth)
        ])

        textLabelsStack.alignment = .leading
        let stackWrapper = textLabelsStack.embedInWrapperView(setConstraints: true)
        contentView.addSubview(stackWrapper)

        let heightConstraint = stackWrapper.heightAnchor.constraint(greaterThanOrEqualToConstant: tripStopCellMinimumHeight)
        heightConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            stackWrapper.leadingAnchor.constraint(equalTo: tripSegmentView.trailingAnchor, constant: ThemeMetrics.padding),
            stackWrapper.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackWrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackWrapper.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            heightConstraint
        ])
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setAlpha(_ alpha: Double) {
        self.tripSegmentView.alpha = alpha
        self.titleLabel.alpha = alpha
        self.timeLabel.alpha = alpha
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAccessibility()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutAccessibility()
    }

    func layoutAccessibility() {
        self.textLabelsStack.axis = isAccessibility ? .vertical : .horizontal
        self.textLabelSpacerView.isHidden = isAccessibility
    }
}
