//
//  CustomCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoryTests: CustomCategoryBaseTest {
    
    func testAddCustomCategory() throws {
        let categoryCell = try SettingsScreen.locateCategoryCell(customCategoryName)
        XCTAssertTrue(categoryCell.isEnabled)
    }
    
    func testCanContinueEditingCategoryName() throws {
        let renamedCategory = customCategoryName + nameSuffix
        
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.renameCategoryButton.tapWhenExists()
        try KeyboardScreen.typeText(nameSuffix)
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        try KeyboardScreen.alertMessageLabel.assertExistence()
        
        try SettingsScreen.alertContinueButton.tapWhenExists()
        try KeyboardScreen.keyboardTextView.staticTexts[renamedCategory].assertExistence()

        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        let renamedCategoryCell = try SettingsScreen.locateCategoryCell(renamedCategory)
        XCTAssertTrue(renamedCategoryCell.isEnabled)
   }
    
    func testCanDiscardEditingCategoryName() throws {
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.renameCategoryButton.tapWhenExists()
        try KeyboardScreen.typeText(nameSuffix)
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        try KeyboardScreen.alertMessageLabel.assertExistence()
        
        try SettingsScreen.alertDiscardButton.tapWhenExists()
        XCTAssertEqual(SettingsScreen.title.label, customCategoryName)
        
        try SettingsScreen.navBarBackButton.tapWhenExists()
        try SettingsScreen.locateCategoryCell(customCategoryName).assertExistence()
    }
    
    func testCanRenameCategory() throws {
        let renamedCategory = customCategoryName + nameSuffix
        
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.renameCategoryButton.tapWhenExists()
        try KeyboardScreen.typeText(nameSuffix)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
        XCTAssertEqual(SettingsScreen.title.label, renamedCategory)
        
        try SettingsScreen.navBarBackButton.tapWhenExists()
        try SettingsScreen.locateCategoryCell(renamedCategory).assertExistence()
    }
    
    func testCanRemoveCategory() throws {
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(customCategoryName))
        
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.removeCategoryButton.tapWhenExists()
        try SettingsScreen.alertRemoveButton.tapWhenExists()
        try SettingsScreen.addCategoryButton.assertExistence(timeout: 1.0)
        XCTAssertFalse(try SettingsScreen.doesCategoryExist(customCategoryName))
    }
  
    func testCanHideCategory() throws {
        // Verify that custom category is created
        XCTAssertTrue(try SettingsScreen.doesCategoryExist(customCategoryName))
        
        // Verify that custom category appears on the main screen
        try CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertTrue(MainScreen.locateAndSelectCustomCategory(customCategoryName))
        
        // Hide the custom category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        
        // Verify that when the category is hidden, up and down buttons are disabled.
        let hiddenCategory = try SettingsScreen.locateCategoryCell(customCategoryName)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.isEnabled)

        // Verify that custom category doesn't appear on the main screen
        try CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertFalse(MainScreen.locateAndSelectCustomCategory(customCategoryName))
        
        // Show the custom category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: customCategoryName)
        try SettingsScreen.showCategoryButton.tapWhenExists()
        try SettingsScreen.navBarBackButton.tapWhenExists()
        
        // Verify that when the category is shown, up button is enabled and down button is disabled.
        let shownCategory = try SettingsScreen.locateCategoryCell(customCategoryName)
        XCTAssertTrue(shownCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(shownCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(shownCategory.isEnabled)
    }
}
