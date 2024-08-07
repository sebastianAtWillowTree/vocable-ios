//
//  CustomCategoryAppRestartTests.swift
//  VocableUITests
//
//  Created by Canan Arikan on 6/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest
import Foundation

class CustomCategoryAppRestartTests: XCTestCase {
    
    let firstCustomCategory: String = "First"
    let secondCustomCategory: String = "Second"
    let phrase: String = "Test"

    override func setUpWithError() throws {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
        }
        continueAfterFailure = false
        app.launch()
        
        // Create a custom category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try CustomCategoriesScreen.createCustomCategory(categoryName: firstCustomCategory)
    }
    
    func testCategoryAndPhraseCustomizationPersists() throws {
        // Verify that custom category exists
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Add a custom phrase to the custom category and verify that it exists
        try SettingsScreen.openCategorySettings(category: firstCustomCategory)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        try CustomCategoriesScreen.addPhrase(phrase)
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
     
        // Restart the app
        Utilities.restartApp()
        
        // Navigate to Settings Category Screen
        try SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that the custom category and phrase persist after restarting
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        try SettingsScreen.openCategorySettings(category: firstCustomCategory)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
    }
    
    func testHideCategoryPersists() throws {
        // Verify that custom category exists
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Verify that when the custom category is shown (last in the list), up button is enabled and down button is disabled
        VTAssertReorderArrowsEqual(.upEnabledOnly, for: firstCustomCategory)
        
        // Hide the custom category
        try SettingsScreen.openCategorySettings(category: firstCustomCategory)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        
        // Verify that when the category is hidden, up and down buttons are disabled
        VTAssertReorderArrowsEqual(.none, for: firstCustomCategory)
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that after restart, hidden category's up and down buttons are disabled
        try SettingsScreen.navigateToSettingsCategoryScreen()
        VTAssertReorderArrowsEqual(.none, for: firstCustomCategory)
    }
    
    func testReorderPersists() throws {
        // Verify that first custom category exists
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Create second custom category and verify that it exists
        try CustomCategoriesScreen.createCustomCategory(categoryName: secondCustomCategory)
        try SettingsScreen.navBarBackButton.assertExistence(timeout: 1.0)
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(secondCustomCategory))
        
        // Verify that first custom category's up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: firstCustomCategory)
        
        // Verify that second custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderArrowsEqual(.upEnabledOnly, for: secondCustomCategory)
        
        // Reorder custom categories, move first custom category to the end of the list
        let firstCategory = try SettingsScreen.locateCategoryCell(firstCustomCategory)
        try firstCategory.buttons[.settings.editCategories.moveDownButton].tapWhenExists()
        try SettingsScreen.navBarBackButton.assertExistence(timeout: 1.0)
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderArrowsEqual(.upEnabledOnly, for: firstCustomCategory)
        
        // Verify that second custom category's up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: secondCustomCategory)
        
        // Restart the app and navigate to Settings Category Screen
        Utilities.restartApp()
        try SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderArrowsEqual(.upEnabledOnly, for: firstCustomCategory)
        
        // Verify that second custom category's up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: secondCustomCategory)
    }
}
