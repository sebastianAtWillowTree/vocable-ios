//
//  VoiceProfilePreviewSynthesizer.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Combine

protocol VoiceProfilePreviewSynthesizerDelegate: AnyObject {
    func voiceProfilePreviewDidBegin(_: AVSpeechSynthesisVoice?)
    func voiceProfilePreviewDidEnd()
}

final class VoiceProfilePreviewSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    
    private let synthesizer = AVSpeechSynthesizer()
    private(set) var activePreviewVoice: AVSpeechSynthesisVoice?
    var delegate: VoiceProfilePreviewSynthesizerDelegate?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func playPreview(_ voice: AVSpeechSynthesisVoice) {
        let format = String(localized: "voice_preview.sample_audio.introducion_format")
        let localizedUtterance = String.localizedStringWithFormat(format, voice.name)
        let utterance = AVSpeechUtterance(string: localizedUtterance)
        utterance.voice = voice
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func stopPlaying() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        activePreviewVoice = utterance.voice
        delegate?.voiceProfilePreviewDidBegin(utterance.voice)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        activePreviewVoice = nil
        delegate?.voiceProfilePreviewDidEnd()
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        activePreviewVoice = nil
        delegate?.voiceProfilePreviewDidEnd()
    }
}
