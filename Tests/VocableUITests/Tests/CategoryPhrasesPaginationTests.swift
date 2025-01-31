//
//  CategoryPhrasesPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest
import SnapshotTesting

class CategoryPhrasesPaginationTests: PaginationBaseTest {
    
    func testCanNavigatePages() throws {
        // Navigate to our test category
        try MainScreen.navigateToSettingsAndOpenCategory(name: ninePhrasesCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        
        // Verify that the user is on the first page and the next page buttons are enabled.
        VTAssertPaginationEquals(1, of: 2, enabledArrows: .both)
        
        // Use the RIGHT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in 1...CustomCategoriesScreen.totalPageCount {
            XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, pageNumber)
            try CustomCategoriesScreen.paginationRightButton.tapWhenExists()
        }
        XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, 1) // Confirm we return to the first page
        
        // Use the LEFT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in stride(from: CustomCategoriesScreen.totalPageCount, through: 1, by: -1) {
            try CustomCategoriesScreen.paginationLeftButton.tapWhenExists()
            XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, pageNumber)
        }
    }
    
    func testPagesAdjustToNewPhrases() throws {
        // Verify that the user is on the first page.
        try MainScreen.navigateToSettingsAndOpenCategory(name: twoPhrasesCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
        
        // Pagination should be disabled when this scenario begins
        VTAssertPaginationArrowsEqual(.none)
        
        // Add phrases and ensure that the page counts update when a page overflows
        let pageCountBeforeAdditions = BaseScreen.totalPageCount
        try CustomCategoriesScreen.addRandomPhrases(numberOfPhrases: 10)
        XCTAssertGreaterThan(BaseScreen.totalPageCount, pageCountBeforeAdditions)
        
        // Pagination should be enabled after the overflow
        VTAssertPaginationArrowsEqual(.both)
        
        // Remove the additional phrases to verify that the page count reduces and arrows become disabled
        let pageCountBeforeDeletions = BaseScreen.totalPageCount
        for _ in 1...10 {
            try CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tapWhenExists()
            try SettingsScreen.alertDeleteButton.tapWhenExists()
        }
        XCTAssertLessThan(BaseScreen.totalPageCount, pageCountBeforeDeletions)
        
        // Assert that the arrows are enabled as expected
        VTAssertPaginationArrowsEqual(.none)
    }
    
    // It is expected that the pagination left and right arrows are disabled when there is only 1 total page
    func testNextPageButtonsDisabled() throws {
        // Navigate to our test category and open the 'Edit Phrases' screen
        try MainScreen.navigateToSettingsAndOpenCategory(name: twoPhrasesCategory.presetCategory.utterance)
        try CustomCategoriesScreen.editCategoryPhrasesButton.tapWhenExists()
    // Verify the page counts and that buttons appear; both buttons are disabled.
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
    func testMyViewController() {
        let vc = UIViewController()

        assertSnapshot(of: vc, as: .image)
      }
}
