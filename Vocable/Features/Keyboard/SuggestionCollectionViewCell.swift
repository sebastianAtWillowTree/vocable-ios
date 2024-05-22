//
//  PresetItemCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: VocableCollectionViewCell {
    
    private let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        installContentView(textLabel)
    }

    func setup(title: String) {
        UIView.transition(
            with: self.contentView,
            duration: 0.2,
            options: [.transitionCrossDissolve]
        ) { [weak textLabel] in
            if title.isEmpty {
                textLabel?.text = title
            } else {
                textLabel?.text = "\"" + title + "\""
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustBackgroundColorForSizeClass()
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
        UIView.performWithoutAnimation {
            borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
            adjustBackgroundColorForSizeClass()
            textLabel.backgroundColor = borderedView.fillColor
            textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
            textLabel.isOpaque = true
            textLabel.font = .systemFont(ofSize: 22, weight: .bold)
            textLabel.textAlignment = .center
            textLabel.numberOfLines = 2
            textLabel.allowsDefaultTighteningForTruncation = true
            textLabel.minimumScaleFactor = 0.5
            textLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func adjustBackgroundColorForSizeClass() {
        if sizeClass.contains(any: .compact) {
            borderedView.backgroundColor = .clear
        } else {
            borderedView.backgroundColor = .categoryBackgroundColor
        }
    }
}
