//
//  VocableSpeechSynthesizer.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Combine

@MainActor
protocol VocableSpeechSynthesizerDelegate: AnyObject {
    func voiceProfilePreviewDidBegin(_: AVSpeechSynthesisVoice?)
    func voiceProfilePreviewDidEnd()
    func voiceSpeechSynthesisWillSpeakRange(_ range: NSRange, utterance: AVSpeechUtterance)
}

actor VocableSpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {

    private let synthesizer = AVSpeechSynthesizer()
    
    @MainActor
    private(set) var activePreviewVoice: AVSpeechSynthesisVoice?
    
    @MainActor
    weak var delegate: VocableSpeechSynthesizerDelegate?

    @MainActor
    static let shared = VocableSpeechSynthesizer()

    @MainActor
    @Published
    private(set) var isSpeaking: Bool = false

    private var synthesisOperations = [AVSpeechUtterance: AsyncStream<NSRange>.Continuation]()

    override init() {
        super.init()
        synthesizer.delegate = self

        Task {
            await speak("")
        }
    }
    
    init(delegate: VocableSpeechSynthesizerDelegate? = nil) {
        self.init()
        Task { @MainActor in
            self.delegate = delegate
        }
    }

    private func setContinuation(
        _ continuation: AsyncStream<NSRange>.Continuation?,
        for utterance: AVSpeechUtterance
    ) {
        synthesisOperations[utterance] = continuation
    }

    private func speak(utterance: AVSpeechUtterance) -> AsyncStream<NSRange> {
        AsyncStream { [weak self] continuation in
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }
                if synthesizer.isSpeaking {
                    synthesizer.stopSpeaking(at: .immediate)
                }
                await setContinuation(continuation, for: utterance)
                synthesizer.speak(utterance)
            }
        }
    }

    @discardableResult
    func speak(_ string: String, language: String = AppConfig.activePreferredLanguageCode) -> AsyncStream<NSRange> {
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

        return speak(utterance: utterance)
    }

    @discardableResult
    func playPreview(_ voice: AVSpeechSynthesisVoice) -> AsyncStream<NSRange> {
        let format = String(localized: "voice_preview.sample_audio.introducion_format")
        let localizedUtterance = String.localizedStringWithFormat(format, voice.name)
        let utterance = AVSpeechUtterance(string: localizedUtterance)
        utterance.voice = voice
        utterance.rate = 0.5
        return speak(utterance: utterance)
    }
    
    func stopPreview() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    private func synthesisOperationDidEnd(utterance: AVSpeechUtterance) {
        synthesisOperations[utterance]?.finish()
        setContinuation(nil, for: utterance)
    }

    private func synthesisOperationWillSpeak(utterance: AVSpeechUtterance, range: NSRange) {
        synthesisOperations[utterance]?.yield(range)
    }

    nonisolated
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            activePreviewVoice = utterance.voice
            isSpeaking = true
            delegate?.voiceProfilePreviewDidBegin(utterance.voice)
        }
    }
    
    nonisolated
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            activePreviewVoice = nil
            isSpeaking = false
            await synthesisOperationDidEnd(utterance: utterance)
            delegate?.voiceProfilePreviewDidEnd()
        }
    }
    
    nonisolated
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            activePreviewVoice = nil
            isSpeaking = false
            await synthesisOperationDidEnd(utterance: utterance)
            delegate?.voiceProfilePreviewDidEnd()
        }
    }

    nonisolated
    public func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            await synthesisOperationWillSpeak(
                utterance: utterance,
                range: characterRange
            )
            delegate?.voiceSpeechSynthesisWillSpeakRange(
                characterRange,
                utterance: utterance
            )
        }
    }
}
