//
//  KeyboardScreenTests.swift
//  KeyboardScreenTests
//
//  Created by Kevin Stechler on 4/22/20.
//  Updated by Rudy Salas and Canan Arikan on 03/17/2022
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreenTests: BaseTest {
    
    func testKeyboardOutputIsDisplayed() throws {
        let testPhrase = "Test"
        
        try MainScreen.keyboardButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
       
        try KeyboardScreen.keyboardTextView.staticTexts[testPhrase]
            .assertExistence("Expected the text \(testPhrase) to be displayed")
    }
  
    func testAddPhraseToMySayingsFromKeyboard() throws {
        let testPhrase = "Test"
        
        try MainScreen.keyboardButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
        try KeyboardScreen.favoriteButton.tapWhenExists()
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        
        MainScreen.locateAndSelectDestinationCategory(.mySayings)

        try MainScreen.locatePhraseCell(phrase: testPhrase)
            .assertExistence("Expected the phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
    }
    
    func testRemovePhraseFromMySayingsFromKeyboard() throws {
        let testPhrase = "Test"
        
        try MainScreen.keyboardButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
        try KeyboardScreen.favoriteButton.tapWhenExists()
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        
        try MainScreen.locatePhraseCell(phrase: testPhrase).assertExistence("Expected the phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
        
        try MainScreen.keyboardButton.tapWhenExists()
        try KeyboardScreen.typeText(testPhrase)
        try KeyboardScreen.favoriteButton.tapWhenExists()
        try KeyboardScreen.navBarDismissButton.tapWhenExists()
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        
        // We expect 'My Sayings' to be empty now.
        try MainScreen.emptyStateAddPhraseButton.assertExistence("Expected the phrase \(testPhrase) to be deleted from 'My Sayings'")
    }
    
}
