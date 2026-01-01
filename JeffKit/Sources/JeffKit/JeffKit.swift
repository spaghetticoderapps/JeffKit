// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import StoreKit

public class JeffKit {
    public init() {}
    public func add() {
        print("hello there!")
    }
}

#if os(iOS)
import UIKit

public struct AppRatingPrompt {
    @MainActor public static func show(on viewController: UIViewController? = nil, appStoreId: String) {
        let alert = UIAlertController(
            title: "Enjoying the app?",
            message: "Would you mind taking a moment to rate us on the App Store?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes, I love it!", style: .default) { _ in
            openAppStore(appStoreId: appStoreId)
        })

        alert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: nil))

        if let presenter = viewController ?? UIApplication.shared.windows.first?.rootViewController {
            presenter.present(alert, animated: true)
        }
    }

    @MainActor public static func openAppStore(appStoreId: String) {
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

@available(iOS 14.0, *)
public struct AppRatingPromptView: View {
    @Binding var isPresented: Bool
    let appStoreId: String

    public init(isPresented: Binding<Bool>, appStoreId: String) {
        self._isPresented = isPresented
        self.appStoreId = appStoreId
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Enjoying the app?")
                .font(.headline)

            Text("Would you mind taking a moment to rate us on the App Store?")
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Not now") {
                    isPresented = false
                }
                .foregroundColor(.secondary)

                Button("Yes, I love it!") {
                    isPresented = false
                    AppRatingPrompt.openAppStore(appStoreId: appStoreId)
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

@available(iOS 14.0, *)
public struct AppRatingToastView: View {
    @Binding var isPresented: Bool
    let appStoreId: String
    let appName: String?

    public init(isPresented: Binding<Bool>, appStoreId: String, appName: String? = nil) {
        self._isPresented = isPresented
        self.appStoreId = appStoreId
        self.appName = appName
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(appName != nil ? "Enjoying \(appName!)?" : "Enjoying the app?")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Would you mind taking a moment to rate us on the App Store?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Not now") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                    Eventer.shared.tap("App rating - Not now")
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                Button("Yes, I love it!") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                    AppRatingPrompt.openAppStore(appStoreId: appStoreId)
                    Eventer.shared.tap("App rating - Yes, I love it")
                }
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .bottom))
        ))
    }
}
#endif
