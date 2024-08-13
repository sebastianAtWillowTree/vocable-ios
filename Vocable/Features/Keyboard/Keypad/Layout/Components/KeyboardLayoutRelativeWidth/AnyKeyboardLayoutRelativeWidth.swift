//
//  AnyKeyboardLayoutRelativeWidth.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

final class AnyKeyboardLayoutRelativeWidth: KeyboardLayoutRelativeWidth {

    private enum EnclosedLayoutWidth: Hashable {
        case proportional(KeyboardLayoutRelativeWidthProportional)
        case span(KeyboardLayoutRelativeWidthSpan)
        case compound(KeyboardLayoutRelativeWidthCompound)
        case fixed(KeyboardLayoutRelativeWidthFixed)
    }

    private let enclosedWidth: EnclosedLayoutWidth

    init(_ layoutWidth: any KeyboardLayoutRelativeWidth) {
        if let layoutWidth = layoutWidth as? KeyboardLayoutRelativeWidthProportional {
            enclosedWidth = .proportional(layoutWidth)
        } else if let layoutWidth = layoutWidth as? KeyboardLayoutRelativeWidthSpan {
            enclosedWidth = .span(layoutWidth)
        } else if let layoutWidth = layoutWidth as? KeyboardLayoutRelativeWidthCompound {
            enclosedWidth = .compound(layoutWidth)
        } else if let layoutWidth = layoutWidth as? KeyboardLayoutRelativeWidthFixed {
            enclosedWidth = .fixed(layoutWidth)
        } else if let layoutWidth = layoutWidth as? AnyKeyboardLayoutRelativeWidth {
            enclosedWidth = layoutWidth.enclosedWidth
        } else {
            fatalError("Unknown width")
        }
    }

    func value(in containerWidth: CGFloat, environment: KeyboardLayoutEnvironment) -> CGFloat {
        switch enclosedWidth {
        case .proportional(let layoutWidth):
            layoutWidth.value(in: containerWidth, environment: environment)
        case .span(let layoutWidth):
            layoutWidth.value(in: containerWidth, environment: environment)
        case .compound(let layoutWidth):
            layoutWidth.value(in: containerWidth, environment: environment)
        case .fixed(let layoutWidth):
            layoutWidth.value(in: containerWidth, environment: environment)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(enclosedWidth)
    }

    static func == (lhs: AnyKeyboardLayoutRelativeWidth, rhs: AnyKeyboardLayoutRelativeWidth) -> Bool {
        lhs.enclosedWidth == rhs.enclosedWidth
    }

    // MARK: Operators
    
    static prefix func - (value: AnyKeyboardLayoutRelativeWidth) -> AnyKeyboardLayoutRelativeWidth {
        switch value.enclosedWidth {
        case .proportional(let layoutWidth):
                .init(-layoutWidth)
        case .span(let layoutWidth):
                .init(-layoutWidth)
        case .compound(let layoutWidth):
                .init(-layoutWidth)
        case .fixed(let layoutWidth):
                .init(-layoutWidth)
        }
    }
}
