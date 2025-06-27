//
//  Extensions.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/24/25.
//

import SwiftUI

extension View {
    func safeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIEdgeInsets()
        }
        return window.safeAreaInsets
    }
}
