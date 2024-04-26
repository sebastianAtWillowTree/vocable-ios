//
//  VoiceProfilePreviewDataSource+Filter.swift
//  Vocable
//
//  Created by Chris Stroud on 4/25/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

extension VoiceProfilePreviewDataSource {
    
    // This is a cheap stand-in until the deployment target can
    // support iOS 17's Foundation Predicates. Goal is to allow
    // injecting a filter into the datasource externally so it can
    // be configured per-presentation context.
    struct Filter {

        private let isIncluded: ((voice: AVSpeechSynthesisVoice, isSelected: Bool)) -> Bool
        
        func shouldInclude(_ voice: AVSpeechSynthesisVoice, isSelected: Bool) -> Bool {
            isIncluded((voice: voice, isSelected: isSelected))
        }
    }
}

extension VoiceProfilePreviewDataSource.Filter {
    
    /// Only allow the selected voice to remain in the collection
    static var selectedVoice: Self {
        Self { (voice: AVSpeechSynthesisVoice, isSelected: Bool) in
            isSelected
        }
    }
    
    /// Only allow the standard selection of system voices to remain in the collection,
    /// excluding novelty voices. For pre-iOS 17.0 devices, this will filter any non-binary
    /// gendered voices because that appears to be the best (only?) strategy we have for
    /// filtering out novelty voices due to the lack of relevant metadata.
    static var systemVoices: Self {
        Self { (voice: AVSpeechSynthesisVoice, isSelected: Bool) in
            if #available(iOS 17.0, *) {
                return !voice.voiceTraits.contains(.isNoveltyVoice)
            } else {
                // Best workaround we have, given the state of pre-iOS 17 APIs
                // Not trying to force a gender binary, merely trying to exclude
                // all the novelty voices without a proper API to do so.
                return [.male, .female].contains(voice.gender)
            }
        }
    }
}
