//
//  KeyboardLayoutDirectionalInsets.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardLayoutDirectionalInsets: Hashable {

    var leading: any KeyboardLayoutRelativeWidth
    var trailing: any KeyboardLayoutRelativeWidth

    static var zero: KeyboardLayoutDirectionalInsets {
        KeyboardLayoutDirectionalInsets(leading: .zero, trailing: .zero)
    }

    init(leading: some KeyboardLayoutRelativeWidth) {
        self.leading = AnyKeyboardLayoutRelativeWidth(leading)
        self.trailing = AnyKeyboardLayoutRelativeWidth(.zero)
    }

    init(trailing: some KeyboardLayoutRelativeWidth) {
        self.leading = AnyKeyboardLayoutRelativeWidth(.zero)
        self.trailing = AnyKeyboardLayoutRelativeWidth(trailing)
    }

    init(leading: some KeyboardLayoutRelativeWidth, trailing: some KeyboardLayoutRelativeWidth) {
        self.leading = AnyKeyboardLayoutRelativeWidth(leading)
        self.trailing = AnyKeyboardLayoutRelativeWidth(trailing)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(AnyKeyboardLayoutRelativeWidth(leading))
        hasher.combine(AnyKeyboardLayoutRelativeWidth(trailing))
    }

    static func == (lhs: KeyboardLayoutDirectionalInsets, rhs: KeyboardLayoutDirectionalInsets) -> Bool {
        AnyKeyboardLayoutRelativeWidth(lhs.leading) == AnyKeyboardLayoutRelativeWidth(rhs.leading) &&
        AnyKeyboardLayoutRelativeWidth(lhs.trailing) == AnyKeyboardLayoutRelativeWidth(rhs.trailing)
    }
}
