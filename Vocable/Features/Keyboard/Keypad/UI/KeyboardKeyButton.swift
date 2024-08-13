//
//  KeyboardKeyButton.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardView {

    final class KeyButton: GazeableButton {
        let identifier: KeyboardLayoutKey

        init(identifier: KeyboardLayoutKey) {
            self.identifier = identifier
            super.init(frame: .zero)

            switch identifier.content {
            case .string(let string):
                self.setTitle(String(string), for: .normal)
            case .function(let keyboardFunctionKey):
                switch keyboardFunctionKey.representation {
                case .image(let uIImage):
                    self.setImage(uIImage, for: .normal)
                case .string(let string):
                    self.setTitle(String(string), for: .normal)
                }
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func updateConfiguration() {
            font = .keyboardKey(satisfying: traitCollection)
            updateConfigurationForKeyFunction()

            super.updateConfiguration()
            self.configuration?.titleAlignment = .automatic
            self.configuration?.contentInsets = .zero
            self.contentVerticalAlignment = .fill
        }

        private func isHighlightedFunction(_ function: KeyboardKeyFunction) -> Bool {
            switch function {
            case .speak, .closeModifierPicker, .endModifier:
                true
            default:
                false
            }
        }
        
        private func updateConfigurationForKeyFunction() {
            
            guard case let .function(functionType) = identifier.content else {
                fillColor = .defaultCellBackgroundColor
                foregroundColor = .defaultTextColor
                return
            }

            if isHighlightedFunction(functionType) {
                // Makes the key a bright blue color for more prominence
                fillColor = .highlightedTextColor ?? self.fillColor
                foregroundColor = .collectionViewBackgroundColor
            } else {
                // Makes the key a slightly lighter color to distinguish it
                // from others as being a function key rather than a character key
                fillColor = .categoryBackgroundColor
                foregroundColor = .defaultTextColor
            }

            if functionType == .speak {
                updateSpeakFunctionSymbolEffect()
            }
        }

        private func updateSpeakFunctionSymbolEffect() {
            if #available(iOS 17.0, *) {
                if traitCollection.isSpeaking {
                    imageView?.addSymbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                } else {
                    imageView?.removeAllSymbolEffects()
                }
            }
        }
    }

}
