//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Updated by Rudy Salas and Canan Arikan on 05/16/2022.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomPhraseTests: XCTestCase {

    let editableCategory = Category("Test") {
        Phrase("Hello")
    }
    
    let emptyCategory = Category("Empty") {
        // Empty
    }
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
            Environment(.overridePresets) {
                Presets {
                    editableCategory
                    emptyCategory
                }
            }
        }
        app.launch()
    }
    
    func testAddNewPhrase() throws {
        let customPhrase = "dd"
        
        // Navigate to our test category
        try MainScreen.navigateToSettingsAndOpenCategory(name: emptyCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()

        // Verify Phrase is not added if edits are discarded
        try CustomCategoriesScreen.categoriesPageAddPhraseButton.tapWhenExists()
        try KeyboardScreen.typeText("A")
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        try KeyboardScreen.alertMessageLabel.assertExistence()

        try SettingsScreen.alertDiscardButton.tapWhenExists()
        try CustomCategoriesScreen.emptyStateAddPhraseButton.assertExistence()

        // Verify Phrase can be added if continuing edit
        try CustomCategoriesScreen.categoriesPageAddPhraseButton.tapWhenExists()
        try KeyboardScreen.typeText("A")
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        try KeyboardScreen.alertMessageLabel.assertExistence()
        try SettingsScreen.alertContinueButton.tapWhenExists()

        try KeyboardScreen.typeText(customPhrase)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()

        XCTAssert(MainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() throws {
        let editSuffix = "test"
        let phraseId = editableCategory.presetPhrases[0].id
        let updatedPhrase = editableCategory.presetPhrases[0].utterance + editSuffix
        
        // Navigate to our test category
        try MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        
        // Edit an existing phrase
        try CustomCategoriesScreen.phraseCell(phraseId).buttons[.settings.editPhrases.editPhraseButton].tapWhenExists()
        try KeyboardScreen.typeText("test")
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
        
        // Verify phrase has been updated
        XCTAssert(MainScreen.isTextDisplayed(updatedPhrase), "Expected the phrase \(updatedPhrase) to be displayed")
    }
    
    func testDeleteCustomPhrase() throws {
        try MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        
        try CustomCategoriesScreen.categoriesPageDeletePhraseButton.tapWhenExists()
        try SettingsScreen.alertDeleteButton.tapWhenExists()
        try CustomCategoriesScreen.emptyStateAddPhraseButton.assertExistence(timeout: 0.5, "Expected the phrase to be deleted")
    }
    
    func testCanAddDuplicatePhrasesToCategories() throws {
        // Navigate to our test category.
        try MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()

        // Duplicate the phrase in this category.
        let originalPhraseId = editableCategory.presetPhrases[0].id
        let duplicatedPhrase = editableCategory.presetPhrases[0].utterance
        try CustomCategoriesScreen.addPhrase(duplicatedPhrase)
        try KeyboardScreen.createDuplicateButton.tapWhenExists()
        
        // Wait for the keyboard to dismiss.
        try CustomCategoriesScreen.navBarBackButton.assertExistence(timeout: 1.0)
        
        // Verify we now have 2 phrases, with matching labels, but unique identifiers.
        let allPhraseCells = XCUIApplication().cells
        XCTAssertEqual(allPhraseCells.count, 2)
        XCTAssertEqual(allPhraseCells.matching(identifier: originalPhraseId).count, 1)
        XCTAssertEqual(allPhraseCells.staticTexts.matching(identifier: duplicatedPhrase).count, 2)
    }
    
}
