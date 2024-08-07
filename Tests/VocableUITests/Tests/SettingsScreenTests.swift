//
//  SettingsScreenTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/24/20.
//  Updated by Canan Arikan and Rudy Salas on 03/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreenTests: BaseTest {

    func testHideShowToggle() throws {
        let category = "Environment"

        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.locateCategoryCell(category).assertExistence()

        // Verify that when the category is hidden, up and down buttons are disabled.
        try SettingsScreen.openCategorySettings(category: category)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        
        VTAssertReorderArrowsEqual(.none, for: category)

        // Verify that when the category is shown, up and down buttons are enabled.
        try SettingsScreen.openCategorySettings(category: category)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        
        VTAssertReorderArrowsEqual(.both, for: category)
    }

    func testReorder() throws {
        try SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Define the query that gives us the first category listed
        let currentFirstCategory = XCUIApplication().cells.allElementsBoundByIndex[0]
        // Define the query that gives us the second category listed
        let currentSecondCategory = XCUIApplication().cells.allElementsBoundByIndex[1]
        let originalFirstCategoryName = currentFirstCategory.label
        let originalSecondCategoryName = currentSecondCategory.label
        
        // Give me the first category, using our query, and confirm the state of the buttons
        XCTAssertFalse(currentFirstCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertTrue(currentFirstCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Give me the second category, using our query, and confirm the state of the buttons
        XCTAssertTrue(currentSecondCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertTrue(currentSecondCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Move the first category down one
        try currentFirstCategory.buttons[.settings.editCategories.moveDownButton].tapWhenExists()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalSecondCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalFirstCategoryName)
        
        // Move the second category back up
        try currentSecondCategory.buttons[.settings.editCategories.moveUpButton].tapWhenExists()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalFirstCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalSecondCategoryName)
    }
}
