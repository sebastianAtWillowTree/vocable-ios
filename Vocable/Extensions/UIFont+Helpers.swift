//
//  UIFont+Helpers.swift
//  Vocable
//
//  Created by Chris Stroud on 5/17/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    static func settingsCellTitle() -> UIFont {
        UIFont.systemFont(ofSize: 22, weight: .bold)
    }

    static func textEditor(
        satisfying traitCollection: UITraitCollection = .current
    ) -> UIFont {
        let fontSize: CGFloat = (traitCollection.sizeClass == .hRegular_vRegular) ? 40 : 28
        let desiredFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return desiredFont
    }

}
