//
//  KeyboardSuggestionAnimationContainer.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardSuggestionsView {
    final class SuggestionAnimationContainer: AnimationContainerView<UIView> {

        typealias ScaleContainer = AnimationContainerView<SuggestionButton>
        typealias OpacityContainer = AnimationContainerView<ScaleContainer>

        let button: SuggestionButton
        let scaleContainer: ScaleContainer
        let opacityContainer: OpacityContainer

        init() {
            self.button = SuggestionButton()
            self.scaleContainer = AnimationContainerView(child: button)
            self.opacityContainer = AnimationContainerView(child: scaleContainer)
            super.init(child: opacityContainer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
