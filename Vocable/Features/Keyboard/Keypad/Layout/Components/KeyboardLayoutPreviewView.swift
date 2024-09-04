//
//  KeyboardLayoutPreviewView.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 17.0, *)
private struct KeyboardViewRepresentable<Layout: KeyboardLayout>: UIViewRepresentable {

    let layout: Layout
    private(set) var mode: KeyboardLayoutMode = .alphabetical

    func makeUIView(context: Context) -> KeyboardView {
        KeyboardView(previewLayout: layout)
    }

    func updateUIView(_ uiView: KeyboardView, context: Context) {
        uiView.mode = mode
    }
}

struct KeyboardLayoutPreviewView<Layout: KeyboardLayout>: View {

    let layout: Layout
    private(set) var mode: KeyboardLayoutMode = .alphabetical

    var body: some View {
        if #available(iOS 17.0, *) {
            KeyboardViewRepresentable(layout: layout, mode: mode)
                .safeAreaPadding(.all)
                .background(Color(uiColor: .collectionViewBackgroundColor))
        } else {
            Text(verbatim: "Preview requires iOS 17.0")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
