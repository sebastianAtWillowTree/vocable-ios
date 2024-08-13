//
//  KeyboardLayoutGroup.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutGroup: KeyboardLayoutElement {

    var children: [any KeyboardLayoutElement]

    init(children: [any KeyboardLayoutElement]) {
        self.children = children
    }

    init(@KeyboardLayoutContent builder: () -> [any KeyboardLayoutElement]) {
        self.init(children: builder())
    }

    func makeKeys(environment: KeyboardLayoutEnvironment) -> [KeyboardLayoutKey] {
        let indexed = children.indexed()
        return indexed.flatMap { (index, key) -> [KeyboardLayoutKey] in
            let isFirst = (index == indexed.startIndex)
            let isLast = (index == indexed.endIndex)
            return if isFirst && isLast {
                key.makeKeys(environment: environment)
            } else if isFirst {
                key.environment(\.padding.trailing, .zero)
                    .makeKeys(environment: environment)
            } else if isLast {
                key.environment(\.padding.leading, .zero)
                    .makeKeys(environment: environment)
            } else {
                key.environment(\.padding, .zero)
                    .makeKeys(environment: environment)
            }
        }
    }
}
