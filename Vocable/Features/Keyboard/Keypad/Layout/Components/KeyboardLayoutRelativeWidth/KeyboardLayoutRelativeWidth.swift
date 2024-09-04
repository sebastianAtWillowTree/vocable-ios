//
//  KeyboardLayoutRelativeWidth.swift
//
//
//  Created by Chris Stroud on 6/17/24.
//

import Foundation

protocol KeyboardLayoutRelativeWidth: Hashable {
    func value(
        in containerWidth: CGFloat,
        environment: KeyboardLayoutEnvironment
    ) -> CGFloat

    static prefix func - (_ value: Self) -> Self
}

func - (lhs: any KeyboardLayoutRelativeWidth, rhs: any KeyboardLayoutRelativeWidth) -> KeyboardLayoutRelativeWidthCompound {
    .compound(lhs, -AnyKeyboardLayoutRelativeWidth(rhs))
}

func -= (lhs: inout any KeyboardLayoutRelativeWidth, rhs: any KeyboardLayoutRelativeWidth) {
    lhs = .compound(lhs, -AnyKeyboardLayoutRelativeWidth(rhs))
}

func + (lhs: any KeyboardLayoutRelativeWidth, rhs: any KeyboardLayoutRelativeWidth) -> KeyboardLayoutRelativeWidthCompound {
    .compound(lhs, rhs)
}

func += (lhs: inout any KeyboardLayoutRelativeWidth, rhs: any KeyboardLayoutRelativeWidth) {
    lhs = KeyboardLayoutRelativeWidthCompound(lhs: lhs, rhs: rhs)
}
