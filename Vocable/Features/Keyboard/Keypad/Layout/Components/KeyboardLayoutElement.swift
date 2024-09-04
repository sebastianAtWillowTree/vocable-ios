//
//  KeyboardLayoutElement.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

protocol KeyboardLayoutElement {
    var children: [any KeyboardLayoutElement] { get set }
    func makeKeys(environment: KeyboardLayoutEnvironment) -> [KeyboardLayoutKey]
}
