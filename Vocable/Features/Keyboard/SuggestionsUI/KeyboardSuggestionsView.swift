//
//  KeyboardSuggestionsView.swift
//  Vocable
//
//  Created by Chris Stroud on 6/2/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

final class KeyboardSuggestionsView: UIView {

    weak var delegate: KeyboardViewDelegate? {
        didSet {
            for suggestionView in suggestionViews {
                suggestionView.delegate = delegate
            }
        }
    }

    var suggestions: [String] = [] {
        didSet {
            guard oldValue != suggestions else { return }
            updateButtons()
        }
    }

    private lazy var suggestionViews: [SuggestionView] = {
        (1 ... maximumSuggestionCount).map { _ in
            SuggestionView()
        }
    }()

    private let stackView = UIStackView(frame: .zero)

    private var maximumSuggestionCount: Int {
        if traitCollection.userInterfaceIdiom == .phone {
            return 3
        }
        return 4
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue.size != bounds.size else { return }
            updateButtons()
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8.0
        addSubview(stackView)
        for suggestionView in suggestionViews {
            stackView.addArrangedSubview(suggestionView)
        }
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func updateButtons() {
        for (index, suggestionView) in suggestionViews.indexed() {
            let suggestion = suggestions[safe: index]
            suggestionView.text = suggestion
        }
    }
}
