//
//  KeyboardLayoutElement+Padding.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension KeyboardLayoutElement {

    func padding(
        leading: some KeyboardLayoutRelativeWidth
    ) -> some KeyboardLayoutElement {
        environment(\.padding.leading, leading)
    }

    func padding(
        trailing: some KeyboardLayoutRelativeWidth
    ) -> some KeyboardLayoutElement {
        environment(\.padding.trailing, trailing)
    }

    func padding(
        leading: some KeyboardLayoutRelativeWidth,
        trailing: some KeyboardLayoutRelativeWidth
    ) -> some KeyboardLayoutElement {
        environment(\.padding, .init(leading: leading, trailing: trailing))
    }
}
