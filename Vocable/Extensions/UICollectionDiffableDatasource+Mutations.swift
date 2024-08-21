//
//  UICollectionDiffableDatasource+Mutations.swift
//  Vocable
//
//  Created by Chris Stroud on 8/21/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

/// A  handful of convenience mutation functions to apply changes
/// to the current snapshot with or without animation
extension UICollectionViewDiffableDataSource {

    func reloadItem(_ item: ItemIdentifierType, animated: Bool = true) {
        reloadItems([item], animated: animated)
    }

    func reloadItems(_ items: [ItemIdentifierType], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.reloadItems(items)
        apply(snapshot, animatingDifferences: animated)
    }

    func appendItem(
        _ item: ItemIdentifierType,
        in section: SectionIdentifierType,
        animated: Bool = true
    ) {
        appendItems([item], in: section, animated: animated)
    }

    func appendItems(
        _ items: [ItemIdentifierType],
        in section: SectionIdentifierType,
        animated: Bool = true
    ) {
        var snapshot = snapshot()
        snapshot.appendItems(items, toSection: section)
        apply(snapshot, animatingDifferences: animated)
    }

    func removeItem(_ item: ItemIdentifierType, animated: Bool = true) {
        removeItems([item], animated: animated)
    }

    func removeItems(_ items: [ItemIdentifierType], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteItems(items)
        apply(snapshot, animatingDifferences: animated)
    }
}
