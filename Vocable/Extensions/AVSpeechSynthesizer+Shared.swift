//
//  AVSpeechSynthesizer+Shared.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesizer {

    private struct Storage {
        static let shared = AVSpeechSynthesizer()
    }

    static let shared: AVSpeechSynthesizer = {
        let synthesizer = Storage.shared
        return synthesizer
    }()
    
    func speak(_ string: String, language: String) {
        let utterance = AVSpeechUtterance(string: string)
        
        if let selectedVoiceID = AppConfig.selectedVoiceIdentifier {
            if let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceID) {
                let languageLocale = NSLocale(localeIdentifier: language)
                let voiceLocale = NSLocale(localeIdentifier: voice.language)
                
                // Check to be sure the user-provided voice can speak this language
                if languageLocale.languageCode == voiceLocale.languageCode {
                    utterance.voice = voice
                }
            }
        }
        
        // fall back to previous behavior
        if utterance.voice == nil {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        
        if isSpeaking {
            stopSpeaking(at: .immediate)
        }
        speak(utterance)
    }

}
