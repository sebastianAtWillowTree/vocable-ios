//
//  AccessibilityID+Shared+Keyboard.swift
//  Vocable
//
//  Created by Rudy Salas on 5/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.shared {
    public struct keyboard {
        public static let outputTextView: AccessibilityID = "keyboard-text-view"
        public static let favoriteButton: AccessibilityID = "favorite-button"
        public static let saveButton: AccessibilityID = "checkmark-save-button"
        public static let collectionView: AccessibilityID = "keyboard-collection-view"
        
        public static func key(_ value: String) -> AccessibilityID {
            AccessibilityID(stringLiteral: "keyboard_key_\(value.lowercased())")
        }
        
        private init() {}
    }
}
