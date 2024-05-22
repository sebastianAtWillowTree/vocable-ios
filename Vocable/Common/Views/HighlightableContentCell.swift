//
//  HighlightableContentCell.swift
//  Vocable
//
//  Created by Chris Stroud on 5/22/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

protocol HighlightableContentCell: UICollectionViewCell {
    @MainActor
    func setHighlightRange(_ range: NSRange?)
}
