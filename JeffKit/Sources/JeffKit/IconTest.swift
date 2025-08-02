import SwiftUI

@available(iOS 14.0, *)
public struct IconTestView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("JeffKit Icon Test")
                .font(.title)
            
            HStack(spacing: 15) {
                ForEach(JeffApps.all, id: \.id) { app in
                    VStack {
                        Image(app.iconName, bundle: .module)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        
                        Text(app.localizedName)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
    }
}