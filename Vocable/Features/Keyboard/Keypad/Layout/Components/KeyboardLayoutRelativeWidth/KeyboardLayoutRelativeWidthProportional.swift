//
//  KeyboardLayoutRelativeWidthProportional.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutRelativeWidthProportional: KeyboardLayoutRelativeWidth {    

    let multiplier: CGFloat

    init(multiplier: CGFloat) {
        self.multiplier = multiplier
    }

    func value(
        in containerWidth: CGFloat,
        environment: KeyboardLayoutEnvironment
    ) -> CGFloat {
        max(containerWidth * multiplier, .zero) * signMultiplier()
    }

    private var sign: FloatingPointSign = .plus

    private func signMultiplier() -> CGFloat {
        switch sign {
        case .plus: 1.0
        case .minus: -1.0
        }
    }

    static prefix func - (value: Self) -> Self {
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

extension KeyboardLayoutRelativeWidth where Self == KeyboardLayoutRelativeWidthProportional {

    static var zero: Self {
        KeyboardLayoutRelativeWidthProportional(multiplier: .zero)
    }

    static func proportional(_ multiplier: CGFloat) -> Self {
        KeyboardLayoutRelativeWidthProportional(multiplier: multiplier)
    }
}
