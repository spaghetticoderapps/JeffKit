//  WishKitView.swift
//  VictoryLog
//
//  Created by Jeff Cedilla on 11/24/24.
//

import SwiftUI
import WishKit

public struct WishKitView: View {
    private var primaryColor: Color
    
    public init(token: String, primaryColor: Color) {
        self.primaryColor = primaryColor
        WishKit.configure(with: token)
        WishKit.config.buttons.addButton.location = .navigationBar
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("__We'd love to hear your ideas!__\n\nShare your suggestions for new features or improvements to help make VictoryLog even better. \n\nYour feedback shapes our future updates.")
                .multilineTextAlignment(.leading)
                .font(.footnote)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            WishKit.FeedbackListView()
        }
        .onAppear {
            WishKit.theme.primaryColor = self.primaryColor
            WishKit.theme.secondaryColor = .set(light: .white, dark: .black)
        }
    }
}
