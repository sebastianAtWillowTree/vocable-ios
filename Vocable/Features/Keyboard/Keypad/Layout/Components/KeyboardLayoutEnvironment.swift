//
//  KeyboardLayoutEnvironment.swift
//  Vocable
//
//  Created by Chris Stroud on 6/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutEnvironment: CustomDebugStringConvertible, Hashable {

    enum KeySizingStrategy: Hashable {
        case columns
        case proportional(multiplier: CGFloat)
    }

    @Attribute
    var columnCount: Int = 1

    @Attribute
    var spanCount: Int = 1

    @Attribute
    var spacing: CGFloat = 6.0

    @Attribute
    var padding: KeyboardLayoutDirectionalInsets = .init(leading: .zero, trailing: .zero)

    @Attribute
    var rowIndex: Int = .zero

    @Attribute
    var keySizingStrategy: KeySizingStrategy = .columns

    func keyWidth(containerWidth: CGFloat) -> CGFloat {
        let relativeWidth: any KeyboardLayoutRelativeWidth = switch keySizingStrategy {
        case .columns:
            KeyboardLayoutRelativeWidthSpan(columns: columnCount, span: spanCount, spacing: spacing)
        case .proportional(let multiplier):
            KeyboardLayoutRelativeWidthProportional(multiplier: multiplier)
        }
        return relativeWidth.value(
            in: containerWidth,
            environment: self
        )
    }

    private mutating func merge<T>(
        _ keyPath: WritableKeyPath<KeyboardLayoutEnvironment, KeyboardLayoutEnvironment.Attribute<T>>,
        ancestor: KeyboardLayoutEnvironment
    ) {
        let ancestorAttr = ancestor[keyPath: keyPath]
        self[keyPath: keyPath].merge(with: ancestorAttr)
    }

    func merging(ancestor: KeyboardLayoutEnvironment) -> KeyboardLayoutEnvironment {
        var result = self
        result.merge(\._columnCount, ancestor: ancestor)
        result.merge(\._spanCount, ancestor: ancestor)
        result.merge(\._spacing, ancestor: ancestor)
        result.merge(\._padding, ancestor: ancestor)
        result.merge(\._rowIndex, ancestor: ancestor)
        result.merge(\._keySizingStrategy, ancestor: ancestor)
        return result
    }

    var debugDescription: String {
        """
        KeyboardLayoutEnvironment {
            columnCount: \(columnCount),
            span: \(spanCount),
            spacing: \(spacing),
            padding: \(padding),
            rowIndex: \(rowIndex)
        }
        """
    }
}

extension KeyboardLayoutEnvironment {
    @propertyWrapper
    struct Attribute<T: Hashable>: Hashable {

        private enum StoredValue: Hashable {
            case unspecified
            case assigned(T)
        }

        private var storage: StoredValue = .unspecified
        private let defaultValue: T

        var wrappedValue: T {
            get {
                return switch storage {
                case .unspecified:
                    defaultValue
                case .assigned(let value):
                    value
                }
            }
            set {
                storage = .assigned(newValue)
            }
        }

        var projectedValue: Attribute<T> {
            self
        }

        init(wrappedValue: T) {
            self.defaultValue = wrappedValue
        }

        func merged(with ancestor: Attribute<T>) -> Attribute<T> {
            var result = self
            result.merge(with: ancestor)
            return result
        }

        mutating func merge(with ancestor: Attribute<T>) {
            if case .unspecified = storage {
                storage = ancestor.storage
            }
        }
    }
}
