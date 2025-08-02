import SwiftUI

public struct AppInfo: Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let iconName: String
    public let appStoreId: String
    public let tintColor: Color
    
    public init(id: String, name: String, description: String, iconName: String, appStoreId: String, tintColor: Color) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.appStoreId = appStoreId
        self.tintColor = tintColor
    }
}

public struct CrossPromotionView: View {
    let app: AppInfo
    @State private var isPressed = false
    
    public init(app: AppInfo) {
        self.app = app
    }
    
    public var body: some View {
        Button(action: {
            if let url = URL(string: "https://apps.apple.com/app/id\(app.appStoreId)") {
                UIApplication.shared.open(url)
                Eventer.shared.tap("Cross Promotion - \(app.name)")
            }
        }) {
            HStack(spacing: 16) {
                Image(app.iconName, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(app.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

public struct CrossPromotionListView: View {
    let apps: [AppInfo]
    let currentAppId: String
    
    public init(apps: [AppInfo], currentAppId: String) {
        self.apps = apps
        self.currentAppId = currentAppId
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Discover more apps designed to help you live better")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                ForEach(apps.filter { $0.id != currentAppId }, id: \.id) { app in
                    CrossPromotionView(app: app)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

public struct CrossPromotionNavigationRow: View {
    let apps: [AppInfo]
    let currentAppId: String
    
    public init(apps: [AppInfo], currentAppId: String) {
        self.apps = apps
        self.currentAppId = currentAppId
    }
    
    private var otherAppsCount: Int {
        apps.filter { $0.id != currentAppId }.count
    }
    
    public var body: some View {
        NavigationLink {
            CrossPromotionListView(apps: apps, currentAppId: currentAppId)
                .navigationTitle("More Apps")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title3)
                    .foregroundColor(Color("CourtGray"))
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text("More Apps")
                        .foregroundColor(.primary)
                    if otherAppsCount > 0 {
                        Text("\(otherAppsCount) other apps by Jeff")
                            .font(.caption)
                            .foregroundColor(Color("CourtGray"))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color("CourtGray"))
            }
            .padding()
            .background(Color("NetWhite"))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CrossPromotionRow: View {
    let app: AppInfo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(app.iconName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(9)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(app.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: "https://apps.apple.com/app/id\(app.appStoreId)") {
                UIApplication.shared.open(url)
                Eventer.shared.tap("Cross Promotion Row - \(app.name)")
            }
        }
    }
}

public class JeffApps {
    public static let pickleballHub = AppInfo(
        id: "pickleball-hub",
        name: "PickleballHub",
        description: "Join thousands of players tracking their games and improving their skills. Find courts, connect with players, and level up your pickleball game!",
        iconName: "PickleballHubIcon",
        appStoreId: "6670420347",
        tintColor: Color.green
    )
    
    public static let gratitudeJournal = AppInfo(
        id: "gratitude-journal",
        name: "Gratitude Journal",
        description: "Transform your mindset in just 3 minutes a day. Beautiful themes, inspiring prompts, and watch your happiness grow like a tree!",
        iconName: "GratitudeJournalIcon",
        appStoreId: "6450279060",
        tintColor: Color.orange
    )
    
    public static let habitTracker = AppInfo(
        id: "habit-tracker",
        name: "One Habit Tracker",
        description: "Build life-changing habits with our beautiful, minimalist tracker. See your progress, stay motivated, and become your best self!",
        iconName: "HabitTrackerIcon",
        appStoreId: "6477730845",
        tintColor: Color.blue
    )
    
    public static let flashcards = AppInfo(
        id: "flashcards",
        name: "Flash Cards Master",
        description: "Master any subject with smart flashcards. Perfect for students, professionals, and lifelong learners. Study smarter, not harder!",
        iconName: "FlashcardsIcon",
        appStoreId: "6502370881",
        tintColor: Color.purple
    )
    
    public static let promptManager = AppInfo(
        id: "prompt-manager",
        name: "Prompt Manager AI",
        description: "Supercharge your AI workflow! Save, organize, and quickly access your best prompts. The ultimate tool for AI power users.",
        iconName: "PromptManagerIcon",
        appStoreId: "6738073662",
        tintColor: Color.indigo
    )
    
    public static let all: [AppInfo] = [
        pickleballHub,
        gratitudeJournal,
        habitTracker,
        flashcards,
        promptManager
    ]
}