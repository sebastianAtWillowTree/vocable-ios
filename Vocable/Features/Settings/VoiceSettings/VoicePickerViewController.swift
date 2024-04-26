//
//  VoicePickerViewController.swift
//  Vocable
//
//  Created by Steve Foster on 4/18/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

final class VoicePickerViewController: PagingCarouselViewController {
        
    private typealias DataSource = CarouselCollectionViewDataSourceProxy<Int, VoiceProfileItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<VocableListCell, VoiceProfileItem>
    
    private var dataSource: DataSource!
    private var cellRegistration: CellRegistration!
    
    private let previewController = VoiceProfilePreviewController(context: .voiceSelection)
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLayoutForCurrentTraitCollection()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
        
        previewController.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.updateDataSource(items: items)
            }
            .store(in: &cancellables)
    }
        
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateBackgroundViewLayoutMargins()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "voice_picker.title")
    }

    private func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.backgroundColor = .collectionViewBackgroundColor
        
        let cellRegistration = CellRegistration { [weak self] cell, _, item in
            guard let self else { return }
            cell.contentConfiguration = VocableListContentConfiguration.voiceProfileItem(
                item,
                controller: self.previewController
            ) { [weak self] in
                self?.handleVoiceSelection(item.voice)
            }
        }
        
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, voice) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: voice
            )
        }
        self.dataSource = dataSource
        self.cellRegistration = cellRegistration
    }
    
    private func updateDataSource(
        items: [VoiceProfileItem]? = nil,
        previewing previewVoice: AVSpeechSynthesisVoice? = nil
    ) {
        let items = items ?? previewController.items
        var snapshot = NSDiffableDataSourceSnapshot<Int, VoiceProfileItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        if snapshot.itemIdentifiers.isEmpty {
            collectionView.backgroundView = EmptyStateView(type: VoicePickerEmptyStateConfiguration())
            updateBackgroundViewLayoutMargins()
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = .init(interRowSpacing: 8, interColumnSpacing: 30)

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(100))
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    private func updateBackgroundViewLayoutMargins() {
        guard let backgroundView = collectionView.backgroundView else { return }
        backgroundView.directionalLayoutMargins.leading = view.directionalLayoutMargins.leading
        backgroundView.directionalLayoutMargins.trailing = view.directionalLayoutMargins.trailing
    }
    
    fileprivate func handleVoiceSelection(_ voice: AVSpeechSynthesisVoice) {
        AppConfig.selectedVoiceIdentifier = voice.identifier
        updateDataSource()
    }
}

private struct VoicePickerEmptyStateConfiguration: EmptyStateRepresentable {
    let title: String = String(localized: "voice_picker.empty_state.title")
    let description: String? = String(localized: "voice_picker.empty_state.description")
    let buttonTitle: String? = nil
    let image: UIImage? = nil
    let yOffset: CGFloat? = nil
}
