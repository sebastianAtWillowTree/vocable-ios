//
//  KeyboardLayoutContentBuilder.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

@resultBuilder
struct KeyboardLayoutContent {

    static func buildBlock(_ components: (any KeyboardLayoutElement)...) -> [any KeyboardLayoutElement] {
        components
    }

    static func buildExpression(_ expression: any KeyboardLayoutElement) -> [any KeyboardLayoutElement] {
        [expression]
    }

    static func buildExpression(_ expression: [any KeyboardLayoutElement]) -> [any KeyboardLayoutElement] {
        expression
    }

    static func buildEither(first component: [any KeyboardLayoutElement]) -> [any KeyboardLayoutElement] {
        component
    }

    static func buildEither(second component: [any KeyboardLayoutElement]) -> [any KeyboardLayoutElement] {
        component
    }

    static func buildArray(_ components: [[any KeyboardLayoutElement]]) -> [any KeyboardLayoutElement] {
        Array(components.joined())
    }

    static func buildOptional(_ component: [any KeyboardLayoutElement]?) -> [any KeyboardLayoutElement] {
        component ?? []
    }

    static func buildFinalResult(_ component: [any KeyboardLayoutElement]) -> [any KeyboardLayoutElement] {
        component
    }

    static func buildPartialBlock(first: [any KeyboardLayoutElement]) -> [any KeyboardLayoutElement] {
        first
    }

    static func buildPartialBlock(
        accumulated: [any KeyboardLayoutElement],
        next: [any KeyboardLayoutElement]
    ) -> [any KeyboardLayoutElement] {
        accumulated + next
    }
}
