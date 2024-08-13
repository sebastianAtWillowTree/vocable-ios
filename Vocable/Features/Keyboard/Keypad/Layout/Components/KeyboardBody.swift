//
//  KeyboardBody.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardBody {
    private(set) var root: any KeyboardLayoutElement

    init(root: any KeyboardLayoutElement) {
        self.root = root
        var baseIndex = 0
        KeyboardBody.rebaseElement(&self.root, baseRowIndex: &baseIndex)
    }

    private static func rebaseElement(
        _ element: inout any KeyboardLayoutElement,
        baseRowIndex: inout Int
    ) {
        if let row = element as? KeyboardLayoutRow {
            element = row.withIndex(baseRowIndex)
            baseRowIndex += 1
        }
        for index in element.children.indices {
            rebaseElement(
                &element.children[index],
                baseRowIndex: &baseRowIndex
            )
        }
    }
}
