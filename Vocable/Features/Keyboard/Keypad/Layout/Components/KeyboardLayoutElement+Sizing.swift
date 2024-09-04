//
//  KeyboardLayoutElement+Sizing.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension KeyboardLayoutElement {
    func keyWidth(
        count: Int,
        span: Int? = nil
    ) -> some KeyboardLayoutElement {
        self.mutatingEnvironment { environment in
            environment.columnCount = count
            if let span {
                environment.spanCount = span
            }
            environment.keySizingStrategy = .columns
        }
    }

    func keyWidth(
        span: Int
    ) -> some KeyboardLayoutElement {
        self.mutatingEnvironment { environment in
            environment.spanCount = span
        }
    }

    func keyWidth(
        proportional multiplier: CGFloat
    ) -> some KeyboardLayoutElement {
        self.mutatingEnvironment { environment in
            environment.keySizingStrategy = .proportional(multiplier: multiplier)
        }
    }
}
