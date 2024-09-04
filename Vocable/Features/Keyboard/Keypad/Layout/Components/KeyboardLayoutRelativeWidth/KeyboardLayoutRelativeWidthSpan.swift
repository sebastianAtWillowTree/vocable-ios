//
//  KeyboardLayoutRelativeWidthSpan.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutRelativeWidthSpan: KeyboardLayoutRelativeWidth {

    private(set) var columns: Int?
    private(set) var span: Int?
    private(set) var spacing: CGFloat?

    init(columns: Int? = nil, span: Int? = nil, spacing: CGFloat? = nil) {
        self.columns = columns
        self.span = span
        self.spacing = spacing
    }

//    private indirect enum Scheme: Hashable {
//        case columns(count: Int? = nil, span: Int? = nil, spacing: CGFloat? = nil)
//        case proportional(multiplier: CGFloat)
//        case compound(KeyboardLayoutRelativeWidth, KeyboardLayoutRelativeWidth)
//
//        func value(
//            in containerWidth: CGFloat,
//            environment: KeyboardLayoutEnvironment
//        ) -> CGFloat {
//            switch self {
//            case .columns(let count, let span, let spacing):
//                let count = count ?? environment.columnCount
//                let span = max(span ?? environment.spanCount, 1) // must be at least 1
//                let spacing = spacing ?? environment.spacing
//                let availableLength = (containerWidth - (spacing * CGFloat(count - 1)))
//                let segmentLength = (availableLength / CGFloat(count))
//                let itemLength = (segmentLength * CGFloat(span)) + (CGFloat(span - 1) * spacing)
//                let result = max(itemLength, .zero)
//                guard result.isFinite else {
//                    return .zero
//                }
//                return result
//            case .proportional(let multiplier):
//                return max(containerWidth * multiplier, .zero)
//            case .compound(let lhs, let rhs):
//                let width_l = lhs.value(in: containerWidth, environment: environment)
//                let width_r = rhs.value(in: containerWidth, environment: environment)
//                return width_l + width_r
//            }
//        }
//    }

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

    func value(
        in containerWidth: CGFloat,
        environment: KeyboardLayoutEnvironment
    ) -> CGFloat {
        let count = columns ?? environment.columnCount
        let span = max(span ?? environment.spanCount, 1) // must be at least 1
        let spacing = spacing ?? environment.spacing
        let availableLength = (containerWidth - (spacing * CGFloat(count - 1)))
        let segmentLength = (availableLength / CGFloat(count))
        let itemLength = (segmentLength * CGFloat(span)) + (CGFloat(span - 1) * spacing)
        let result = max(itemLength, .zero)
        guard result.isFinite else {
            return .zero
        }
        return result * signMultiplier()
    }

}

extension KeyboardLayoutRelativeWidth where Self == KeyboardLayoutRelativeWidthSpan {

    static func columns(
        _ count: Int,
        span: Int? = nil,
        spacing: CGFloat? = nil
    ) -> Self {
        KeyboardLayoutRelativeWidthSpan(
            columns: count,
            span: span,
            spacing: spacing
        )
    }

    static func columns(
        span: Int,
        spacing: CGFloat? = nil
    ) -> Self {
        KeyboardLayoutRelativeWidthSpan(
            columns: nil,
            span: span,
            spacing: spacing
        )
    }

    static func columns(
        spacing: CGFloat
    ) -> Self {
        KeyboardLayoutRelativeWidthSpan(
            columns: nil,
            span: nil,
            spacing: spacing
        )
    }
}
