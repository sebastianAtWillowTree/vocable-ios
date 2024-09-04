//
//  KeyboardLayout.swift
//  Vocable
//
//  Created by Chris Stroud on 5/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardLayout {

    var identifier: String { get }

    @KeyboardBuilder
    func makeLayout(configuration: KeyboardLayoutConfiguration) -> KeyboardBody
}
