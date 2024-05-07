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
    
    static let keyboardCollectionView = XCUIApplication().collectionViews[.shared.keyboard.collectionView]
    static let keyboardTextView = XCUIApplication().textViews[.shared.keyboard.outputTextView]
    static let favoriteButton = XCUIApplication().buttons[.shared.keyboard.favoriteButton]
    static let checkmarkAddButton = XCUIApplication().buttons[.shared.keyboard.saveButton]
    static let createDuplicateButton = XCUIApplication().buttons[.shared.alert.createDuplicateButton]
    
    static func typeText(
        _ textToType: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // Ensure the keyboard is visible on screen before tapping any cells
        if !keyboardCollectionView.waitForExistence(timeout: 0.5) {
            XCTFail("Failed to locate keyboard", file: file, line: line)
            return
        }
        
        for char in textToType {
            keyboardCollectionView.cells[.shared.keyboard.key("\(char)")].tap()
        }
    }
    
    static func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
