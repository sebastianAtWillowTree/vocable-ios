//
//  StandardKeyboardLayoutIT.swift
//  Vocable
//
//  Created by Chris Stroud on 6/3/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import SwiftUI

struct StandardKeyboardLayoutIT: KeyboardLayout {

    let identifier = "standard_layout_IT"
    
    func makeLayout(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardBody {
        switch configuration.mode {
        case .alphabetical:
            KeyboardLayoutRow {
                for key in "QWERTYUIOP" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 10)
                }
            }
            KeyboardLayoutRow {
                for key in "ASDFGHJKL" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 10)
                }
            }
            KeyboardLayoutRow {
                for key in "ZXCVBNM" {
                    KeyboardLayoutKey(value: key)
                        .keyWidth(count: 10)
                }
                backspaceButton
                    .padding(
                        leading: .columns(200, span: 6)
                    )
            }
            .padding(
                leading: .columns(200, span: 33)
            )
        case .modifierPicker:
            KeyboardLayoutRow {
                KeyboardLayoutKey(function: .beginModifier("\u{0300}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0301}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0302}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0303}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0306}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0307}"))
            }
            .keyWidth(count: 6)
            KeyboardLayoutRow {
                KeyboardLayoutKey(function: .beginModifier("\u{0308}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0309}"))
                KeyboardLayoutKey(function: .beginModifier("\u{030A}"))
                KeyboardLayoutKey(function: .beginModifier("\u{030B}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0311}"))
                KeyboardLayoutKey(function: .beginModifier("\u{0313}"))
            }
            .keyWidth(count: 6)
            KeyboardLayoutRow {
                backspaceButton
            }
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
                        .keyWidth(count: 8)
                }
                backspaceButton
                    .padding(
                        leading: .columns(200, span: 13)
                    )
            }
            .padding(
                leading: .columns(200, span: 40)
            )
        }

        KeyboardLayoutRow {
            KeyboardLayoutKey(function: configuration.mode == .alphabetical ? .numberPad : .alphabet)
                .keyWidth(span: 10)
            KeyboardLayoutKey(function: .space)
                .keyWidth(span: 20)
            KeyboardLayoutKey(function: .speak)
                .keyWidth(span: 10)
        }
        .keyWidth(count: 40)
    }

    private var backspaceButton: some KeyboardLayoutElement {
        KeyboardLayoutKey(
            function: .backspace
        )
        .keyWidth(count: 40, span: 6)
    }
}

#Preview {
    KeyboardLayoutPreviewView(
        layout: StandardKeyboardLayoutIT(),
        mode: .numerical
    )
}
