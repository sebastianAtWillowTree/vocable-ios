//
//  KeyboardKeyFunction.swift
//  Vocable
//
//  Created by Chris Stroud on 8/2/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

enum KeyboardKeyFunction: Hashable {
    case clear
    case backspace
    case space
    case speak
    case numberPad
    case alphabet
    case openModifierPicker
    case closeModifierPicker
    case beginModifier(Character)
    case endModifier(Character)
}
