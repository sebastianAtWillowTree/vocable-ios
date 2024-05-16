//
//  VocableUIControl.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UIControl.State: Hashable {

}

@IBDesignable
class GazeableButton: UIButton {

    fileprivate var gazeBeganDate: Date?
    private var cachedFillColors = [UIControl.State: UIColor]()
    private var cachedTitleColors = [UIControl.State: UIColor]()
    private var cachedHighlightColor: UIColor?
    private let defaultIBStates = [UIControl.State.normal, .highlighted, .selected, .disabled]

    var shouldShrinkWhenTouched = true {
        didSet {
            updateSelectionAppearance()
        }
    }

    private(set) var isTrackingTouches: Bool = false {
        didSet {
            guard oldValue != isTrackingTouches else { return }

            setNeedsUpdateConfiguration()
            updateSelectionAppearance()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet {
            guard oldValue != cornerRadius else { return }
            // FIXME: Replace with UIButtonConfiguration
//            updateBackgroundImagesForCurrentParameters()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 4 {
        didSet {
            guard oldValue != borderWidth else { return }
            // FIXME: Replace with UIButtonConfiguration
//            updateBackgroundImagesForCurrentParameters()
        }
    }

    // FIXME: needed
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            guard oldValue != roundedCorners else { return }
            // FIXME: Replace with UIButtonConfiguration
//            updateBackgroundImagesForCurrentParameters()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configuration = UIButton.Configuration.plain()
    }
    
    override func updateConfiguration() {
        guard let configuration = configuration else {
            return
        }
        
        var updatedConfiguration = configuration
        
        tintColor = .defaultTextColor
        
        var fillColor = UIColor.defaultCellBackgroundColor
        var titleColor = UIColor.defaultTextColor
        
        
        if self.state.contains(.selected) {
            fillColor = .cellSelectionColor
            titleColor = .collectionViewBackgroundColor
        }
        
        if self.state.contains(.disabled)  {
            fillColor = fillColor.disabled(blending: .collectionViewBackgroundColor)
            titleColor = .white.withAlphaComponent(0.5)
        }
        
        if isTrackingTouches {
            fillColor = fillColor.darkenedForHighlight()
        }
        
        var strokeColor = fillColor
        
        if self.state.contains(.highlighted) {
            strokeColor = UIColor.cellBorderHighlightColor
        }

        updatedConfiguration.background.backgroundColor = fillColor
        updatedConfiguration.baseForegroundColor = titleColor
        
        updatedConfiguration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = titleColor
            return outgoing
        }
        
        updatedConfiguration.imageColorTransformer = UIConfigurationColorTransformer { incoming in
            return titleColor
        }
        
        updatedConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        updatedConfiguration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)

        updatedConfiguration.background.strokeColor = strokeColor
        updatedConfiguration.background.strokeWidth = borderWidth

        print("isTrackingTouches: \(isTrackingTouches)")
        print("highlighted: \(self.state.contains(.highlighted))")
        
        self.configuration = updatedConfiguration
    }

    private func updateSelectionAppearance() {

        func actions() {
            let scale: CGFloat = (isHighlighted && isTrackingTouches && shouldShrinkWhenTouched) ? 0.95 : 1.0
            transform = .init(scaleX: scale, y: scale)
        }

        if UIView.inheritedAnimationDuration == 0 {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: actions,
                           completion: nil)
        } else {
            actions()
        }
    }

    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        gazeBeganDate = Date()
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeMoved(gaze, with: event)
        
        guard let beganDate = gazeBeganDate else {
            return
        }
        
        let timeElapsed = Date().timeIntervalSince(beganDate)
        if timeElapsed >= AppConfig.selectionHoldDuration {
            if isEnabled {
                isSelected = true
                sendActions(for: .primaryActionTriggered)
                (self.window as? HeadGazeWindow)?.animateCursorSelection()
            }
            gazeBeganDate = nil
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        
        gazeBeganDate = nil
        isSelected = false
        isHighlighted = false
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeCancelled(gaze, with: event)
        isHighlighted = false
        isSelected = false
        gazeBeganDate = .distantFuture
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = false
    }
}

class GazeableSegmentedButton: GazeableButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSelected {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if !isSelected {
            isHighlighted = true
        }
        gazeBeganDate = Date()
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if !isSelected {
            gazeBeganDate = nil
            isSelected = false
        }
        isHighlighted = false
    }
    
}
