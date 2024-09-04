//
//  TextCursorBeamView.swift
//  Vocable
//
//  Created by Chris Stroud on 8/2/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension OutputTextView {
    final class TextCursorBeamView: UIView {

        private var blinkTimer: Timer?

        override func tintColorDidChange() {
            super.tintColorDidChange()
            backgroundColor = tintColor
        }

        override func willMove(toWindow newWindow: UIWindow?) {
            super.willMove(toWindow: newWindow)
            if newWindow == nil {
                blinkTimer?.invalidate()
            }
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            scheduleBlinkTimerIfNeeded()
            backgroundColor = tintColor
        }

        override var isHidden: Bool {
            didSet {
                scheduleBlinkTimerIfNeeded()
            }
        }

        private var shouldAllowTimer: Bool {
            guard self.window != nil, !isHidden else {
                return false
            }
            return true
        }

        private func scheduleBlinkTimerIfNeeded() {
            guard shouldAllowTimer else {
                blinkTimer?.invalidate()
                return
            }
            if let current = blinkTimer, current.isValid {
                return
            }
            let timer = Timer(fireAt: Date(),
                              interval: 1.2,
                              target: self,
                              selector: #selector(blinkTimerDidFire(_:)),
                              userInfo: nil,
                              repeats: true)
            RunLoop.main.add(timer, forMode: .common)
            blinkTimer = timer
        }

        @objc
        private func blinkTimerDidFire(_ sender: Timer) {

            guard shouldAllowTimer else {
                blinkTimer?.invalidate()
                return
            }

            guard UIView.areAnimationsEnabled else {
                return
            }

            layer.removeAllAnimations()

            UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.beginFromCurrentState], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
                    self.alpha = 0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.33) {
                    self.alpha = 1
                }
            }, completion: nil)
        }
    }
}
