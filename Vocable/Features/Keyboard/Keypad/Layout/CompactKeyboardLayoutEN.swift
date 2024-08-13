//
//  CompactKeyboardLayoutEN.swift
//  Vocable
//
//  Created by Chris Stroud on 6/12/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import SwiftUI
import Collections

struct CompactKeyboardLayoutEN: KeyboardLayout {

    let identifier = "compact_layout_EN"

    func makeLayout(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardBody {
        switch configuration.mode {
        case .alphabetical:
            let values = "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.?"
            KeyboardLayoutGroup {
                for row in values.chunks(ofCount: 6) {
                    KeyboardLayoutRow {
                        for key in row {
                            KeyboardLayoutKey(value: key)
                        }
                    }
                }
                KeyboardLayoutRow {
                    for key in "()!\"" {
                        KeyboardLayoutKey(value: key)
                    }
                    KeyboardLayoutKey(function: .backspace)
                        .keyWidth(span: 2)
                }
            }
            .keyWidth(count: 6)
        case .numerical:
            let values = "123456789"
            for row in values.chunks(ofCount: 3) {
                KeyboardLayoutRow {
                    for key in row {
                        KeyboardLayoutKey(value: key)
                            .keyWidth(count: 3)
                    }
                }
            }
            KeyboardLayoutRow {
                KeyboardLayoutKey(value: ".")
                KeyboardLayoutKey(value: "0")
                KeyboardLayoutKey(function: .backspace)
            }
            .keyWidth(count: 3)
        case .modifierPicker:
            KeyboardLayoutGroup { }
        }
        KeyboardLayoutRow {
            KeyboardLayoutKey(
                function: configuration.mode == .alphabetical ? .numberPad : .alphabet
            )
            .keyWidth(span: 3)
            KeyboardLayoutKey(function: .space)
                .keyWidth(span: 6)
            KeyboardLayoutKey(function: .speak)
                .keyWidth(span: 3)
        }
        .keyWidth(count: 12)
    }
}

#Preview {
    KeyboardLayoutPreviewView(
        layout: CompactKeyboardLayoutEN(),
        mode: .alphabetical
    )
}
