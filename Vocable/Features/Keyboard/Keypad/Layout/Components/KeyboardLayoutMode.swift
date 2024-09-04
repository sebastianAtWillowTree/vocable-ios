//
//  KeyboardLayoutMode.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

enum KeyboardLayoutMode: Equatable {
    case alphabetical
    case modifierPicker
    case numerical

    var isAlphabetical: Bool {
        self == .alphabetical
    }
}
