//
//  KeyboardLayoutRelativeWidthFixed.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutRelativeWidthFixed: KeyboardLayoutRelativeWidth {
    let value: CGFloat

    init(value: CGFloat) {
        self.value = value
    }

    func value(
        in containerWidth: CGFloat,
        environment: KeyboardLayoutEnvironment
    ) -> CGFloat {
        self.value * signMultiplier()
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

extension KeyboardLayoutRelativeWidth where Self == KeyboardLayoutRelativeWidthFixed {

    static func fixed(_ value: CGFloat) -> Self {
        KeyboardLayoutRelativeWidthFixed(value: value)
    }
}
