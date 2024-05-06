//
//  VoiceProfilePreviewDataSource.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import Algorithms

final class VoiceProfilePreviewDataSource {
    
    private(set) var selectedVoice: AVSpeechSynthesisVoice?
    
    private(set) var voices: [AVSpeechSynthesisVoice] = []

    private let filter: VoiceProfilePreviewDataSource.Filter
    
    init(filter: VoiceProfilePreviewDataSource.Filter) {
        self.filter = filter
        reloadData()
    }
    
    func reloadData() {
        
        var availableVoices = AVSpeechSynthesisVoice.speechVoices()
        availableVoices = linguisticallyRelevantVoices(from: availableVoices)
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
        
        if let selectedVoiceID = AppConfig.selectedVoiceIdentifier {
            selectedVoice = availableVoices.first { item in
                item.identifier == selectedVoiceID
            }
        }
        
        // Split off from the above so it now handles the case where a
        // user had selected a Personal voice and then revoked Vocable's
        // access to that particular voice.
        if let defaultedVoice = AVSpeechSynthesisVoice(language: AppConfig.activePreferredLanguageCode) {
            if selectedVoice == nil {
                selectedVoice = defaultedVoice
            }
        } else {
            selectedVoice = nil
        }

        voices = availableVoices
            .filter { voice in
                filter.shouldInclude(voice, isSelected: selectedVoice == voice)
            }
        
        if #available(iOS 17.0, *) {
            // Ensure personal voices, if present, are listed first
            voices.sort { lhs, rhs in
                if lhs.voiceTraits.contains(.isPersonalVoice) {
                    return true
                } else if rhs.voiceTraits.contains(.isPersonalVoice) {
                    return false
                } else {
                    return lhs.name < rhs.name
                }
            }
        }
    }
    
    /// Attempts to take all the variants of each voice (grouped by name) and surfaces only one voice
    /// for each name that most closely matches the current region.
    private func linguisticallyRelevantVoices(from voices: [AVSpeechSynthesisVoice]) -> [AVSpeechSynthesisVoice] {
        // Using NSLocale because of Locale.language availability
        let activeLocale = NSLocale(localeIdentifier: AppConfig.activePreferredLanguageCode)
        let result = voices
            .filter { voice in
                let voiceLocale = NSLocale(localeIdentifier: voice.language)
                return activeLocale.languageCode == voiceLocale.languageCode
            }
            .grouped(by: \.name)
            .compactMapValues { voices in
                // Attempting to get the most relevant locale out of the list
                voices
                    .sorted { lhs, rhs in
                        let lhsLocale = NSLocale(localeIdentifier: lhs.language)
                        let rhsLocale = NSLocale(localeIdentifier: rhs.language)
                        let lhsMatches: Bool
                        let rhsMatches: Bool
                        if #available(iOS 17, *) {
                            lhsMatches = lhsLocale.regionCode == activeLocale.regionCode
                            rhsMatches = rhsLocale.regionCode == activeLocale.regionCode
                        } else {
                            lhsMatches = lhsLocale.localeIdentifier == activeLocale.localeIdentifier
                            rhsMatches = rhsLocale.localeIdentifier == activeLocale.localeIdentifier
                        }
                        return lhsMatches && !rhsMatches
                    }
                    .first
            }
            .values
        return Array(result)
    }
}
