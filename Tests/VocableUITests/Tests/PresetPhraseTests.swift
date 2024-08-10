//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 04/19/20.
//  Copyright © 2022 WillowTree. All rights reserved.
//
import XCTest

class PresetPhraseTests: BaseTest {
    
    func testAddNewPhrase() throws {
        let customPhrase = "Add"
        let category = "Environment"
                
        // Navigate to our test category and Add a phrase
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: category)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        try CustomCategoriesScreen.addPhrase(customPhrase)
        
        // Verify that phrase does exist in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(customPhrase))
        
        // Verify that phrase does exist in Main Screen
        try CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.environment)
        XCTAssertTrue(MainScreen.phraseDoesExist(customPhrase))
    }
    
    func testEditPresetPhrase() throws {
        let customPhrase = "ab"
        let category = "Personal Care"
                
        // Navigate to our test category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let originalPhrase = CustomCategoriesScreen.firstPhraseCell.staticTexts.firstMatch.label
        
        try CustomCategoriesScreen.firstPhraseCell.staticTexts[originalPhrase].tapWhenExists()
        try KeyboardScreen.typeText(customPhrase)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
   
        // Verify that the original phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.phraseDoesExist(originalPhrase))
        
        // Verify that updated phrase exists in Category Details Screen
        let updatedPhrase = originalPhrase + customPhrase
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(updatedPhrase))
        
        // Verify that updated phrase exists in Main Screen
        try CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.personalCare)
        XCTAssertTrue(MainScreen.phraseDoesExist(updatedPhrase))
    }
    
    func testDeletePresetPhrase() throws {
        let category = "Basic Needs"
                
        // Navigate to our test category
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let firstPhrase = CustomCategoriesScreen.firstPhraseCell.staticTexts.firstMatch.label
        
        CustomCategoriesScreen.firstPhraseCell.buttons[.settings.editPhrases.deletePhraseButton].tap()
        try SettingsScreen.alertDeleteButton.tapWhenExists()
        
        // Verify that phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.phraseDoesExist(firstPhrase))
        
        // Verify that phrase doesn't exist in Main Screen
        try CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        XCTAssertFalse(MainScreen.phraseDoesExist(firstPhrase))
    }
    
    func testEditPhrasesButtonIsDisabledForNumberPadCategory() throws {
        let categoryName = "123"
           
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(CustomCategoriesScreen.editCategoryPhrasesButton.isEnabled)
    }
        
    func testEditPhrasesButtonIsDisabledForRecentsCategory() throws {
        let categoryName = "Recents"
       
        try SettingsScreen.navigateToSettingsCategoryScreen()
        try SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(CustomCategoriesScreen.editCategoryPhrasesButton.isEnabled)
    }
        
    func testAddDuplicatePhrasesToMySayings() throws {
        let testPhrase = "Test"
        
        try MainScreen.keyboardButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
        try KeyboardScreen.favoriteButton.tapWhenExists()
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
       
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        XCTAssertTrue(MainScreen.phraseDoesExist(testPhrase), "Expected the first phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
        
        // Add the same phrase again to the My Sayings
        try MainScreen.addPhraseButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
        try KeyboardScreen.checkmarkAddButton.tapWhenExists()
        try KeyboardScreen.createDuplicateButton.tapWhenExists()
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = app.staticTexts.containing(phrasePredicate)
        try phraseQuery.element.assertExistence(timeout: 1.0)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be present in 'My Sayings'")
    }
}
