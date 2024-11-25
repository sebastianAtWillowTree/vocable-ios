import XCTest

class SettingsScreen: BaseScreen {
    
    // MARK: Screen elements
    static let otherElements = XCUIApplication().collectionViews.cells.otherElements
    static let cells = XCUIApplication().cells
    
    // Settings Screen
    static let categoriesAndPhrasesCell = XCUIApplication().cells[.settings.categoriesAndPhrasesCell]
    static let timingAndSensitivityCell = XCUIApplication().cells[.settings.timingAndSensitivityCell]
    static let resetAppSettingsCell = XCUIApplication().cells[.settings.resetAppSettingsCell]
    static let listeningModeCell = XCUIApplication().cells[.settings.listeningModeCell]
    static let selectionModeCell = XCUIApplication().cells[.settings.selectionModeCell]
    static let privacyPolicyCell = XCUIApplication().cells[.settings.privacyPolicyCell]
    static let contactDevelopersCell = XCUIApplication().cells[.settings.contactDevelopersCell]
    static let hotDogStandThemeCell = XCUIApplication().cells[.settings.hotDogStandThemeCell] // Pd3e5
    
    // Categories and Phrases
    static let addCategoryButton = XCUIApplication().buttons[.settings.editCategories.addCategoryButton]

    // Category Details
    static let renameCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.renameCategoryButton]
    static let showCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.showCategoryToggle]
    static let removeCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.removeCategoryButton]

    // MARK: Helpers
    
    static func openCategorySettings(
        category: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let categoryCell = try locateCategoryCell(category, file: file, line: line)
        try categoryCell.buttons[.settings.editCategories.categoryButton]
            .tapWhenExists(file: file, line: line)
    }
    
    @discardableResult
    static func locateCategoryCell(
        _ category: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> XCUIElement {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        // Loop through each page to find our category
        for _ in 1...totalPageCount {
            let query = cells.containing(predicate)
            let element = query.firstMatch
            if element.waitForExistence(timeout: 0.5) {
                return element
            } else {
                try paginationRightButton.tapWhenExists(file: file, line: line)
            }
        }
        XCTFail("Failed to locate cell for category named \"\(category)\"", file: file, line: line)
        throw XCTestError(.timeoutWhileWaiting)
    }
    
    private static func categoryCellQuery(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        let cellLabel = cells.staticTexts.containing(predicate).element.label
        
        return XCUIApplication().cells.containing(.staticText, identifier: cellLabel)
    }
    
    static func doesCategoryExist(
        _ category: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Bool {
        var flag = false
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        
        // Loop through each custom category page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists {
                flag = true
                break
            } else {
                try MainScreen.paginationRightButton.tapWhenExists(file: file, line: line)
            }
        }
        
        return flag
    }
    
    static func navigateToCategory(
        category: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            try paginationRightButton.tapWhenExists(file: file, line: line)
            if MainScreen.pageNumberText.label.contains("Page 1") {
                break
            }
        }
    }
    
    static func navigateToSettingsCategoryScreen(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try MainScreen.settingsButton.tapWhenExists(timeout: 1.0, file: file, line: line)
        try categoriesAndPhrasesCell.tapWhenExists(timeout: 1.0, file: file, line: line)
        try addCategoryButton.assertExistence(timeout: 0.5, "Failed to locate add category button", file: file, line: line)
    }
    
    static func returnToMainScreen(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try navBarDismissButton.tapWhenExists(file: file, line: line)
    }
    
}
