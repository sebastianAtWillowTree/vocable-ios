//
//  VoiceProfileItem.swift
//  Vocable
//
//  Created by Chris Stroud on 4/25/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

struct VoiceProfileItem: Hashable {
    let voice: AVSpeechSynthesisVoice
    let isSelected: Bool
    let isPlaying: Bool
    
    func hash(into hasher: inout Hasher) {
        voice.identifier.hash(into: &hasher)
        isSelected.hash(into: &hasher)
        isPlaying.hash(into: &hasher)
    }
    
    static func ==(_ lhs: VoiceProfileItem, _ rhs: VoiceProfileItem) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.isPlaying == rhs.isPlaying &&
        lhs.voice.identifier == rhs.voice.identifier
    }
}
