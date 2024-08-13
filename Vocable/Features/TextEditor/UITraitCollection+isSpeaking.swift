//
//  UITraitCollection+isSpeaking.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 17.0, *)
private struct SpeakingStateTrait: UITraitDefinition {
    static var defaultValue: Bool = false
}

@available(iOS 17.0, *)
extension UITraitCollection {
    var isSpeaking: Bool {
        self[SpeakingStateTrait.self]
    }
}

@available(iOS 17.0, *)
extension UIMutableTraits {
    var isSpeaking: Bool {
        get { self[SpeakingStateTrait.self] }
        set { self[SpeakingStateTrait.self] = newValue }
    }
}
