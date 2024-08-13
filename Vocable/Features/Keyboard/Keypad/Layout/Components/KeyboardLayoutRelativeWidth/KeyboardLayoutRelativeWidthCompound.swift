//
//  KeyboardLayoutRelativeWidthCompound.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutRelativeWidthCompound: KeyboardLayoutRelativeWidth {

    private let lhs: AnyKeyboardLayoutRelativeWidth
    private let rhs: AnyKeyboardLayoutRelativeWidth
    private var sign: FloatingPointSign = .plus
    
    init(lhs: any KeyboardLayoutRelativeWidth, rhs: any KeyboardLayoutRelativeWidth) {
        self.lhs = AnyKeyboardLayoutRelativeWidth(lhs)
        self.rhs = AnyKeyboardLayoutRelativeWidth(rhs)
    }

    func value(in containerWidth: CGFloat, environment: KeyboardLayoutEnvironment) -> CGFloat {
        let lhs_value = lhs.value(in: containerWidth, environment: environment)
        let rhs_value = rhs.value(in: containerWidth, environment: environment)
        return (lhs_value + rhs_value) * signMultiplier()
    }

    private func signMultiplier() -> CGFloat {
        switch sign {
        case .plus: 1.0
        case .minus: -1.0
        }
    }

    static prefix func - (value: KeyboardLayoutRelativeWidthCompound) -> KeyboardLayoutRelativeWidthCompound {
        var value = value
        switch value.sign {
        case .plus:
            value.sign = .minus
        case .minus:
            value.sign = .plus
        }
        return value
    }
}

extension KeyboardLayoutRelativeWidth where Self == KeyboardLayoutRelativeWidthCompound {
    static func compound(
        _ lhs: any KeyboardLayoutRelativeWidth,
        _ rhs: any KeyboardLayoutRelativeWidth
    ) -> Self {
        KeyboardLayoutRelativeWidthCompound(
            lhs: lhs,
            rhs: rhs
        )
    }
}
