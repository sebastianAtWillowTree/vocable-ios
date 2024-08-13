//
//  KeyboardLayoutRow.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutRow: KeyboardLayoutElement {

    private(set) var index: Int = .zero
    var children: [any KeyboardLayoutElement]

    let debugID: String

    init(
        debugID: String = "",
        @KeyboardLayoutContent builder: () -> [any KeyboardLayoutElement]
    ) {
        self.debugID = debugID
        self.children = builder()
    }

    func makeKeys(environment: KeyboardLayoutEnvironment) -> [KeyboardLayoutKey] {

        var childEnvironment = environment
        childEnvironment.padding = .zero

        return children
            .indexed()
            .flatMap { (keyIndex, child) in
                child.mutatingEnvironment { env in
                    env.rowIndex = index
                    if keyIndex == children.indices.first {
                        env.padding.leading += environment.padding.leading
                    }
                    if keyIndex == children.indices.last {
                        env.padding.trailing += environment.padding.trailing
                    }
                }
                .makeKeys(environment: childEnvironment)
            }
    }

    func withIndex(_ index: Int) -> KeyboardLayoutRow {
        var result = self
        result.index = index
        return result
    }
}
