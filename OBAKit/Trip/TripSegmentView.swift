//
//  TripSegmentView.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import OBAKitCore

/// The line/squircle adornment on the leading side of a cell on the `TripFloatingPanelController`.
///
/// Depicts if the associated stop is the user's destination or the current location of the transit vehicle.
class TripSegmentView: UIView {

    enum State: CaseIterable {
        case origin
        case ellipsis
        case stop
        case terminal
        case nextTrip
        case previousTrip
    }

    var state: State = .stop {
        didSet {
            setNeedsDisplay()
        }
    }

    private let lineWidth: CGFloat = 2.0
    private let circleRadius: CGFloat = 10
    private var halfRadius: CGFloat {
        circleRadius / 2.0
    }
    private let imageInset: CGFloat = 5.0

    /// This is the color that is used to highlight a value change in this label.
    public var lineColor: UIColor = ThemeColors.shared.brand

    /// This is the color that is used to highlight a value change in this label.
    public var imageColor: UIColor = ThemeColors.shared.brand

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: circleRadius + (2.0 * lineWidth), height: UIView.noIntrinsicMetric)
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()

        lineColor.setFill()
        lineColor.setStroke()

        switch state {
        case .nextTrip:
            drawNextTripSegment(rect, context: ctx)
        case .previousTrip:
            drawPreviousTripSegment(rect, context: ctx)
        case .origin:
            drawOrigin(rect, context: ctx)
        case .ellipsis:
            drawEllipsis(rect, context: ctx)
        case .stop:
            drawStop(rect, context: ctx)
        case .terminal:
            drawTerminal(rect, context: ctx)
        }

        ctx?.restoreGState()
    }

    private func drawGradient(_ colors: [UIColor], rect: CGRect, context: CGContext?) {
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.move(to: startPoint)
        path.addLine(to: endPoint)

        context?.addLines(between: [startPoint, endPoint])
        context?.setLineWidth(lineWidth)
        context?.replacePathWithStrokedPath()

        path.addClip()
        let gradient = CGGradient(colorsSpace: nil, colors: colors.map(\.cgColor) as CFArray, locations: nil)!
        context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }

    private func drawNextTripSegment(_ rect: CGRect, context: CGContext?) {
        drawGradient([lineColor, lineColor.withAlphaComponent(0)], rect: rect, context: context)
    }

    private func drawPreviousTripSegment(_ rect: CGRect, context: CGContext?) {
        drawGradient([lineColor.withAlphaComponent(0), lineColor], rect: rect, context: context)
    }

    private func drawOrigin(_ rect: CGRect, context: CGContext?) {
        let circle = CGRect(x: rect.midX - halfRadius, y: rect.minY + halfRadius, width: circleRadius, height: circleRadius)
        let circlePath = UIBezierPath(ovalIn: circle)
        circlePath.lineWidth = lineWidth
        circlePath.fill()

        let topLine = UIBezierPath()
        topLine.lineWidth = lineWidth
        topLine.move(to: CGPoint(x: rect.midX, y: circle.minY))
        topLine.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        topLine.stroke()
    }

    private func drawEllipsis(_ rect: CGRect, context: CGContext?) {
        let path = UIBezierPath()
        path.setLineDash([lineWidth, lineWidth], count: 2, phase: 0)
        path.lineWidth = lineWidth

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.stroke()
    }

    private func drawTerminal(_ rect: CGRect, context: CGContext?) {
        let topLine = UIBezierPath()
        topLine.lineWidth = lineWidth
        topLine.move(to: CGPoint(x: rect.midX, y: rect.minY))
        topLine.addLine(to: CGPoint(x: rect.midX, y: rect.minY + halfRadius))
        topLine.stroke()

        let circle = CGRect(x: rect.midX - halfRadius, y: rect.minY + halfRadius, width: circleRadius, height: circleRadius)
        let circlePath = UIBezierPath(ovalIn: circle)
        circlePath.lineWidth = lineWidth
        circlePath.fill()
    }

    private func drawStop(_ rect: CGRect, context: CGContext?) {
        let circleMinY = rect.minY + halfRadius
        let circleMaxY = rect.minY + halfRadius + circleRadius

        let topLine = UIBezierPath()
        topLine.lineWidth = lineWidth
        topLine.move(to: CGPoint(x: rect.midX, y: rect.minY))
        topLine.addLine(to: CGPoint(x: rect.midX, y: circleMinY))
        topLine.stroke()

        let circle = CGRect(x: rect.midX - halfRadius, y: circleMinY, width: circleRadius, height: circleRadius)
        let circlePath = UIBezierPath(ovalIn: circle)
        circlePath.lineWidth = lineWidth
        circlePath.stroke()

        let bottomLine = UIBezierPath()
        topLine.lineWidth = lineWidth
        topLine.move(to: CGPoint(x: rect.midX, y: circleMaxY))
        topLine.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        topLine.stroke()
    }
}

#if DEBUG
import SwiftUI
import OBAKitCore

struct TripSegmentView_Previews: PreviewProvider {
    private static let width: CGFloat = 64
    private static let height: CGFloat = 44

    private static func tripSegmentView(_ state: TripSegmentView.State) -> some View {
        HStack(alignment: .top) {
            UIViewPreview {
                let view = TripSegmentView()
                view.state = state
                return view
            }.frame(width: width, height: height, alignment: .center)

            Text("\(String(describing: state))")
        }
    }

    static var previews: some View {
        VStack(alignment: .leading, spacing: 0) {
            tripSegmentView(.origin)
            tripSegmentView(.stop)
            tripSegmentView(.ellipsis)
            tripSegmentView(.stop)
            tripSegmentView(.nextTrip)
            tripSegmentView(.previousTrip)
            tripSegmentView(.terminal)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

#endif
