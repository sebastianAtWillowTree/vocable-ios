//
//  AnimationContainerView.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class AnimationContainerView<T: UIView>: UIView {

    let child: T

    init(child: T) {
        self.child = child
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        child.translatesAutoresizingMaskIntoConstraints = false
        addSubview(child)

        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
