//
//  AccessoryAction.swift
//  Vocable
//
//  Created by Chris Stroud on 3/21/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

struct VocableListCellAccessory: Equatable {

    enum Content: Equatable {
        case toggle(isOn: Bool)
        case image(UIImage)

        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.toggle(let isOnLeft), .toggle(let isOnRight)):
                return isOnLeft == isOnRight
            case (.image(let leftImage), .image(let rightImage)):
                return leftImage.isEqual(rightImage)
            default:
                return false
            }
        }
    }

    let content: Content
    let isEnabled: Bool

    private static var trailingDefaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
    }

    static func disclosureIndicator(isEnabled: Bool = true) -> VocableListCellAccessory {
        let symbolName: String
        if UITraitCollection.current.layoutDirection == .leftToRight {
            symbolName = "chevron.right"
        } else {
            symbolName = "chevron.left"
        }
        return .systemImage(symbolName, isEnabled: isEnabled)
    }
    
    static func systemImage(_ name: String, isEnabled: Bool = true) -> VocableListCellAccessory {
        let image = UIImage(systemName: name, withConfiguration: trailingDefaultSymbolConfiguration)!
        return VocableListCellAccessory(content: .image(image), isEnabled: isEnabled)
    }

    static func toggle(isOn: Bool, isEnabled: Bool = true) -> VocableListCellAccessory {
        return VocableListCellAccessory(content: .toggle(isOn: isOn), isEnabled: isEnabled)
    }
    
    static var checkmark: VocableListCellAccessory {
        .checkmark(isEnabled: true)
    }
    
    static func checkmark(isEnabled: Bool) -> VocableListCellAccessory {
        .systemImage("checkmark", isEnabled: true)
    }
    
    static var playAudio: VocableListCellAccessory {
        .systemImage("play.circle", isEnabled: true)
    }
    
    static var stopAudio: VocableListCellAccessory {
        .systemImage("stop.circle", isEnabled: true)
    }
}
