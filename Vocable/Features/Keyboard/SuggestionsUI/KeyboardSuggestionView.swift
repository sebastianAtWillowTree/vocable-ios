//
//  KeyboardSuggestionView.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardSuggestionsView {
    final class SuggestionView: UIView {

        weak var delegate: KeyboardViewDelegate?

        private let animationContainer = SuggestionAnimationContainer()

        private var button: SuggestionButton {
            animationContainer.button
        }

        var text: String? {
            didSet {
                guard oldValue != text else { return }
                updateContent(oldValue: oldValue)
            }
        }

        init() {
            super.init(frame: .zero)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError()
        }

        private func commonInit() {
            animationContainer.translatesAutoresizingMaskIntoConstraints = false
            addSubview(animationContainer)

            NSLayoutConstraint.activate([
                animationContainer.topAnchor.constraint(equalTo: topAnchor),
                animationContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
                animationContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                animationContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

            animationContainer.button.addTarget(
                self,
                action: #selector(handleSuggestionSelection(_:)),
                for: .primaryActionTriggered
            )
            updateContent(animated: false)
        }

        @objc
        private func handleSuggestionSelection(_ button: SuggestionButton) {
            if let content = button.currentTitle {
                delegate?.keyboardViewDidSelectSuggestion(content)
            }
        }

        private func updateContent(
            oldValue: String? = nil,
            animated: Bool = true
        ) {
            let duration: TimeInterval = 0.8
            let opacityDuration: TimeInterval = 0.24

            let isActive: Bool = (text != nil)
            let wasActive: Bool = (oldValue != nil)
            let isEntering: Bool = !wasActive && isActive
            let isExiting: Bool = !isActive && wasActive

            // If exiting, don't change the content since the
            // whole view is disappearing and the switch to an
            // empty suggestion would be strange.
            // If entering, update the content before the
            // animation begins so we don't see a stale value
            // animate to the new value.
            animationContainer.button.setTitle(isExiting ? oldValue : text, for: .normal)
            performTransformTransition(
                isActive: isActive,
                duration: duration,
                animated: animated
            )
            performOpacityTransition(
                isActive: isActive,
                duration: opacityDuration,
                isEntering: isEntering,
                isExiting: isExiting,
                animated: animated
            )
        }

        private func performTransformTransition(
            isActive: Bool,
            duration: TimeInterval,
            animated: Bool = true
        ) {
            UIView.animate(
                withDuration: animated ? duration: .zero,
                delay: .zero,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 1.0,
                options: [.allowAnimatedContent, .allowUserInteraction]
            ) { [weak self] in
                guard let self else { return }
                if isActive {
                    animationContainer.scaleContainer.isUserInteractionEnabled = true
                    animationContainer.scaleContainer.transform = .identity
                } else {
                    animationContainer.scaleContainer.isUserInteractionEnabled = false
                    animationContainer.scaleContainer.transform = .identity
                        .scaledBy(x: 0.9, y: 0.9)
                }
            }
        }

        private func performOpacityTransition(
            isActive: Bool,
            duration: TimeInterval,
            isEntering: Bool,
            isExiting: Bool,
            animated: Bool = true
        ) {

            let curveOption: UIView.AnimationOptions
            if isEntering {
                curveOption = .curveEaseOut
            } else if isExiting {
                curveOption = .curveLinear
            } else {
                curveOption = []
            }

            UIView.animate(
                withDuration: animated ? duration : .zero,
                delay: .zero,
                options: [.allowAnimatedContent, .allowUserInteraction, curveOption]
            ) { [weak self] in
                if isActive {
                    self?.animationContainer.opacityContainer.alpha = 1.0
                } else {
                    self?.animationContainer.opacityContainer.alpha = 0.0
                }
            }
        }

        private func performContentTransition(
            text: String?,
            duration: TimeInterval,
            animated: Bool = true
        ) {
            animationContainer.button.setTitle(text, for: .normal)
        }
    }
}
