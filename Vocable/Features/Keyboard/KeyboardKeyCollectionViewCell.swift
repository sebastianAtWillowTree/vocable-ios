//
//  KeyboardKeyCollectionView.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class KeyboardKeyCollectionViewCell: VocableCollectionViewCell {
    fileprivate let textLabel = UILabel()
    fileprivate let imageView = UIImageView()
    
    private var font: UIFont {
        switch sizeClass {
        case .hCompact_vCompact, .hRegular_vCompact:
            return .boldSystemFont(ofSize: 28)
        case .hCompact_vRegular:
            if AppConfig.isCompactQWERTYKeyboardEnabled {
                return .boldSystemFont(ofSize: 16)
            }
            return .boldSystemFont(ofSize: 28)
        default:
            return .boldSystemFont(ofSize: 48)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        
        installContentView(textLabel)
        installContentView(imageView)
    }
    
    private func installContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).withPriority(999),
            view.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).withPriority(999),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    override func updateContent() {
        super.updateContent()
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
        textLabel.font = font
        textLabel.textAlignment = .center
        
        imageView.tintColor = textLabel.textColor
        imageView.preferredSymbolConfiguration = .init(font: self.font)
    }

    func setup(title: String) {
        textLabel.isHidden = false
        imageView.isHidden = true
        textLabel.text = title
    }
    
    func setup(with image: UIImage?) {
        textLabel.isHidden = true
        imageView.isHidden = false
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .center
    }
}

final class SpeakFunctionKeyboardKeyCollectionViewCell: KeyboardKeyCollectionViewCell {
    
    override var fillColor: UIColor {
        get {
            UIColor.highlightedTextColor!
        }
        set {
            // no-op
        }
    }
    
    override func updateContent() {
        super.updateContent()
        
        let foregroundColor: UIColor = isSelected ? .selectedTextColor : .collectionViewBackgroundColor
        textLabel.textColor = foregroundColor
        imageView.tintColor = foregroundColor
    }
}
