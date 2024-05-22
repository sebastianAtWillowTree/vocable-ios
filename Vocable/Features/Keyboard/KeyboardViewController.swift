//
//  KeyboardViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/22/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVKit
import Combine

class KeyboardViewController: UICollectionViewController, VocableSpeechSynthesizerDelegate {

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>

    private typealias SuggestionCellRegistration = UICollectionView.CellRegistration<SuggestionCollectionViewCell, TextSuggestion>
    private typealias KeyCellRegistration = UICollectionView.CellRegistration<KeyboardKeyCollectionViewCell, String>
    private typealias FunctionKeyCellRegistration = UICollectionView.CellRegistration<KeyboardKeyCollectionViewCell, KeyboardFunctionKey>
    private typealias SpeakKeyCellRegistration = UICollectionView.CellRegistration<SpeakFunctionKeyboardKeyCollectionViewCell, KeyboardFunctionKey>

    private var speechSynthesizer: VocableSpeechSynthesizer!
    private var dataSource: DataSource!

    private var disposables = Set<AnyCancellable>()
    
    private var _textTransaction = TextTransaction(text: "") {
        didSet {
            attributedText = _textTransaction.attributedText
        }
    }
    
    private var textTransaction: TextTransaction {
        return _textTransaction
    }
    
    private let textExpression = TextExpression()
    
    private var suggestions: [TextSuggestion] = [] {
        didSet {
            var snapshot = dataSource.snapshot()
            let suggestionItems = snapshot.itemIdentifiers(inSection: .suggestions)
            snapshot.reconfigureItems(suggestionItems)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private var isSpeaking: Bool = false {
        didSet {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([.functionKey(.speak)])
            dataSource.apply(snapshot)
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

    private var suggestionCellRegistration: SuggestionCellRegistration!
    private var keyCellRegistration: KeyCellRegistration!
    private var functionKeyCellRegistration: FunctionKeyCellRegistration!
    private var speakCellRegistration: SpeakKeyCellRegistration!

    private enum ItemWrapper: Hashable {
        case key(String)
        case functionKey(KeyboardFunctionKey)
        case suggestionCell(Int)
    }
    
    private enum Section: Int, CaseIterable {
        case suggestions
        case keyboard
    }

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        speechSynthesizer = VocableSpeechSynthesizer(delegate: self)

        $attributedText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (newAttributedText) in
                guard
                    let self, let newAttributedText,
                    newAttributedText.string != self._textTransaction.text
                else {
                    return
                }
                self._textTransaction = TextTransaction(text: newAttributedText.string, intent: .lastCharacter)
            }
            .store(in: &disposables)

        setupCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }
    
    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.accessibilityID = .shared.keyboard.collectionView
    }
    
    private func configureDataSource() {
        let suggestionRegistration = SuggestionCellRegistration { cell, _, itemIdentifier in
            cell.setup(title: itemIdentifier.text)
        }
        let keyCellRegistration = KeyCellRegistration { cell, _, char in
            cell.setup(title: char)
            cell.accessibilityID = .shared.keyboard.key(char)
        }
        let functionKeyRegistration = FunctionKeyCellRegistration { cell, _, itemIdentifier in
            cell.setup(with: itemIdentifier.image)
            cell.accessibilityID = .shared.keyboard.key(itemIdentifier.accessibilityID)
        }
        let speakKeyRegistration = SpeakKeyCellRegistration { cell, _, itemIdentifier in
            if #available(iOS 17.0, *), self.isSpeaking {
                cell.setup(with: itemIdentifier.image, effect: .variableColor.iterative.dimInactiveLayers.reversing, options: .repeating)
            } else {
                cell.setup(with: itemIdentifier.image)
            }
            cell.accessibilityID = .shared.keyboard.key(itemIdentifier.accessibilityID)
        }

        dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            guard let self else { return nil }
            return switch identifier {
            case .suggestionCell(let index):
                collectionView.dequeueConfiguredReusableCell(
                    using: suggestionRegistration,
                    for: indexPath,
                    item: suggestions[safe: index] ?? .init(text: "")
                )
            case .key(let char):
                collectionView.dequeueConfiguredReusableCell(
                    using: keyCellRegistration,
                    for: indexPath,
                    item: char
                )
            case .functionKey(let functionType):
                if functionType == .speak {
                    collectionView.dequeueConfiguredReusableCell(
                        using: speakKeyRegistration,
                        for: indexPath,
                        item: functionType
                    )
                } else {
                    collectionView.dequeueConfiguredReusableCell(
                        using: functionKeyRegistration,
                        for: indexPath,
                        item: functionType
                    )
                }
            }
        }
        self.keyCellRegistration = keyCellRegistration
        self.functionKeyCellRegistration = functionKeyRegistration
        self.speakCellRegistration = speakKeyRegistration
        self.suggestionCellRegistration = suggestionRegistration
        updateSnapshot()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetCollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch sectionKind {
            case .keyboard:
                return PresetCollectionViewCompositionalLayout.editTextKeyboardLayout(with: layoutEnvironment)
            case .suggestions:
                return PresetCollectionViewCompositionalLayout.suggestiveTextSectionLayout(with: layoutEnvironment)
            }
        }
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        return layout
    }
    
    private func updateSnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        // Snapshot construction
        snapshot.appendSections([.suggestions])
        snapshot.appendItems((0...3).map { ItemWrapper.suggestionCell($0)})
        
        snapshot.appendSections([.keyboard])
        if sizeClass == .hCompact_vRegular && !AppConfig.isCompactQWERTYKeyboardEnabled {
            snapshot.appendItems(KeyboardLocale.current.compactPortraitKeyMapping.map { ItemWrapper.key("\($0)") })
        } else {
            snapshot.appendItems(KeyboardLocale.current.landscapeKeyMapping.map { ItemWrapper.key("\($0)") })
        }
        
        snapshot.appendItems([.functionKey(.clear), .functionKey(.space), .functionKey(.backspace), .functionKey(.speak)])
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        for selectedPath in collectionView.indexPathsForSelectedItems ?? [] {
            if selectedPath.section == indexPath.section && selectedPath != indexPath {
                collectionView.deselectItem(at: selectedPath, animated: true)
            }
        }
        
        switch selectedItem {
        case .functionKey(let functionType):
            switch functionType {
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
            case .clear:
                setTextTransaction(TextTransaction(text: "", intent: .none))
            case .backspace:
                setTextTransaction(textTransaction.deletingLastToken())
            }
        case .key(let char):
            setTextTransaction(textTransaction.appendingCharacter(with: char))
        case .suggestionCell(let index):
            if let suggestion = suggestions[safe: index] {
                setTextTransaction(textTransaction.insertingSuggestion(with: suggestion.text))
            }
        }
        
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .functionKey, .key:
            return true
        case .suggestionCell(let index):
            return suggestions.indices.contains(index)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .functionKey, .key:
            return true
        case .suggestionCell(let index):
            return suggestions.indices.contains(index)
        }
    }
    
    private func setTextTransaction(_ transaction: TextTransaction) {
        _textTransaction = transaction
        
        // Update suggestions
        if textTransaction.isHint || textTransaction.text.last == " " {
            suggestions = []
        } else {
            textExpression.replace(text: textTransaction.text)
            suggestions = textExpression.suggestions().map({ TextSuggestion(text: $0) })
        }
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateSnapshot()
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
}
