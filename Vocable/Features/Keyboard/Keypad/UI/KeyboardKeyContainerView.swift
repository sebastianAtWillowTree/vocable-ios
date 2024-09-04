//
//  KeyboardKeyContainerView.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardView {

    final class KeyContainerView: UIView {
        let button: KeyButton

        lazy private(set) var buttonWidthConstraint: NSLayoutConstraint = {
            button.widthAnchor.constraint(equalToConstant: 10.0).withPriority(999)
        }()

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        init(button: KeyButton) {
            self.button = button
            super.init(frame: .zero)

            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            NSLayoutConstraint.activate(
                [
                    button.topAnchor.constraint(
                        equalTo: self.topAnchor
                    ),
                    button.leadingAnchor.constraint(
                        equalTo: self.layoutMarginsGuide.leadingAnchor
                    ),
                    button.bottomAnchor.constraint(
                        equalTo: self.bottomAnchor
                    ),
                    button.trailingAnchor.constraint(
                        equalTo: self.layoutMarginsGuide.trailingAnchor
                    ),
                    buttonWidthConstraint
                ]
            )
        }
    }
}
