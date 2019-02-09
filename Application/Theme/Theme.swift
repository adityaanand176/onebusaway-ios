//
//  Theme.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/25/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit

@objc(OBATheme)
public class Theme: NSObject {
    public let colors: ThemeColors
    public let fonts: ThemeFonts
    public let metrics: ThemeMetrics

    public init(bundle: Bundle?, traitCollection: UITraitCollection?) {
        colors = ThemeColors(bundle: bundle ?? Bundle(for: Theme.self), traitCollection: traitCollection)
        fonts = ThemeFonts()
        metrics = ThemeMetrics()
    }
}

@objc(OBAThemeMetrics)
public class ThemeMetrics: NSObject {

    public let padding: CGFloat = 8.0

    public let controllerMargin: CGFloat = 20.0

    public let defaultMapAnnotationSize: CGFloat = 54.0
}

@objc(OBAThemeColors)
public class ThemeColors: NSObject {

    /// Primary theme color.
    public let primary: UIColor

    /// Dark variant of the primary theme color.
    public let dark: UIColor

    /// Light variant of the primary theme color.
    public let light: UIColor

    /// Light text color, used on dark backgrounds.
    public let lightText: UIColor

    /// A gray text color, used on light backgrounds for de-emphasized text.
    public let subduedText: UIColor

    /// A dark gray text color, used on maps.
    public let mapText: UIColor

    public let stopAnnotationIcon: UIColor

    init(bundle: Bundle, traitCollection: UITraitCollection?) {
        primary = UIColor(named: "primary", in: bundle, compatibleWith: traitCollection)!
        dark = UIColor(named: "dark", in: bundle, compatibleWith: traitCollection)!
        light = UIColor(named: "light", in: bundle, compatibleWith: traitCollection)!
        lightText = UIColor(named: "lightText", in: bundle, compatibleWith: traitCollection)!
        subduedText = UIColor(named: "subduedText", in: bundle, compatibleWith: traitCollection)!
        mapText = UIColor(named: "mapTextColor", in: bundle, compatibleWith: traitCollection)!
        stopAnnotationIcon = UIColor(named: "stopAnnotationIconColor", in: bundle, compatibleWith: traitCollection)!
    }
}

@objc(OBAThemeFonts)
public class ThemeFonts: NSObject {

    // MARK: - Fonts

    public lazy var title = ThemeFonts.boldFont(textStyle: UIFont.TextStyle.title2)
    public lazy var body = ThemeFonts.font(textStyle: UIFont.TextStyle.body)
    public lazy var boldBody = ThemeFonts.boldFont(textStyle: UIFont.TextStyle.body)
    public lazy var footnote = ThemeFonts.font(textStyle: UIFont.TextStyle.footnote)
    public lazy var mapAnnotation: UIFont = {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.footnote)
        return UIFont.systemFont(ofSize: descriptor.pointSize - 2.0, weight: .black)
    }()

    // MARK: - Internal

    private static let maxFontSize: CGFloat = 32.0

    private class func font(textStyle: UIFont.TextStyle, pointSize: CGFloat? = nil) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let size = pointSize ?? min(descriptor.pointSize, maxFontSize)
        return UIFont(descriptor: descriptor, size: size)
    }

    private class func boldFont(textStyle: UIFont.TextStyle, pointSize: CGFloat? = nil) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).withSymbolicTraits(.traitBold)!
        let size = pointSize ?? min(descriptor.pointSize, maxFontSize)
        return UIFont(descriptor: descriptor, size: size)
    }
}