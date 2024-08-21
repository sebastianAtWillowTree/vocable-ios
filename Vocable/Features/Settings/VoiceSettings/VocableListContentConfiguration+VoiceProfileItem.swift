//
//  VoiceProfileCell.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension VocableListContentConfiguration {
    
    @MainActor
    static func voiceProfileItem(
        _ item: VoiceProfileItem,
        controller: VoiceProfilePreviewController,
        voiceSelectedAction: (() -> Void)? = nil
    ) -> Self {
        
        let sampleAction: VocableListCellAction
        if item.isPlaying {
            sampleAction = VocableListCellAction.stopAudio(
                accessibilityIdentifier: .settings.voiceSettings.audioPlaying
            ) {
                controller.stopPreview()
            }
        } else {
            sampleAction = VocableListCellAction.startAudio(
                accessibilityIdentifier: .settings.voiceSettings.playButton
            ) {
                controller.playPreview(item)
            }
        }

        return VocableListContentConfiguration(
            title: item.voice.name,
            actions: [sampleAction],
            trailingAccessory: (voiceSelectedAction != nil && item.isSelected) ? .checkmark : nil,
            isPrimaryActionEnabled: voiceSelectedAction != nil,
            accessibilityIdentifier: .settings.voiceSettings.previewVoiceCell,
            primaryAction: voiceSelectedAction ?? {}
        )
    }
    
    @MainActor
    static func voiceSelectionPreview(
        _ item: VoiceProfileItem,
        controller: VoiceProfilePreviewController
    ) -> Self {
        
        let accessory: VocableListCellAccessory
        if item.isPlaying {
            accessory = .stopAudio
        } else {
            accessory = .playAudio
        }

        return VocableListContentConfiguration(
            title: item.voice.name,
            leadingAccessory: accessory,
            accessibilityIdentifier: AccessibilityID.settings.voiceSettings.previewVoiceCell
        ) {
            if item.isPlaying {
                controller.stopPreview()
            } else {
                controller.playPreview(item)
            }
        }
    }
}
