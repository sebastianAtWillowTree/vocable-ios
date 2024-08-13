//
//  StandardKeyboardLayoutEN.swift
//  Vocable
//
//  Created by Chris Stroud on 6/3/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import SwiftUI

struct StandardKeyboardLayoutEN: KeyboardLayout {

    let identifier = "standard_layout_EN"

    func makeLayout(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardBody {
        switch configuration.mode {
        case .alphabetical:
            KeyboardLayoutGroup {
                KeyboardLayoutRow(debugID: "top") {
                    for key in "QWERTYUIOP" {
                        KeyboardLayoutKey(value: key)
                    }
                }
                KeyboardLayoutRow(debugID: "middle") {
                    for key in "ASDFGHJKL" {
                        KeyboardLayoutKey(value: key)
                    }
                }
                KeyboardLayoutRow(debugID: "bottom") {
                    KeyboardLayoutGroup {
                        for key in "ZXCVBNM" {
                            KeyboardLayoutKey(value: key)
                        }
                    }
                    .padding(
                        leading: .columns(80, span: 12)
                    )
                    backspaceKey()
                        .padding(
                            leading: .columns(80, span: 1)
                        )
                }
            }
            .keyWidth(count: 10)
        case .numerical:
            KeyboardLayoutRow {
                for key in "1234567890" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 10)
                }
            }
            KeyboardLayoutRow {
                for key in "-/:;()$&@\"" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 10)
                }
            }
            KeyboardLayoutRow {
                for key in ".,?!'" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 80, span: 11)
                }
                backspaceKey()
                    .padding(
                        leading: .columns(40, span: 1)
                    )
            }
            .padding(
                leading: .columns(40, span: 6)
            )
        case .modifierPicker: 
            KeyboardLayoutGroup { }
        }
        KeyboardLayoutRow(debugID: "function bottom") {
            KeyboardLayoutKey(function: configuration.mode == .alphabetical ? .numberPad : .alphabet)
            KeyboardLayoutKey(function: .space)
                .keyWidth(count: 4, span: 2)
            KeyboardLayoutKey(function: .speak)
        }
        .keyWidth(count: 4)
    }

    private func backspaceKey() -> some KeyboardLayoutElement {
        KeyboardLayoutKey(function: .backspace)
            .keyWidth(count: 60, span: 8)
    }
}

#Preview {
    KeyboardLayoutPreviewView(
        layout: StandardKeyboardLayoutEN(),
        mode: .numerical
    )
}
