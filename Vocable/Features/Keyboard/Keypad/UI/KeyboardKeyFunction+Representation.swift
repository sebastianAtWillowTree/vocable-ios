//
//  KeyboardKeyFunction.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardKeyFunction {

    enum Representation: Hashable {
        case image(UIImage)
        case string(String)
    }

    var representation: Representation {
        return switch self {
        case .clear:
            .image(UIImage(systemName: "trash")!)
        case .backspace:
            .image(UIImage(systemName: "delete.left")!)
        case .space:
            .image(UIImage(systemName: "space")!)
        case .speak:
            .image(UIImage(systemName: "person.wave.2.fill")!)
        case .numberPad:
            .image(UIImage(systemName: "textformat.123")!)
        case .alphabet:
            .image(UIImage(systemName: "abc")!)
        case .openModifierPicker, .closeModifierPicker:
            .image(UIImage(systemName: "ellipsis")!)
        case .beginModifier(let value), .endModifier(let value):
            .string("\u{25CC}\(value)")
        }
    }

    var accessibilityID: String {
        return switch self {
        case .clear: "clear"
        case .backspace: "backspace"
        case .space: "space"
        case .speak: "speak"
        case .numberPad: "numpad"
        case .alphabet: "alphabet"
        case .openModifierPicker, .closeModifierPicker: "extended-alphabet-toggle"
        case .beginModifier(let value): "begin-modifier-\(value)"
        case .endModifier(let value): "end-modifier-\(value)"
        }
    }
}
