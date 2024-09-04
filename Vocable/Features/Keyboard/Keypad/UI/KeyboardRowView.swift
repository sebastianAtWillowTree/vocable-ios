//
//  KeyboardRowView.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardView {
    class RowView: UIView {
        private let stackView = UIStackView()
        private let alignmentStack = UIStackView()

        let keys: [KeyboardLayoutKey]

        override var bounds: CGRect {
            didSet {
                guard bounds.size != oldValue.size else { return }
                setNeedsUpdateConstraints()
            }
        }

        var keyButtons: [KeyButton] {
            keyContainers.map(\.button)
        }

        private var keyContainers: [KeyContainerView] {
            stackView.arrangedSubviews as? [KeyContainerView] ?? []
        }

        init(keys: [KeyboardLayoutKey]) {
            self.keys = keys
            super.init(frame: .zero)

            backgroundColor = .collectionViewBackgroundColor

            alignmentStack.translatesAutoresizingMaskIntoConstraints = false
            alignmentStack.distribution = .equalSpacing
            alignmentStack.axis = .vertical
            alignmentStack.alignment = .center
            addSubview(alignmentStack)

            NSLayoutConstraint.activate([
                alignmentStack.topAnchor.constraint(equalTo: topAnchor),
                alignmentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                alignmentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                alignmentStack.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

            alignmentStack.addArrangedSubview(stackView)

            for key in keys {
                let button = KeyButton(identifier: key)
                let container = KeyContainerView(button: button)
                stackView.addArrangedSubview(container)
            }

            stackView.spacing = 6.0
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .fill
            setNeedsUpdateConstraints()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func updateConstraints() {
            super.updateConstraints()

            for keyContainer in keyContainers {
                let identifier = keyContainer.button.identifier
                keyContainer.directionalLayoutMargins.leading = identifier.environment.padding.leading.value(in: bounds.width, environment: identifier.environment)
                keyContainer.directionalLayoutMargins.trailing = identifier.environment.padding.trailing.value(in: bounds.width, environment: identifier.environment)
                keyContainer.buttonWidthConstraint.constant = identifier.environment.keyWidth(containerWidth: bounds.width)
            }
        }
    }
}
