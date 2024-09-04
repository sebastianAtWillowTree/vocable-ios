//
//  KeyboardLayoutElement+Environment.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension KeyboardLayoutElement {
    func environment<T>(_ keyPath: WritableKeyPath<KeyboardLayoutEnvironment, T>, _ value: T) -> some KeyboardLayoutElement {
        KeyboardLayoutEnvironmentModifier(content: self) { env in
            env[keyPath: keyPath] = value
        }
    }

    func mutatingEnvironment(_ t: @escaping (inout KeyboardLayoutEnvironment) -> Void) -> some KeyboardLayoutElement {
        KeyboardLayoutEnvironmentModifier(content: self, transform: t)
    }
}

private struct KeyboardLayoutEnvironmentModifier<Content: KeyboardLayoutElement>: KeyboardLayoutElement {
    private(set) var content: Content
    let transform: (inout KeyboardLayoutEnvironment) -> Void

    func makeKeys(environment: KeyboardLayoutEnvironment) -> [KeyboardLayoutKey] {
        var newEnvironment = environment
        transform(&newEnvironment)
        let merged = newEnvironment.merging(ancestor: environment)
        return content.makeKeys(environment: merged)
    }

    var children: [any KeyboardLayoutElement] {
        get {
            [content]
        }
        set {
            if let converted = newValue.first as? Content {
                content = converted
            }
        }
    }
}
