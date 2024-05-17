//
//  VocableListCellPrimaryButton.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class VocableListCellPrimaryButton: GazeableButton {

    private var trailingAccessoryViewLayoutGuide = UILayoutGuide()
    private(set) var trailingAccessoryView: UIView?
    
    private var leadingAccessoryViewLayoutGuide = UILayoutGuide()
    private(set) var leadingAccessoryView: UIView?
    
    private let defaultInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
    
    override var isEnabled: Bool {
        didSet {
            trailingAccessoryView?.alpha = isEnabled ? 1 : 0.5
            leadingAccessoryView?.alpha = isEnabled ? 1 : 0.5
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
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
        
        configuration = UIButton.Configuration.plain()
        
        addLayoutGuide(trailingAccessoryViewLayoutGuide)
        NSLayoutConstraint.activate([
            trailingAccessoryViewLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            trailingAccessoryViewLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingAccessoryViewLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingAccessoryViewLayoutGuide.widthAnchor.constraint(equalToConstant: defaultInsets.trailing).withPriority(.defaultLow)
        ])
        
        addLayoutGuide(leadingAccessoryViewLayoutGuide)
        NSLayoutConstraint.activate([
            leadingAccessoryViewLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            leadingAccessoryViewLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingAccessoryViewLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingAccessoryViewLayoutGuide.widthAnchor.constraint(equalToConstant: defaultInsets.leading).withPriority(.defaultLow)
        ])
    }
    
    override func updateConfiguration() {
        super.updateConfiguration()
        guard var configuration else { return }
        let trailingInset = trailingAccessoryViewLayoutGuide.layoutFrame.width
        let leadingInset = leadingAccessoryViewLayoutGuide.layoutFrame.width

        if configuration.contentInsets.leading != leadingInset {
            configuration.contentInsets.leading = leadingInset
        }

        if configuration.contentInsets.trailing != trailingInset {
            configuration.contentInsets.trailing = trailingInset
        }
        self.configuration = configuration
    }

    func setTrailingAccessory(_ accessory: VocableListCellAccessory?) {
        let trailingInsets: NSDirectionalEdgeInsets = defaultInsets
        switch accessory?.content {
        case .image(let image):
            if let trailingImageView = trailingAccessoryView as? UIImageView {
                trailingImageView.image = image
            } else {
                setTrailingAccessoryView(UIImageView(image: image), insets: trailingInsets)
            }
        case .toggle(let isOn):
            if let trailingToggle = trailingAccessoryView as? UISwitch {
                trailingToggle.setOn(isOn, animated: true)
            } else {
                let toggle = UISwitch()
                toggle.setOn(isOn, animated: true)
                toggle.isUserInteractionEnabled = false
                setTrailingAccessoryView(toggle, insets: trailingInsets)
            }
        case .none:
            setTrailingAccessoryView(nil, insets: .zero)
        }
    }

    private func setTrailingAccessoryView(_ view: UIView?, insets: NSDirectionalEdgeInsets) {

        defer {
            trailingAccessoryView = view
        }

        if view === trailingAccessoryView {
            return
        }

        trailingAccessoryView?.removeFromSuperview()

        guard let view = view else {
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.trailingAnchor, constant: -insets.trailing),
            view.centerYAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.centerYAnchor),
            view.leadingAnchor.constraint(equalTo: trailingAccessoryViewLayoutGuide.leadingAnchor, constant: insets.leading)
        ])
    }
    
    func setLeadingAccessory(_ accessory: VocableListCellAccessory?) {
        let leadingInsets: NSDirectionalEdgeInsets = defaultInsets
        switch accessory?.content {
        case .image(let image):
            if let leadingImageView = leadingAccessoryView as? UIImageView {
                leadingImageView.image = image
            } else {
                setLeadingAccessoryView(UIImageView(image: image), insets: leadingInsets)
            }
        case .toggle(let isOn):
            if let leadingToggle = leadingAccessoryView as? UISwitch {
                leadingToggle.setOn(isOn, animated: true)
            } else {
                let toggle = UISwitch()
                toggle.setOn(isOn, animated: true)
                toggle.isUserInteractionEnabled = false
                setLeadingAccessoryView(toggle, insets: leadingInsets)
            }
        case .none:
            setLeadingAccessoryView(nil, insets: .zero)
        }
    }

    private func setLeadingAccessoryView(_ view: UIView?, insets: NSDirectionalEdgeInsets) {
        
        defer {
            leadingAccessoryView = view
        }

        if view === leadingAccessoryView {
            return
        }

        leadingAccessoryView?.removeFromSuperview()

        guard let view = view else {
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAccessoryViewLayoutGuide.leadingAnchor, constant: insets.leading),
            view.centerYAnchor.constraint(equalTo: leadingAccessoryViewLayoutGuide.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: leadingAccessoryViewLayoutGuide.trailingAnchor, constant: -insets.trailing)
        ])
    }
}
