//
//  KeyboardLayoutBuilders.swift
//  Vocable
//
//  Created by Chris Stroud on 5/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

@resultBuilder
struct KeyboardBuilder {

    typealias Result = KeyboardBody
    typealias Row = (any KeyboardLayoutElement)

    struct Partial {
        var element: any KeyboardLayoutElement
        var lastRowIndex: Int = .zero

        init(element: any KeyboardLayoutElement, baseRowIndex: Int = .zero) {
            self.lastRowIndex = baseRowIndex
            self.element = element
        }

        init(elements: [any KeyboardLayoutElement], baseRowIndex: Int = .zero) {
            self.init(
                element: KeyboardLayoutGroup(children: elements),
                baseRowIndex: baseRowIndex
            )
        }
    }

    // MARK: Keys

    static func buildBlock(_ components: Row...) -> Partial {
        Partial(elements: components)
    }

    static func buildExpression(_ expression: Row) -> Partial {
        Partial(element: expression)
    }

    static func buildExpression(_ expression: Partial) -> Partial {
        expression
    }

    static func buildEither(first component: Partial) -> Partial {
        component
    }

    static func buildEither(second component: Partial) -> Partial {
        component
    }

    static func buildArray(_ components: [any KeyboardLayoutElement]) -> Partial {
        Partial(elements: components)
    }

    static func buildArray(_ components: [Partial]) -> Partial {
        Partial(elements: components.map(\.element))
    }

    static func buildOptional(_ component: Row?) -> Partial {
        Partial(elements: Array([component].compacted()))
    }

    static func buildPartialBlock(first: Partial) -> Partial {
        first
    }

    static func buildPartialBlock(accumulated: Partial, next: Partial) -> Partial {
        Partial(elements: [accumulated.element, next.element])
    }

    static func buildFinalResult(_ component: Partial) -> Result {
        return Result(root: component.element)
    }
}
