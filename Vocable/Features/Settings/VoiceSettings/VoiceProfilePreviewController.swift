//
//  VoiceProfilePreviewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import Combine
import AVFoundation
import UIKit

final class VoiceProfilePreviewController {

    enum PresentationContext {
        case selectedProfilePreview
        case voiceSelection
    }
    
    let context: PresentationContext
    
    @Published
    private(set) var items: [VoiceProfileItem] = []
    
    private let synthesizer = VoiceProfilePreviewSynthesizer()
    private let dataSource: VoiceProfilePreviewDataSource
    private var cancellables: Set<AnyCancellable> = []
    
    init(context: PresentationContext) {
        self.context = context
        switch context {
        case .selectedProfilePreview:
            self.dataSource = .init(filter: .selectedVoice)
        case .voiceSelection:
            self.dataSource = .init(filter: .systemVoices)
        }
        
        synthesizer.delegate = self
        
        if #available(iOS 17.0, *) {
            NotificationCenter.default
                .publisher(for: AVSpeechSynthesizer.availableVoicesDidChangeNotification)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.availableVoicesDidChange()
                }
                .store(in: &cancellables)
        }
        
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateItems()
            }
            .store(in: &cancellables)

        AppConfig.$selectedVoiceIdentifier
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.selectedVoiceDidChange()
            }
            .store(in: &cancellables)

        updateItems()
    }
    
    func playPreview(_ item: VoiceProfileItem) {
        synthesizer.playPreview(item.voice)
    }
    
    func stopPreview() {
        synthesizer.stopPlaying()
    }
    
    private func availableVoicesDidChange() {
        updateItems()
    }
    
    private func selectedVoiceDidChange() {
        updateItems()
    }
    
    private func updateItems() {
        reloadDataSource()
        let newItems = dataSource.voices.map { voice in
            VoiceProfileItem(
                voice: voice,
                isSelected: dataSource.selectedVoice == voice,
                isPlaying: synthesizer.activePreviewVoice == voice
            )
        }
        if items != newItems {
            items = newItems
        }
    }
    
    private func reloadDataSource() {
        dataSource.reloadData()
    }
}

// MARK: VoiceProfilePreviewSynthesizerDelegate

extension VoiceProfilePreviewController: VoiceProfilePreviewSynthesizerDelegate {
    func voiceProfilePreviewDidBegin(_ voice: AVSpeechSynthesisVoice?) {
        updateItems()
    }
    
    func voiceProfilePreviewDidEnd() {
        updateItems()
    }
}
