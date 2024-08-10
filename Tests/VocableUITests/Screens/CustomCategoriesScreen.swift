//
//  CustomCategoriesScreen.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Updated by Canan Arikan and Rudy Salas on 04/07/2022
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesScreen: BaseScreen {
    
    static let categoriesPageAddPhraseButton = XCUIApplication().buttons[.settings.editPhrases.addPhraseButton]
    static let editCategoryPhrasesButton = XCUIApplication().buttons[.settings.editCategoryDetails.editPhrasesButton]
    static let categoriesPageDeletePhraseButton = XCUIApplication().buttons[.settings.editPhrases.deletePhraseButton]

    static var firstPhraseCell: XCUIElement {
        let firstPhraseId = XCUIApplication().cells.firstMatch.identifier
        return XCUIApplication().cells[firstPhraseId]
    }
    
    static func phraseCell(_ phraseId: String) -> XCUIElementQuery {
        return XCUIApplication().cells.matching(identifier: phraseId)
    }
    
    static func createCustomCategory(
        categoryName: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try SettingsScreen.addCategoryButton.tapWhenExists(file: file, line: line)
        try KeyboardScreen.typeText(categoryName, file: file, line: line)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists(file: file, line: line)
    }
    
    static func createAndLocateCustomCategory(
        _ categoryName: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> CategoryIdentifier {
        try createCustomCategory(categoryName: categoryName, file: file, line: line)
        let customCategoryIdentifier = try SettingsScreen.locateCategoryCell(categoryName, file: file, line: line).identifier
        return CategoryIdentifier(customCategoryIdentifier)
    }
    
    static func addPhrase(
        _ phrase: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try categoriesPageAddPhraseButton.tapWhenExists(file: file, line: line)
        try KeyboardScreen.checkmarkAddButton.assertExistence(timeout: 1.0, file: file, line: line)
        try KeyboardScreen.typeText(phrase, file: file, line: line)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists(file: file, line: line)
    }
    
    static func addRandomPhrases(
        numberOfPhrases: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        for _ in 1...numberOfPhrases {
            let randomPhrase = KeyboardScreen.randomString(length: 2)
            try categoriesPageAddPhraseButton.tapWhenExists(file: file, line: line)
            try KeyboardScreen.typeText(randomPhrase, file: file, line: line)
            try KeyboardScreen.checkmarkAddButton.tapWhenExists(file: file, line: line)
        }
        try categoriesPageAddPhraseButton.assertExistence(timeout: 1.0, file: file, line: line)
    }
    
    static func returnToMainScreenFromCategoriesList(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        // Exit the Edit Categories and Settings Screens
        try navBarBackButton.tapWhenExists(file: file, line: line)
        try navBarDismissButton.tapWhenExists(file: file, line: line)
        
        // Wait for the Main Screen to appear
        try MainScreen.settingsButton.assertExistence(
            timeout: 1.0,
            "Did not return to main screen as expected",
            file: file,
            line: line
        )
    }
    
    static func returnToMainScreenFromCategoryDetails(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try navBarBackButton.tapWhenExists(file: file, line: line)
        try returnToMainScreenFromCategoriesList(file: file, line: line)
    }
    
    static func returnToMainScreenFromEditPhrases(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try navBarBackButton.tapWhenExists(file: file, line: line)
        try returnToMainScreenFromCategoryDetails(file: file, line: line)
    }
    
    static func navigateToSettingsCategoryScreenFromCategoryEditPhrases(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        // Exit the Edit Phrases and Category Detail Screens
        try navBarBackButton.tapWhenExists(file: file, line: line)
        try navBarBackButton.tapWhenExists(file: file, line: line)
        
        // Wait for the Categories Screen to appear
        try SettingsScreen.addCategoryButton.assertExistence(
            timeout: 1.0,
            "Did not return to Settings Categories Screen as expected.",
            file: file,
            line: line
        )
    }
    
}
