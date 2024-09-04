//
//  KeyboardSuggestionButton.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension KeyboardSuggestionsView {
    final class SuggestionButton: GazeableButton {
        override func updateConfiguration() {
            fillColor = .categoryBackgroundColor
            font = .keyboardKey(satisfying: traitCollection)
            super.updateConfiguration()
            configuration?.titleLineBreakMode = .byTruncatingTail
        }
    }
}
