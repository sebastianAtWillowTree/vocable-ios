//
//  KeyboardView.swift
//  Vocable
//
//  Created by Chris Stroud on 6/1/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class KeyboardView: UIView {

    private let stackView = UIStackView()

    private let suggestionsView = KeyboardSuggestionsView()

    var mode: KeyboardLayoutMode = .alphabetical {
        didSet {
            guard oldValue != mode else { return }
            updateContent()
        }
    }

    private var activeModifier: Character? {
        didSet {
            guard oldValue != activeModifier else { return }
            updateContent()
        }
    }

    weak var delegate: KeyboardViewDelegate? {
        didSet {
            suggestionsView.delegate = delegate
        }
    }

    var suggestions: [String] {
        get {
            suggestionsView.suggestions
        }
        set {
            suggestionsView.suggestions = newValue
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private var previewLayout: (any KeyboardLayout)?
    convenience init(previewLayout: some KeyboardLayout) {
        self.init(frame: .zero)
        self.previewLayout = previewLayout
        updateContent()
    }

    private func commonInit() {

        accessibilityID = AccessibilityID.shared.keyboard.view

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(suggestionsView)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = true
        stackView.layoutMargins = .zero
        stackView.backgroundColor = .collectionViewBackgroundColor
        stackView.isOpaque = true

        // Rely on the safe area to avoid the bulk of
        // obstructions, but use a negative inset to
        // ensure the keyboard can more closely hug the edges
        // of the device like the system keyboard
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: .zero, leading: -8, bottom: -8, trailing: -8)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor).withPriority(999),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.backgroundColor = .collectionViewBackgroundColor
        self.isOpaque = true
        updateContent()
    }

    private func updateContent() {
        for arrangedSubview in stackView.arrangedSubviews where arrangedSubview != suggestionsView {
            stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        let heightRange = rowHeightRange()
        let layout = currentLayout()
        let configuration = KeyboardLayoutConfiguration(
            mode: mode, 
            modifierGrapheme: activeModifier,
            sizeClass: traitCollection.sizeClass
        )
        let body = layout
            .makeLayout(configuration: configuration)

        stackView.spacing = rowSpacing()
        let keys = body.root.children.flatMap({$0.makeKeys(environment: .init())})
        let groupedKeys = keys
            .grouped(by: \.environment.rowIndex)
            .sorted { lhs, rhs in
                lhs.key < rhs.key
            }

        for (_, keys) in groupedKeys {
            let rowView = RowView(keys: keys)
            stackView.addArrangedSubview(rowView)
            rowView.addConstraints(
                [
                    rowView.heightAnchor.constraint(
                        greaterThanOrEqualToConstant: heightRange.lowerBound
                    ),
                    rowView.heightAnchor.constraint(
                        lessThanOrEqualToConstant: heightRange.upperBound
                    )
                ]
            )
            for keyButton in rowView.keyButtons {
                keyButton.addTarget(
                    self,
                    action: #selector(handleKeyAction(_:)),
                    for: .primaryActionTriggered
                )
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.sizeClass != traitCollection.sizeClass {
            updateContent()
        }
    }

    private var needsCompactLayout: Bool {
        guard sizeClass == .hCompact_vRegular else {
            return false
        }

        let isHeadTrackingEnabled = AppConfig.isHeadTrackingEnabled
        let isCompactQWERTYEnabled = AppConfig.isCompactQWERTYKeyboardEnabled

        // Only default to compact layout when head tracking is enabled
        // and the user hasn't explicitly forced standard layout
        // in horizontally compact environments
        let result = isHeadTrackingEnabled && !isCompactQWERTYEnabled
        return result
    }

    private func currentLayout() -> KeyboardLayout {
        if let previewLayout {
            previewLayout
        } else {
            if needsCompactLayout {
                CompactKeyboardLayoutEN()
            } else {
                switch KeyboardLocale.current {
                case .en:
                    StandardKeyboardLayoutEN()
                case .de:
                    StandardKeyboardLayoutDE()
                case .it:
                    StandardKeyboardLayoutIT()
                }
            }
        }
    }

    private func rowSpacing() -> CGFloat {
        6.0
    }

    private func rowHeightRange() -> ClosedRange<CGFloat> {
        if traitCollection.userInterfaceIdiom == .phone {
            44.0 ... 58.0
        } else {
            54.0 ... 88.0
        }
    }

    @objc
    private func handleKeyAction(_ sender: KeyButton) {
        var nextMode: KeyboardLayoutMode?
        switch sender.identifier.action {
        case .alphabet:
            nextMode = .alphabetical
        case .numberPad:
            nextMode = .numerical
            activeModifier = nil
        case .closeModifierPicker:
            nextMode = .alphabetical
        case .openModifierPicker:
            nextMode = .modifierPicker
        case .beginModifier(let value):
            nextMode = .alphabetical
            activeModifier = value
        case .endModifier:
            nextMode = .alphabetical
            activeModifier = nil
        default:
            break
        }

        if let nextMode {
            self.mode = nextMode
        } else {
            delegate?.keyboardViewDidSelectKey(sender.identifier)
        }

        // Unset the modifier if it was just used to enter text
        if case .insertCharacter = sender.identifier.action, activeModifier != nil {
            activeModifier = nil
        }
    }
}
