//
//  KeyboardLayoutKey.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutKey: Hashable, KeyboardLayoutElement {

    typealias Action = KeyboardKeyAction

    private(set) var environment: KeyboardLayoutEnvironment = .init()

    var children: [any KeyboardLayoutElement] {
        get {
            []
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // no-op
        }
    }

    func makeKeys(environment: KeyboardLayoutEnvironment) -> [KeyboardLayoutKey] {
        var result = self
        result.environment = environment
        return [result]
    }

    private(set) var action: Action

    init(_ value: Character) {
        self.init(.insertCharacter(value))
    }

    init(_ action: Action) {
        self.action = action
    }

    func withModifier(modifier: Character?) -> KeyboardLayoutKey {
        guard let modifier else {
            return self
        }
        var result = self
        if case .insertCharacter(let character) = result.action {
            var unicodeScalars = character.unicodeScalars
            unicodeScalars.append(contentsOf: modifier.unicodeScalars)
            if let newValue = String(unicodeScalars).first {
                result.action = .insertCharacter(newValue)
            }
        }
        return result
    }
}
