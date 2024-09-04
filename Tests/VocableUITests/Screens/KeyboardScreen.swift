//
//  KeyboardScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreen: BaseScreen {
    private static let app = XCUIApplication()
    
    static let keyboardView = XCUIApplication().otherElements[.shared.keyboard.view]
    static let keyboardTextView = XCUIApplication().textViews[.shared.keyboard.outputTextView]
    static let favoriteButton = XCUIApplication().buttons[.shared.keyboard.favoriteButton]
    static let checkmarkAddButton = XCUIApplication().buttons[.shared.keyboard.saveButton]
    static let createDuplicateButton = XCUIApplication().buttons[.shared.alert.createDuplicateButton]
    
    static func typeText(
        _ textToType: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        // Ensure the keyboard is visible on screen before tapping any cells
        try keyboardView.assertExistence(
            timeout: 0.5,
            "Failed to locate keyboard",
            file: file,
            line: line
        )
        
        // The entire keyboard is visible by design, so it is okay to
        // not wait for the existence of each cell before tapping. It's
        // a minor optimization, but the savings add up.
        for char in textToType.uppercased() {
            keyboardView.buttons[.shared.keyboard.key(.insertCharacter(char))].tap()
        }
    }
    
    static func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
