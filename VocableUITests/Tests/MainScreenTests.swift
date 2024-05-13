//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Updated by Rudy Salas, Canan Arikan, and Rhonda Oglesby on 03/30/2022
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: XCTestCase {
    
    let firstTestCategory = Category(id: "first_category", "First") {
        Phrase(id: "phrase_one", "Please help")
    }
    
    let secondTestCategory = Category(id: "second_category", "To Be Hidden") {
        Phrase(id: "phrase_two", "Hello")
    }
    
    let thirdTestCategory = Category(id: "third_category", "Third") {
        Phrase(id: "phrase_three", "I need a blanket")
    }
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode, .disableAnimations)
            Environment(.overridePresets) {
                Presets {
                    firstTestCategory
                    secondTestCategory
                    thirdTestCategory
                }
            }
        }
        app.launch()
    }
    
    func testSelectingCategoryChangesPhrases() {
        let firstCategory = CategoryIdentifier(firstTestCategory.presetCategory.id)
        let secondCategory = CategoryIdentifier(secondTestCategory.presetCategory.id)
        
        // Navigate to a category and grab it's first, top most, phrase.
        MainScreen.locateAndSelectDestinationCategory(firstCategory)
        let phraseOne = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertEqual(phraseOne, firstTestCategory.presetPhrases[0].utterance)
        
        // Navigate to a different category and verify the top most phrase listed has changed.
        MainScreen.locateAndSelectDestinationCategory(secondCategory)
        let phraseTwo = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertEqual(phraseTwo, secondTestCategory.presetPhrases[0].utterance)
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() throws {
        let customTestCategories = [firstTestCategory,
                                    secondTestCategory,
                                    thirdTestCategory]
        for category in customTestCategories {
            let phrase = category.presetPhrases[0]
            MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(category.presetCategory.id))
            try app.collectionViews.staticTexts.element(boundBy: 0).assertExistence(timeout: 1.0)
            try app.cells[phrase.id].tapWhenExists()
            XCTAssertEqual(MainScreen.outputText.label, phrase.utterance)
        }
    }
    
    func testDisablingCategory() throws {
        let hiddenCategory = secondTestCategory
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.locateCategoryCell(hiddenCategory.presetCategory.utterance)

        // Navigate to the category and hide it.
        try SettingsScreen.openCategorySettings(category: hiddenCategory.presetCategory.utterance)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        
        // Return to the main screen
        try CustomCategoriesScreen.returnToMainScreenFromCategoryDetails()
        
        // Confirm that the category is no longer accessible.
        let isVisible = MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(hiddenCategory.presetCategory.id))
        XCTAssertFalse(isVisible)
    }
    
}
