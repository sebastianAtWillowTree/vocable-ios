//
//  AccessibilityID+Settings+VoiceConfiguration.swift.swift
//  Vocable
//
//  Created by Steve Foster on 4/23/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.settings {
    public struct voiceSettings {
        public static let playButton: AccessibilityID = "voice-configuration-play-voice-button"
        public static let audioPlaying: AccessibilityID = "voice-configuration-audio-playing-button"
        public static let previewVoiceCell: AccessibilityID = "voice-settings-preview-voice-cell"
        private init() {}
    }
}
