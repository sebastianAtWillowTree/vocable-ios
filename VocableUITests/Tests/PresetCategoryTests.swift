//
//  PresetCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 5/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PresetCategoryTests: BaseTest {
    let nameSuffix = "test"
    
    func testRenameCategory() throws {
        let categoryName = "General"
        let renamedCategory = categoryName + nameSuffix
        let categoryIdentifier = (CategoryIdentifier.general).identifier
        
        //Rename the preset category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: categoryName)
        try SettingsScreen.renameCategoryButton.tapWhenExists()
        try KeyboardScreen.typeText(nameSuffix)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
        XCTAssertEqual(SettingsScreen.title.label, renamedCategory)
        
        // Confirm that the category is renamed from categories list
        try SettingsScreen.navBarBackButton.tapWhenExists()
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(renamedCategory))
        
        // Confirm that the category is renamed from main screen
        try CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        MainScreen.locateAndSelectDestinationCategory(.general)
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        let query = XCUIApplication().cells.containing(isSelectedPredicate)
        XCTAssertEqual(query.staticTexts.element.label, renamedCategory)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryIdentifier)
    }
    
    func testRemoveCategory() throws {
        let categoryName = "Environment"
        
        //Remove the preset category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: categoryName)
        try SettingsScreen.removeCategoryButton.tapWhenExists()
        try SettingsScreen.alertRemoveButton.tapWhenExists()
        
        // Confirm that the category is removed from categories list
        try SettingsScreen.addCategoryButton.assertExistence(timeout: 0.5)
        XCTAssertFalse(try SettingsScreen.doesCategoryExist(categoryName))
        
        // Confirm that the category is removed from main screen
        try CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertFalse(MainScreen.locateAndSelectDestinationCategory(.environment))
    }
    
    func testShowHideButtonIsDisabledForMySayingsCategory() throws {
        let categoryName = "My Sayings"
        
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(SettingsScreen.showCategoryButton.isEnabled)
    }
    
    // For the first 5 preset categories, tap() the top left phrase, then verify that all selected phrases appear in "Recents"
    func testRecentScreen_ShowsPressedButtons() throws {
        var listOfSelectedPhrases: [String] = []
        var firstPhrase = ""
        let listOfCategoriesToSkip: [String] = [CategoryIdentifier.keyPad.identifier,
                                                CategoryIdentifier.mySayings.identifier,
                                                CategoryIdentifier.recents.identifier,
                                                CategoryIdentifier.listen.identifier]
        
        for categoryName in PresetCategories().list {
            
            // Skip the 123 (keypad), My Sayings, Recents, and Listen categories because their entries do not get added to 'Recents'
            if listOfCategoriesToSkip.contains(categoryName.identifier) {
                continue;
            }
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhrase].tap()
            listOfSelectedPhrases.append(firstPhrase)
        }
        MainScreen.locateAndSelectDestinationCategory(.recents)
        
        for phrase in listOfSelectedPhrases {
            try MainScreen.locatePhraseCell(phrase: phrase)
                .assertExistence("Expected \(phrase) to appear in Recents category")
        }
    }
    
    func testDefaultCategoriesExist() {
        for categoryName in PresetCategories().list {
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryName.identifier, "Preset category with ID '\(categoryName.identifier)' was not found")
        }
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        MainScreen.locateAndSelectDestinationCategory(.keyPad)
        let firstKeypadNumber = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstKeypadNumber].tap()
        XCTAssertEqual(MainScreen.outputText.label, firstKeypadNumber)
    }
    
}
