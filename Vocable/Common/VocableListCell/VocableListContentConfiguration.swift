//
//  VocableListContentConfiguration.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

struct VocableListContentConfiguration: UIContentConfiguration, Equatable {

    typealias TraitCollectionChangeHandler = (UITraitCollection, inout VocableListContentConfiguration) -> Void

    struct ActionsConfiguration {

        enum Position {
            case leading
            case bottom
        }

        struct LayoutSize {

            enum Dimension {
                case absolute(CGFloat)
                case fractionalHeight(CGFloat)
                case fractionalWidth(CGFloat)
            }

            var widthDimension: Dimension
            let heightDimension: Dimension = .fractionalHeight(1.0)

            static let square = LayoutSize(widthDimension: .fractionalHeight(1.0))
        }

        var position: Position = .leading
        var size: LayoutSize

        static let `default` = ActionsConfiguration(position: .leading, size: .square)
    }

    var actions: [VocableListCellAction]
    var attributedTitle: NSAttributedString
    var isPrimaryActionEnabled: Bool
    var leadingAccessory: VocableListCellAccessory?
    var trailingAccessory: VocableListCellAccessory?
    var primaryAction: (() -> Void)?
    var actionsConfiguration: ActionsConfiguration
    var accessibilityIdentifier: String?
    var accessibilityLabel: String?
    var primaryBackgroundColor: UIColor = .defaultCellBackgroundColor
    var primaryContentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .leading

    var traitCollectionChangeHandler: TraitCollectionChangeHandler?

    init(
        title: String,
        actions: [VocableListCellAction] = [],
        actionsConfiguration: ActionsConfiguration = .default,
        accessory: VocableListCellAccessory? = nil,
        isPrimaryActionEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        primaryAction: @escaping () -> Void
    ) {
        self.init(
            title: title,
            actions: actions,
            actionsConfiguration: actionsConfiguration,
            leadingAccessory: nil,
            trailingAccessory: accessory,
            isPrimaryActionEnabled: isPrimaryActionEnabled,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel,
            primaryAction: primaryAction
        )
    }
    
    init(
        title: String,
        actions: [VocableListCellAction] = [],
        actionsConfiguration: ActionsConfiguration = .default,
        leadingAccessory: VocableListCellAccessory? = nil,
        trailingAccessory: VocableListCellAccessory? = nil,
        isPrimaryActionEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        primaryAction: @escaping () -> Void
    ) {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22, weight: .bold)]
        let attributedText = NSAttributedString(string: title, attributes: attributes)

        self.init(
            attributedText: attributedText,
            actions: actions,
            actionsConfiguration: actionsConfiguration,
            leadingAccessory: leadingAccessory,
            trailingAccessory: trailingAccessory,
            isPrimaryActionEnabled: isPrimaryActionEnabled,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel,
            primaryAction: primaryAction
        )
    }

    init(
        attributedText: NSAttributedString,
        actions: [VocableListCellAction] = [],
        actionsConfiguration: ActionsConfiguration = .default,
        accessory: VocableListCellAccessory? = nil,
        isPrimaryActionEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        primaryAction: @escaping () -> Void
    ) {
        self.init(
            attributedText: attributedText,
            actions: actions,
            actionsConfiguration: actionsConfiguration,
            leadingAccessory: nil,
            trailingAccessory: accessory,
            isPrimaryActionEnabled: isPrimaryActionEnabled,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel,
            primaryAction: primaryAction
        )
    }
    
    init(
        attributedText: NSAttributedString,
        actions: [VocableListCellAction] = [],
        actionsConfiguration: ActionsConfiguration = .default,
        leadingAccessory: VocableListCellAccessory? = nil,
        trailingAccessory: VocableListCellAccessory? = nil,
        isPrimaryActionEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        primaryAction: @escaping () -> Void
    ) {
        self.attributedTitle = attributedText
        self.isPrimaryActionEnabled = isPrimaryActionEnabled
        self.primaryAction = primaryAction
        self.actions = actions
        self.leadingAccessory = leadingAccessory
        self.trailingAccessory = trailingAccessory
        self.actionsConfiguration = actionsConfiguration
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    static func disclosureCellConfiguration(withTitle title: String, action: @escaping () -> Void) -> VocableListContentConfiguration {
        .init(title: title, accessory: .disclosureIndicator(), primaryAction: action)
    }

    static func toggleCellConfiguration(withTitle title: String, isOn: Bool, action: @escaping () -> Void) -> VocableListContentConfiguration {
        .init(title: title, accessory: .toggle(isOn: isOn), primaryAction: action)
    }

    func makeContentView() -> UIView & UIContentView {
        VocableListCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VocableListContentConfiguration {
        var updatedSelf = self
        
        if let state = state as? UICellConfigurationState {
            updatedSelf.primaryBackgroundColor = state.isSelected ? .cellSelectionColor : .defaultCellBackgroundColor
            let color = state.isSelected ? UIColor.selectedTextColor : UIColor.defaultTextColor
            
            let updatedAttributedTitle = NSMutableAttributedString(attributedString: updatedSelf.attributedTitle)
            updatedAttributedTitle.addAttributes([.foregroundColor: color], range: NSRange.entireRange(of: updatedAttributedTitle.string))
            updatedSelf.attributedTitle = updatedAttributedTitle
        }
        
        traitCollectionChangeHandler?(state.traitCollection, &updatedSelf)
        return updatedSelf
    }

    static func == (lhs: VocableListContentConfiguration, rhs: VocableListContentConfiguration) -> Bool {
        lhs.actions.elementsEqual(rhs.actions) &&
        lhs.attributedTitle.isEqual(to: rhs.attributedTitle) &&
        lhs.isPrimaryActionEnabled == rhs.isPrimaryActionEnabled &&
        lhs.trailingAccessory == rhs.trailingAccessory &&
        lhs.leadingAccessory == rhs.leadingAccessory
    }
}
