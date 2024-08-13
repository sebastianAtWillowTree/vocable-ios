//
//  KeyboardLayoutKey.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutKey: Hashable, KeyboardLayoutElement {

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

    enum Content: Hashable {
        case string(Character)
        case function(KeyboardKeyFunction)
    }

    private(set) var content: Content

    init(function: KeyboardKeyFunction) {
        self.init(content: .function(function))
    }

    init(value: Character) {
        self.init(content: .string(value))
    }

    private init(content: Content) {
        self.content = content
    }

    func withModifier(modifier: Character?) -> KeyboardLayoutKey {
        guard let modifier else {
            return self
        }
        var result = self
        if case .string(let character) = result.content {
            var unicodeScalars = character.unicodeScalars
            unicodeScalars.append(contentsOf: modifier.unicodeScalars)
            if let newValue = String(unicodeScalars).first {
                result.content = .string(newValue)
            }
        }
        return result
    }
}
