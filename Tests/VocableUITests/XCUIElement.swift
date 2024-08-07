//
//  XCUIElement.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/15/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    
    /// Waits the amount of time you specify for the element’s exists property to become true and then taps on it.
    ///
    /// Returns false if the timeout expires without the element coming into existence. In this case, the `tap` action
    /// will not occur.
    func tapWhenExists(
        timeout: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try assertExistence(timeout: timeout, file: file, line: line)
        self.tap()
    }
    
    func assertExistence(
        timeout: TimeInterval = 0.5,
        _ message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        guard self.waitForExistence(timeout: timeout) else {
            let message = message ?? "Element did not come into existence before timeout."
            XCTFail(message, file: file, line: line)
            throw XCTestError(.timeoutWhileWaiting)
        }
    }
    
}
