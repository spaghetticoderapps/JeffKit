//
//  Haptics.swift
//  JeffKit
//
//  Created by Jeff Cedilla on 3/13/25.
//

import Foundation

#if os(iOS)
import UIKit

final public class Haptics {
    /// Shared instance
    @MainActor private static let shared = Haptics()

    // Private initializer to enforce singleton pattern
    private init() {

    }

    // MARK: - Static Interface

    /// Trigger light impact feedback
    @MainActor public static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Trigger medium impact feedback
    @MainActor public static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Trigger heavy impact feedback
    @MainActor public static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
#endif
