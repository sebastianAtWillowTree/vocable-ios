//
//  TextEditorViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import Combine

protocol TextEditorConfigurationProviding {
    mutating func textEditorViewController(_: TextEditorViewController, textDidChange text: String?)
    func textEditorViewControllerConfiguration(_: TextEditorViewController) -> TextEditorViewController.Configuration
    func textEditorViewControllerInitialValue(_: TextEditorViewController) -> String?
}

class TextEditorViewController: VocableViewController, UICollectionViewDelegate, VocableSpeechSynthesizerDelegate, KeyboardViewDelegate {

    struct Configuration {
        var leftItemConfiguraton: TextEditorNavigationButton.Configuration?
        var rightItemConfiguration: TextEditorNavigationButton.Configuration?
    }

    let textView = OutputTextView(frame: .zero)

    let leftButton = TextEditorNavigationButton()
    let rightButton = TextEditorNavigationButton()

    var delegate: TextEditorConfigurationProviding?

    private var needsConfigurationUpdate = true

    @PublishedValue private(set) var text: String?

    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()

    private var speechSynthesizer: VocableSpeechSynthesizer!

    private var _textTransaction = TextTransaction(text: "") {
        didSet {
            attributedText = _textTransaction.attributedText
        }
    }

    private var textTransaction: TextTransaction {
        return _textTransaction
    }

    private let textExpression = TextExpression()

    private var suggestions: [String] = [] {
        didSet {
            guard !suggestions.elementsEqual(oldValue) else {
                return
            }
            keyboardView.suggestions = suggestions
        }
    }

    private let keyboardView = KeyboardView()
    private var isSpeaking: Bool = false {
        didSet {
            if #available(iOS 17.0, *) {
                self.traitOverrides.isSpeaking = isSpeaking
            }
        }
    }

    private var speakingRange: NSRange? {
        didSet {
            guard oldValue != speakingRange else { return }
            self.setTextTransaction(self.textTransaction.withSpeakingRange(speakingRange))
        }
    }

    @PublishedValue
    var attributedText: NSAttributedString?

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        commonInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        modalPresentationStyle = .fullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        speechSynthesizer = VocableSpeechSynthesizer(delegate: self)
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.frame.size.width = view.bounds.width
        view.addSubview(keyboardView)

        let initialAttributedText = NSAttributedString(string: delegate?.textEditorViewControllerInitialValue(self) ?? "")
        attributedText = initialAttributedText

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.accessibilityID = .shared.keyboard.outputTextView
        textView.textAlignment = .natural

        navigationBar.leftButton = leftButton
        navigationBar.rightButton = rightButton

        handleTextChange()
        setNeedsUpdateConfiguration()
    }

    private func handleTextChange() {
        $attributedText
            .dropFirst()
            .map { [weak self] attributedText -> NSAttributedString? in
                guard let self else { return attributedText }
                textView.attributedText = attributedText
                if let attributedText, attributedText.string != self._textTransaction.text {
                    self._textTransaction = TextTransaction(text: attributedText.string, intent: .lastCharacter)
                }
                return attributedText
            }
            .map { $0?.string }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.text = text
                self.delegate?.textEditorViewController(self, textDidChange: text)
            }
            .store(in: &disposables)
    }

    private func updateForConfiguration() {
        guard let configuration = delegate?.textEditorViewControllerConfiguration(self) else { return }

        leftButton.configure(with: configuration.leftItemConfiguraton)
        rightButton.configure(with: configuration.rightItemConfiguration)
        needsConfigurationUpdate = false
    }

    func setNeedsUpdateConfiguration() {
        needsConfigurationUpdate = true
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        if needsConfigurationUpdate { updateForConfiguration() }
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        if sizeClass.contains(.vCompact) {
            navigationBar.titleView = textView
            let widthConstraint = textView.widthAnchor.constraint(equalTo: view.widthAnchor)
            widthConstraint.priority = .defaultHigh
            constraints += [
                widthConstraint,
                keyboardView.topAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: 8
                )
            ]
        } else {
            navigationBar.titleView = nil
            if textView.superview != view {
                view.addSubview(textView)
            }
            constraints += [
                textView.heightAnchor.constraint(greaterThanOrEqualTo: navigationBar.layoutMarginsGuide.heightAnchor, multiplier: 2),
                textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8),
                textView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
                textView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
                keyboardView.topAnchor.constraint(greaterThanOrEqualTo: textView.bottomAnchor)
            ]
        }

        // Collection view
        constraints += [
            keyboardView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }

    private func setTextTransaction(_ transaction: TextTransaction) {
        _textTransaction = transaction

        // Update suggestions
        if textTransaction.isHint || textTransaction.text.last == " " {
            suggestions = []
        } else {
            textExpression.replace(text: textTransaction.text)
            suggestions = textExpression.suggestions()
        }

    }

    // MARK: VocableSpeechSynthesizerDelegate

    func voiceProfilePreviewDidBegin(_: AVSpeechSynthesisVoice?) {
        isSpeaking = true
    }

    func voiceProfilePreviewDidEnd() {
        isSpeaking = false
        speakingRange = nil
    }

    func voiceSpeechSynthesisWillSpeakRange(_ range: NSRange, utterance: AVSpeechUtterance) {
        speakingRange = range
    }

    func keyboardViewDidSelectSuggestion(_ suggestion: String) {
        setTextTransaction(textTransaction.insertingSuggestion(with: suggestion))
    }

    func keyboardViewDidSelectKey(_ value: KeyboardLayoutKey) {
        switch value.content {
        case .string(let character):
            setTextTransaction(textTransaction.appendingCharacter(with: String(character)))
        case .function(let keyboardFunctionKey):
            switch keyboardFunctionKey {
            case .clear:
                setTextTransaction(TextTransaction(text: "", intent: .none))
            case .backspace:
                setTextTransaction(textTransaction.deletingLastToken())
            case .space:
                setTextTransaction(textTransaction.appendingCharacter(with: " "))
            case .speak:
                guard !textTransaction.isHint else {
                    break
                }

                Analytics.shared.track(.keyboardPhraseSpoken)
                let utterance = textTransaction.text
                Task { [weak self] in
                    await self?.speechSynthesizer.speak(utterance)
                }
            case .numberPad, .alphabet, .openModifierPicker, .closeModifierPicker, .beginModifier, .endModifier:
                break
            }
        }
    }
}
