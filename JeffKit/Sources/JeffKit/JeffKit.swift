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
    
    @MainActor static func openAppStore(appStoreId: String) {
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
