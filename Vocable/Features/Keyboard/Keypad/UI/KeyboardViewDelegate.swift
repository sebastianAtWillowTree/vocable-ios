//
//  KeyboardViewDelegate.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

protocol KeyboardViewDelegate: AnyObject {
    func keyboardViewDidSelectSuggestion(_ suggestion: String)
    func keyboardViewDidSelectKey(_ value: KeyboardLayoutKey)
}
