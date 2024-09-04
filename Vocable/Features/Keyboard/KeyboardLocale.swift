//
//  KeyboardModel.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

enum KeyboardLocale: String {
    case en
    case de
    case it

    static var current: Self {
        let preferredLanguageCode = AppConfig.activePreferredLanguageCode
        let code = Locale(identifier: preferredLanguageCode).languageCode ?? AppConfig.defaultLanguageCode
        return Self(rawValue: code) ?? .en
    }
}
